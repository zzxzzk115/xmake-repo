package("libvultra")
    set_homepage("https://github.com/zzxzzk115/libvultra")
    set_description("libvultra is the core library of Vultra, which can be used for rapidly creating graphics or game prototypes without the VultraEditor.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/libvultra.git")
    add_versions("2025.08.01", "13e2a23b9f0583db47983ad455bc7b97e98028d1")

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

    on_install(function (package)
        local configs = {
            examples = false,
            tests = false,
        }
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vultra/core/os/window.hpp>

            using namespace vultra;

            int main()
            {
                auto window = os::Window::Builder {}.setTitle("Empty Vultra Window").setExtent({1024, 768}).build();

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

                return 0;
            }
        ]]}, {configs = {languages = "c++23"}}))
    end)
