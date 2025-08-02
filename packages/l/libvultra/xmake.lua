package("libvultra")
    set_homepage("https://github.com/zzxzzk115/libvultra")
    set_description("libvultra is the core library of Vultra, which can be used for rapidly creating graphics or game prototypes without the VultraEditor.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/libvultra.git")
    add_versions("2025.08.01", "13e2a23b9f0583db47983ad455bc7b97e98028d1")

    add_configs("tracy", {description = "Enable Tracy profiler support", default = true, type = "boolean"})
    add_configs("tracky", {description = "Enable Tracky profiler support", default = true, type = "boolean"})
    add_configs("renderdoc", {description = "Enable RenderDoc support", default = true, type = "boolean"})

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
    add_deps("imgui v1.92.0-docking", {configs={vulkan=true,sdl3=true,wchar32=true}})
    add_deps("assimp", {configs={debug=false,draco=true,shared=true}})
    add_deps("spirv-cross vulkan-sdk-1.4.309", {configs={debug=false,shared=true}})
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
        package:add("defines", "VULKAN_HPP_DISPATCH_LOADER_DYNAMIC", {public = true})
        
        if package:config("tracy") then
            package:add("defines", "TRACY_ENABLE=1", {public = true})
        else
            package:add("defines", "TRACY_ENABLE=0", {public = true})
        end

        if package:config("tracky") then
            package:add("defines", "TRACKY_ENABLE=1", {public = true})
        else
            package:add("defines", "TRACKY_ENABLE=0", {public = true})
        end
        package:add("defines", "TRACKY_VULKAN", {public = true})
        
        package:add("defines", "FMT_UNICODE=0", {public = true})

        if package:config("debug") then
            package:add("defines", "_DEBUG", {public = true})
            if package:config("renderdoc") then
                package:add("defines", "VULTRA_ENABLE_RENDERDOC", {public = true})
            end
        else
            package:add("defines", "NDEBUG", {public = true})
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
            #include <vultra/core/rhi/graphics_pipeline.hpp>
            #include <vultra/core/rhi/vertex_buffer.hpp>
            #include <vultra/function/app/imgui_app.hpp>

            #include <imgui.h>

            using namespace vultra;

            struct SimpleVertex
            {
                glm::vec3 position;
                glm::vec3 color;
            };

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

            // Triangle in NDC for simplicity.
            constexpr auto kTriangle = std::array {
                // clang-format off
                //                    position                 color
                SimpleVertex{ {  0.0f,  0.5f, 0.0f }, { 1.0f, 0.0f, 0.0f } }, // top
                SimpleVertex{ { -0.5f, -0.5f, 0.0f }, { 0.0f, 1.0f, 0.0f } }, // left
                SimpleVertex{ {  0.5f, -0.5f, 0.0f }, { 0.0f, 0.0f, 1.0f } }  // right
                // clang-format on
            };

            class ImGuiExampleApp final : public ImGuiApp
            {
            public:
                explicit ImGuiExampleApp(const std::span<char*>& args) :
                    ImGuiApp(args, {.title = "RHI Triangle with ImGui"}, {.enableDocking = false})
                {
                    m_VertexBuffer = m_RenderDevice->createVertexBuffer(sizeof(SimpleVertex), 3);

                    // Upload vertex buffer
                    {
                        constexpr auto kVerticesSize       = sizeof(SimpleVertex) * kTriangle.size();
                        auto           stagingVertexBuffer = m_RenderDevice->createStagingBuffer(kVerticesSize, kTriangle.data());

                        m_RenderDevice->execute([&](auto& cb) {
                            cb.copyBuffer(stagingVertexBuffer, m_VertexBuffer, vk::BufferCopy {0, 0, kVerticesSize});
                        });
                    }

                    m_GraphicsPipeline = rhi::GraphicsPipeline::Builder {}
                                            .setColorFormats({m_Swapchain.getPixelFormat()})
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
                                            .build(*m_RenderDevice);
                }

                void onImGui() override
                {
                    ImGui::ShowDemoWindow();
                    ImGui::Begin("Example Window");
                    ImGui::Text("Hello, world!");
            #ifdef VULTRA_ENABLE_RENDERDOC
                    ImGui::Button("Capture One Frame");
                    if (ImGui::IsItemClicked())
                    {
                        m_WantCaptureFrame = true;
                    }
            #endif
                    ImGui::End();
                }

                void onRender(rhi::CommandBuffer& cb, const rhi::RenderTargetView rtv, const fsec dt) override
                {
                    const auto& [frameIndex, target] = rtv;
                    rhi::prepareForAttachment(cb, target, false);
                    {
                        RHI_GPU_ZONE(cb, "RHI Triangle");
                        cb.beginRendering({
                                            .area = {.extent = target.getExtent()},
                                            .colorAttachments =
                                                {
                                                    {
                                                        .target     = &target,
                                                        .clearValue = glm::vec4 {0.0f, 0.0f, 0.0f, 1.0f},
                                                    },
                                                },
                                        })
                            .bindPipeline(m_GraphicsPipeline)
                            .draw({
                                .vertexBuffer = &m_VertexBuffer,
                                .numVertices  = static_cast<uint32_t>(kTriangle.size()),
                            })
                            .endRendering();
                    }
                    ImGuiApp::onRender(cb, rtv, dt);
                }

            private:
                rhi::VertexBuffer     m_VertexBuffer;
                rhi::GraphicsPipeline m_GraphicsPipeline;
            };

            CONFIG_MAIN(ImGuiExampleApp)
        ]]}, {configs = {languages = "c++23"}}))
    end)
