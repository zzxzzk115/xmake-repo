package("vri")
    set_homepage("https://github.com/zzxzzk115/VRI")
    set_description("VRI - a cross-API Render Hardware Interface (C ABI core + header-only C++23 wrapper) over Vulkan/D3D12/Metal/OpenGL(ES)/WebGPU.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/VRI/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zzxzzk115/VRI.git")

    add_versions("v0.1.2", "c169e504038382dc079aa7e267c82f3371eb561c6fa6f44fa59857268be6cdbd")
    add_versions("v0.1.1", "b91baa762dfdbe9273f348fa023a835f05776a73cb4c75c5c9dd7d511bbe3063")
    add_versions("v0.1.0", "6aba9d064743ae50840fc04b13474aaad568e196330ef0f11d27ad335fb60fec")

    -- Backend selection mirrors VRI's own options. Vulkan is the reference backend (default on);
    -- the others are opt-in so consumers only pull the deps they actually use.
    add_configs("vulkan", {description = "Enable the Vulkan backend", default = true, type = "boolean"})
    add_configs("gl",     {description = "Enable the OpenGL / OpenGL ES / WebGL backend", default = false, type = "boolean"})
    add_configs("wgpu",   {description = "Enable the WebGPU backend", default = false, type = "boolean"})

    on_load(function (package)
        -- Propagate this package's MSVC runtime to the backend deps we add below. on_load runs
        -- after the consumer's add_requireconfs("**") is resolved, so deps added here would
        -- otherwise miss the runtime and fall back to CMake's /MD default - which then fails to
        -- link into an /MT consumer (LNK2038). (Same idiom as the vshadersystem package.)
        local dep_configs = {}
        if package:is_plat("windows") and package:runtimes() then
            dep_configs.runtimes = package:runtimes()
        end

        -- Dependency set per backend, matching VRI's external/xmake.lua.
        if package:config("vulkan") and not package:is_plat("wasm") then
            package:add("deps", "vulkan-headers 1.4.335", "vulkan-memory-allocator")
        end
        if package:config("gl") then
            package:add("deps", "spirv-cross vulkan-sdk-1.4.335", {configs = dep_configs})
            if package:is_plat("wasm") then
                -- The GL backend targets WebGL2 (GLES3) via Emscripten's GLFW3 + FULL_ES3 ports.
                -- FULL_ES3 provides the ES3 entry points the backend calls (glMapBufferRange,
                -- glTexStorage2D/3D, glGenSamplers, ...); without these link flags a consumer's
                -- final link fails with undefined GL symbols. VRI's own target sets them publicly,
                -- but target-public flags don't reach package consumers, so export them here.
                package:add("ldflags", "-sUSE_GLFW=3", "-sFULL_ES3",
                            "-sMIN_WEBGL_VERSION=2", "-sMAX_WEBGL_VERSION=2")
            else
                local glad_configs = {profile = "core", api = "gl=4.6"}
                if dep_configs.runtimes then glad_configs.runtimes = dep_configs.runtimes end
                package:add("deps", "glad", {configs = glad_configs})
                if not package:is_plat("linux") then
                    package:add("deps", "glfw", {configs = dep_configs})
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
