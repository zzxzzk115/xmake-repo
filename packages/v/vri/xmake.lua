package("vri")
    set_homepage("https://github.com/zzxzzk115/VRI")
    set_description("VRI - a cross-API Render Hardware Interface (C ABI core + header-only C++23 wrapper) over Vulkan/D3D12/Metal/OpenGL(ES)/WebGPU.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/VRI/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zzxzzk115/VRI.git")

    add_versions("v0.1.0", "6aba9d064743ae50840fc04b13474aaad568e196330ef0f11d27ad335fb60fec")

    -- Backend selection mirrors VRI's own options. Vulkan is the reference backend (default on);
    -- the others are opt-in so consumers only pull the deps they actually use.
    add_configs("vulkan", {description = "Enable the Vulkan backend", default = true, type = "boolean"})
    add_configs("gl",     {description = "Enable the OpenGL / OpenGL ES / WebGL backend", default = false, type = "boolean"})
    add_configs("wgpu",   {description = "Enable the WebGPU backend", default = false, type = "boolean"})

    on_load(function (package)
        -- Dependency set per backend, matching VRI's external/xmake.lua.
        if package:config("vulkan") and not package:is_plat("wasm") then
            package:add("deps", "vulkan-headers 1.4.335", "vulkan-memory-allocator")
        end
        if package:config("gl") then
            package:add("deps", "spirv-cross vulkan-sdk-1.4.335")
            if not package:is_plat("wasm") then
                package:add("deps", "glad", {configs = {profile = "core", api = "gl=4.6"}})
                if not package:is_plat("linux") then
                    package:add("deps", "glfw")
                end
            end
        end
        if package:config("wgpu") then
            package:add("deps", "webgpu-sdk v0.1.2")
        end
    end)

    on_install(function (package)
        local configs = {
            vri_build_examples = false,
            vri_build_tests    = false,
            vri_build_tools    = false,
            vri_backend_vulkan = package:config("vulkan"),
            vri_backend_gl     = package:config("gl"),
            vri_backend_wgpu   = package:config("wgpu"),
        }
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        -- Compile-only check (avoids needing the platform Vulkan loader at link time here).
        assert(package:has_cxxincludes("vri/vri.h", {configs = {languages = "c++23"}}))
    end)
