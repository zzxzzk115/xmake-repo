package("libvultra")
    set_homepage("https://github.com/zzxzzk115/libvultra")
    set_description("libvultra is the core library of Vultra, which can be used for rapidly creating graphics or game prototypes without the VultraEditor.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/libvultra.git")

    add_versions("2025.09.10", "5fe1cd5e13249d28b638c3e0cdb4f8f692f91319")
    add_versions("2025.09.08", "0aeaf756482465069a26a20951c6e1cc99873a8e")

    add_configs("tracy", {description = "Enable Tracy profiler support", default = true, type = "boolean"})
    add_configs("tracky", {description = "Enable Tracky profiler support", default = true, type = "boolean"})
    add_configs("renderdoc", {description = "Enable RenderDoc support", default = true, type = "boolean"})
    add_configs("vk_validation_stack_trace", {description = "Enable Vulkan validation stacktrace support", default = false, type = "boolean"})

    add_deps("fmt", {system=false})
    add_deps("spdlog")
    add_deps("magic_enum")
    add_deps("entt")
    add_deps("glm")
    add_deps("stb")
    add_deps("vulkan-headers 1.4.309+0")
    add_deps("vulkan-memory-allocator-hpp")
    add_deps("fg")
    add_deps("cpptrace")
    add_deps("tracy 0.11.1", {configs={on_demand=true}})
    add_deps("libsdl3", {system=false})
    add_deps("imgui v1.92.0-docking", {configs={vulkan=true,sdl3=true,wchar32=true}})
    add_deps("assimp", {configs={debug=false,draco=true,shared=true}})
    add_deps("spirv-cross vulkan-sdk-1.4.309", {configs={debug=false,shared=true}, system=false})
    add_deps("glslang 1.4.309+0", {configs={debug=false},system=false})
    add_deps("openxr", {configs={debug=false,shared=true}})

    on_load(function (package)
        -- Workaround, wait for policy to be updated
        -- https://github.com/xmake-io/xmake-repo/issues/3962#issuecomment-2096205856
        import("lib.detect.find_library")
        import("detect.sdks.find_vulkansdk")

        local vulkansdk = find_vulkansdk()
        if vulkansdk then
            print(format("Found Vulkan SDK: %s", vulkansdk.bindir))
            package:add("runevs", "PATH", vulkansdk.bindir)

            -- We don't need to add the include directories for vulkan headers
            -- Instead, we rely on Vulkan-Headers
            -- target:add("includedirs", vulkansdk.includedirs)

            local suffix
            if package:is_plat("windows") then
                suffix = ".lib"
            elseif package:is_plat("macosx") then
                suffix = ".dylib"
            else
                suffix = ".so"
            end

            local utils = {}
            table.insert(utils, package:is_plat("windows") and "vulkan-1" or "vulkan")

            for _, util in ipairs(utils) do
                if not find_library(util, vulkansdk.linkdirs) then
                    wprint(format("The library %s for %s is not found!", util, package:arch()))
                    return
                end
                -- add vulkan library
                lib_name = package:is_plat("windows") and util or "lib" .. util
                package:add("syslinks", path.join(vulkansdk.linkdirs[1], lib_name .. suffix), { public = true })
                print(format("Added Vulkan library: %s", path.join(vulkansdk.linkdirs[1], lib_name .. suffix)))
            end
        end
        package:add("defines", "VULKAN_HPP_DISPATCH_LOADER_DYNAMIC")
        package:add("defines", "TRACY_ENABLE=" .. (package:config("tracy") and "1" or "0"))
        package:add("defines", "TRACKY_ENABLE=" .. (package:config("tracky") and "1" or "0"))
        package:add("defines", "TRACKY_VULKAN")
        package:add("defines", "FMT_UNICODE=0")

        if package:config("debug") then
            if package:config("vk_validation_stack_trace") then
                package:add("defines", "VULTRA_ENABLE_VK_VALIDATION_STACK_TRACE")
            end
            if package:config("renderdoc") then
                package:add("defines", "VULTRA_ENABLE_RENDERDOC")
            end
        end
    end)

    on_install(function (package)
        local configs = {
            examples = false,
            tests = false,
        }
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vultra/core/base/common_context.hpp>
            #include <vultra/core/os/window.hpp>
            #include <vultra/core/rhi/command_buffer.hpp>
            #include <vultra/core/rhi/frame_controller.hpp>
            #include <vultra/core/rhi/graphics_pipeline.hpp>
            #include <vultra/core/rhi/render_device.hpp>
            #include <vultra/core/rhi/vertex_buffer.hpp>

            using namespace vultra;

            struct SimpleVertex
            {
                glm::vec3 position;
                glm::vec3 color;
            };

            int main()
            try
            {
                os::Window window = os::Window::Builder {}.setExtent({1024, 768}).build();

                // Event callback
                window.on<os::GeneralWindowEvent>([](const os::GeneralWindowEvent& event, os::Window& wd) {
                    if (event.type == SDL_EVENT_KEY_DOWN)
                    {
                        // Press ESC to close the window
                        if (event.internalEvent.key.key == SDLK_ESCAPE)
                        {
                            wd.close();
                        }
                    }
                });

                rhi::RenderDevice renderDevice(rhi::RenderDeviceFeatureFlagBits::eNormal);

                VULTRA_CLIENT_INFO("RenderDevice Name: {}", renderDevice.getName());
                VULTRA_CLIENT_INFO("RenderDevice PhysicalDeviceInfo: {}", renderDevice.getPhysicalDeviceInfo().toString());

                VULTRA_CLIENT_WARN("Press ESC to close the window");

                window.setTitle(std::format("RHI Triangle ({})", renderDevice.getName()));

                // Create swapchain
                rhi::Swapchain swapchain = renderDevice.createSwapchain(window);

                // Create frame controller
                rhi::FrameController frameController {renderDevice, swapchain, 3};

                // Create vertex buffer
                rhi::VertexBuffer vertexBuffer = renderDevice.createVertexBuffer(sizeof(SimpleVertex), 3);

                // Upload vertex buffer
                // Triangle in NDC for simplicity.
                constexpr auto kTriangle = std::array {
                    // clang-format off
                    //                    position                 color
                    SimpleVertex{ {  0.0f,  0.5f, 0.0f }, { 1.0f, 0.0f, 0.0f } }, // top
                    SimpleVertex{ { -0.5f, -0.5f, 0.0f }, { 0.0f, 1.0f, 0.0f } }, // left
                    SimpleVertex{ {  0.5f, -0.5f, 0.0f }, { 0.0f, 0.0f, 1.0f } }  // right
                    // clang-format on
                };
                {
                    constexpr auto kVerticesSize       = sizeof(SimpleVertex) * kTriangle.size();
                    auto           stagingVertexBuffer = renderDevice.createStagingBuffer(kVerticesSize, kTriangle.data());

                    renderDevice.execute(
                        [&](auto& cb) { cb.copyBuffer(stagingVertexBuffer, vertexBuffer, vk::BufferCopy {0, 0, kVerticesSize}); });
                }

                const auto* const vertCode = R"(
            #extension GL_ARB_separate_shader_objects : enable

            layout(location = 0) in vec3 a_Position;
            layout(location = 1) in vec3 a_Color;

            out gl_PerVertex { vec4 gl_Position; };
            layout(location = 0) out vec3 v_FragColor;

            void main() {
            v_FragColor = a_Color;
            gl_Position = vec4(a_Position, 1.0);
            gl_Position.y *= -1.0;
            })";
                const auto* const fragCode = R"(
            #extension GL_ARB_separate_shader_objects : enable

            layout(location = 0) in vec3 v_FragColor;
            layout(location = 0) out vec4 FragColor;

            void main() {
            FragColor = vec4(v_FragColor, 1.0);
            })";

                // Create graphics pipeline
                auto graphicsPipeline = rhi::GraphicsPipeline::Builder {}
                                            .setColorFormats({swapchain.getPixelFormat()})
                                            .setInputAssembly({
                                                {0, {.type = rhi::VertexAttribute::Type::eFloat3, .offset = 0}},
                                                {1,
                                                {
                                                    .type   = rhi::VertexAttribute::Type::eFloat3,
                                                    .offset = offsetof(SimpleVertex, color),
                                                }},
                                            })
                                            .addShader(rhi::ShaderType::eVertex, {.code = vertCode})
                                            .addShader(rhi::ShaderType::eFragment, {.code = fragCode})
                                            .setDepthStencil({
                                                .depthTest  = false,
                                                .depthWrite = false,
                                            })
                                            .setRasterizer({.polygonMode = rhi::PolygonMode::eFill})
                                            .setBlending(0, {.enabled = false})
                                            .build(renderDevice);

                while (!window.shouldClose())
                {
                    window.pollEvents();

                    if (!swapchain)
                        continue;

                    auto& backBuffer        = frameController.getCurrentTarget().texture;
                    auto& cb                = frameController.beginFrame();
                    bool  acquiredNextFrame = frameController.acquireNextFrame();
                    if (!acquiredNextFrame)
                    {
                        continue;
                    }

                    rhi::prepareForAttachment(cb, backBuffer, false);
                    const rhi::FramebufferInfo framebufferInfo {.area             = rhi::Rect2D {.extent = backBuffer.getExtent()},
                                                                .colorAttachments = {
                                                                    {
                                                                        .target     = &backBuffer,
                                                                        .clearValue = glm::vec4 {0.0f, 0.0f, 0.0f, 1.0f},
                                                                    },
                                                                }};
                    {
                        RHI_GPU_ZONE(cb, "RHI Triangle");
                        cb.beginRendering(framebufferInfo)
                            .bindPipeline(graphicsPipeline)
                            .draw({
                                .vertexBuffer = &vertexBuffer,
                                .numVertices  = static_cast<uint32_t>(kTriangle.size()),
                            })
                            .endRendering();
                    }

                    frameController.endFrame();
                    frameController.present();
                }

                // Remember to wait idle explicitly before any destructors.
                renderDevice.waitIdle();

                return 0;
            }
            catch (const std::exception& e)
            {
                VULTRA_CLIENT_CRITICAL("Exception: {}", e.what());
            }
        ]]}, {configs = {languages = "c++23"}}))
    end)
