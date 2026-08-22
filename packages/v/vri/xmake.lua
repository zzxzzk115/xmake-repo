package("vri")
    set_homepage("https://github.com/zzxzzk115/VRI")
    set_description("VRI - a cross-API Render Hardware Interface (C ABI core + header-only C++23 wrapper) over Vulkan/D3D12/Metal/OpenGL(ES)/WebGPU.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/VRI/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zzxzzk115/VRI.git")

    add_versions("v0.1.12", "e23fba0afc97e032f430163a98b60c8202d96f9600815f3137a10fae417e1740")
    add_versions("v0.1.11", "d4404deffed12c8851c8ba0ece7073c334ba82f54fb52acbf0af4babe94de3b4")
    add_versions("v0.1.10", "e4cf50d65ac801474a2beba26a54546b84122eddcf3ab83bac6114ea4806784a")
    add_versions("v0.1.9", "ec109e6652fd7806ec569e4676162a02bc7a99bd8dd2896b7733a529815471dd")
    add_versions("v0.1.8", "97e29be17b93b1d7d1a95c6d4ce07928589673f45f6221e704ecd2dd417f38c3")
    add_versions("v0.1.7", "ce55287c77de13323d28990e81faec892cdce5cb6646e3e5cf6dceff505155af")
    add_versions("v0.1.6", "50e6dfb7cddc68ea5916c9d8ce0d762d4b49c42cbe29cd1c7ddf6b8585473f84")
    add_versions("v0.1.5", "532899e76cdb4aebfb5af6b543bb5ca2a0dc223aafbf1e9182980afc26b3ceca")
    add_versions("v0.1.4", "df316fc2c0706ce8e66a9e93ff3930a5abb82793b10bac5135074d8872cff64c")
    add_versions("v0.1.3", "cbc95748f949b2164fe79cb3f4c74a0619a6edb35aa0d235e4f9e83e90816a08")
    add_versions("v0.1.2", "c169e504038382dc079aa7e267c82f3371eb561c6fa6f44fa59857268be6cdbd")
    add_versions("v0.1.1", "b91baa762dfdbe9273f348fa023a835f05776a73cb4c75c5c9dd7d511bbe3063")
    add_versions("v0.1.0", "6aba9d064743ae50840fc04b13474aaad568e196330ef0f11d27ad335fb60fec")

    -- Backend selection mirrors VRI's own options. Vulkan is the reference backend (default on);
    -- the others are opt-in so consumers only pull the deps they actually use.
    add_configs("vulkan", {description = "Enable the Vulkan backend", default = true, type = "boolean"})
    add_configs("gl",     {description = "Enable the OpenGL / OpenGL ES / WebGL backend", default = false, type = "boolean"})
    add_configs("wgpu",   {description = "Enable the WebGPU backend", default = false, type = "boolean"})
    add_configs("d3d12",  {description = "Enable the Direct3D 12 backend (Windows only)", default = false, type = "boolean"})
    add_configs("metal",  {description = "Enable the native Metal backend (macOS only)", default = false, type = "boolean"})

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
            -- The loader. Same package-boundary problem as the GL/D3D12/Metal branches below,
            -- but one step worse: VRI links it through a rule("vulkansdk") declared in its own
            -- root xmake.lua, and a project-level rule doesn't travel with the installed package
            -- at all. Without this a consumer's link fails with ~117 undefined vk* symbols
            -- (vkCreateInstance, vkQueuePresentKHR, vkCreateWin32SurfaceKHR, ...) even though
            -- vri.lib itself built fine.
            -- No dep_configs: the loader is a C-ABI import library, so it has no MSVC runtime
            -- coupling - same reason vulkan-headers and VMA above don't take it either.
            if package:is_plat("android") then
                package:add("syslinks", "vulkan") -- part of the platform there
            else
                package:add("deps", "vulkan-loader")
            end
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
                -- Public syslinks/frameworks the GL backend needs. VRI's source/xmake.lua adds
                -- these to its own target as {public = true}, but a target's public syslinks do
                -- NOT cross the package boundary (package.tools.xmake install only captures the
                -- library + headers), so a consumer of the vri package would otherwise have to
                -- re-declare them by hand - e.g. Lazy-100 manually adds EGL + wayland-egl. Mirror
                -- them here so `add_packages("vri")` links out of the box.
                if package:is_plat("linux") then
                    -- context/present go through EGL (VRI_GL_EGL); wayland-egl provides the
                    -- Wayland window surface (wl_egl_window); libGL resolves the desktop-GL
                    -- core symbols glad loads through eglGetProcAddress.
                    package:add("syslinks", "EGL", "wayland-egl", "GL")
                elseif package:is_plat("windows") then
                    -- GetDC / SetPixelFormat / SwapBuffers live in gdi32.
                    package:add("syslinks", "gdi32")
                elseif package:is_plat("macosx") then
                    -- GL present retargets the NSOpenGL context to the window view and paces
                    -- on a CVDisplayLink (Cocoa + the deprecated OpenGL framework + CoreVideo).
                    package:add("frameworks", "Cocoa", "OpenGL", "CoreVideo")
                end
            end
        end
        if package:config("wgpu") then
            package:add("deps", "webgpu-sdk v0.1.2")
        end
        if package:config("d3d12") and package:is_plat("windows") then
            -- D3D12 core + DXGI; d3dcompiler (FXC) for runtime HLSL->DXBC. These are public
            -- syslinks on VRI's own target, so - like the GL backend above - they don't cross
            -- the package boundary and must be re-declared for consumers to link.
            package:add("syslinks", "d3d12", "dxgi", "d3dcompiler")
            -- Agility SDK: its d3d12.h (DXR 1.2 / opacity micromaps) takes precedence over the
            -- stock Windows SDK header; a consuming exe deploys D3D12Core.dll from it.
            package:add("deps", "directx12-agility", {configs = dep_configs})
        end
        if package:config("metal") and package:is_plat("macosx") then
            -- SPIR-V is VRI's portable shader IR; SPIRV-Cross transpiles it to MSL at pipeline
            -- creation (the same package - and pin - the GL backend uses for SPIR-V->GLSL).
            package:add("deps", "spirv-cross vulkan-sdk-1.4.335", {configs = dep_configs})
            -- Metal + CAMetalLayer (QuartzCore) + the SDL3 metal view's NSWindow/AppKit chain.
            -- Public frameworks on VRI's own target, so they don't cross the package boundary.
            package:add("frameworks", "Metal", "QuartzCore", "Foundation", "Cocoa")
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
            vri_backend_d3d12  = package:config("d3d12"),
            vri_backend_metal  = package:config("metal"),
        }
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        -- Compile-only check (avoids needing the platform Vulkan loader at link time here).
        assert(package:has_cxxincludes("vri/vri.h", {configs = {languages = "c++23"}}))
    end)
