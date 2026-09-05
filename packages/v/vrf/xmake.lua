package("vrf")
    set_homepage("https://github.com/zzxzzk115/VRI-Framework")
    set_description("VRI-Framework - framegraph, streaming builders, asset loaders and app scaffolding over VRI.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/VRI-Framework/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zzxzzk115/VRI-Framework.git")

    add_versions("v0.1.0", "d4591f0a325bb2fab5815033d7c1bdcb688cf2bdf6b42d9b98d6dc6cfec30520")

    -- Mirrors VRI-Framework's own vrf_* options. Defaults follow upstream, EXCEPT bake_bc7:
    -- upstream defaults it on, but as a package default it drags libktx (CMake + astc-encoder +
    -- zstd) into every consumer's dependency graph, so it is opt-in here.
    add_configs("imgui",    {description = "Build the Dear ImGui integration", default = true,  type = "boolean"})
    add_configs("sdl3",     {description = "Build the SDL3 window backend",    default = true,  type = "boolean"})
    add_configs("glfw",     {description = "Build the GLFW window backend",    default = false, type = "boolean"})
    add_configs("ktx2",     {description = "Enable the KTX2 texture loader (libktx)", default = false, type = "boolean"})
    add_configs("bake_bc7", {description = "Block-compress baked cache textures to BC7 (libktx)", default = false, type = "boolean"})
    add_configs("openxr",   {description = "Enable OpenXR support (vrf::xr)",  default = false, type = "boolean"})
    add_configs("vplot",    {description = "Enable the vplot plotting integration", default = false, type = "boolean"})
    add_configs("draco",    {description = "Enable Draco-compressed glTF",     default = false, type = "boolean"})
    add_configs("tracy",    {description = "Enable Tracy profiler zones",      default = false, type = "boolean"})

    -- Backend selection, forwarded to the vri package (same option set as vri's own).
    add_configs("vulkan", {description = "Enable the Vulkan backend",          default = true,  type = "boolean"})
    add_configs("gl",     {description = "Enable the OpenGL / OpenGL ES backend", default = false, type = "boolean"})
    add_configs("wgpu",   {description = "Enable the WebGPU backend",          default = false, type = "boolean"})
    add_configs("d3d12",  {description = "Enable the Direct3D 12 backend (Windows only)", default = false, type = "boolean"})
    add_configs("metal",  {description = "Enable the native Metal backend (macOS only)",  default = false, type = "boolean"})

    add_deps("fg", "glm")

    on_load(function (package)
        -- Same idiom as the vri package: on_load runs after the consumer's add_requireconfs("**")
        -- resolves, so deps added here must carry the runtime explicitly or they fall back to
        -- CMake's /MD default and fail to link into an /MT consumer (LNK2038).
        local dep_configs = {}
        if package:is_plat("windows") and package:runtimes() then
            dep_configs.runtimes = package:runtimes()
        end

        -- vri and glm appear in vrf's PUBLIC API, so consumers need both. Pinned to the SAME
        -- version VRI-Framework's own external/xmake.lua requires: two vri packages in one
        -- project would link two copies of the C ABI.
        local vri_configs = {
            vulkan = package:config("vulkan"),
            gl     = package:config("gl"),
            wgpu   = package:config("wgpu"),
            d3d12  = package:config("d3d12"),
            metal  = package:config("metal"),
        }
        if dep_configs.runtimes then vri_configs.runtimes = dep_configs.runtimes end
        package:add("deps", "vri v0.1.15", {configs = vri_configs})

        -- vshadersystem is confined to shader_library.cpp (PImpl) so its headers stay out of the
        -- public API - but it is a real static lib compiled into vrf.lib, so its symbols (plus
        -- spirv-cross/glslang/xxhash) must resolve in the consumer's final link.
        package:add("deps", "vshadersystem v1.2.0", {configs = dep_configs})

        if package:config("imgui") then
            package:add("defines", "VRF_WITH_IMGUI")
            local imgui_configs = {sdl3 = package:config("sdl3"), glfw = package:config("glfw")}
            if dep_configs.runtimes then imgui_configs.runtimes = dep_configs.runtimes end
            package:add("deps", "imgui v1.92.5-docking", {configs = imgui_configs})
        end
        if package:config("sdl3") then package:add("deps", "libsdl3", {configs = dep_configs}) end
        if package:config("glfw") then package:add("deps", "glfw",    {configs = dep_configs}) end
        if package:config("ktx2") or package:config("bake_bc7") then
            local ktx_configs = {ktx1 = true, ktx2 = true, shared = false}
            if dep_configs.runtimes then ktx_configs.runtimes = dep_configs.runtimes end
            package:add("deps", "ktx", {configs = ktx_configs})
        end
        if package:config("draco")  then package:add("deps", "draco", {configs = dep_configs}) end
        if package:config("vplot")  then package:add("deps", "vplot 0.1.1", {configs = dep_configs}) end
        if package:config("openxr") then
            package:add("defines", "VRF_WITH_OPENXR")
            package:add("deps", "openxr", {configs = dep_configs})
            package:add("deps", "vulkan-headers 1.4.335")
        end
        if package:config("tracy") then
            package:add("defines", "VRF_WITH_TRACY", "TRACY_ENABLE")
            package:add("deps", "tracy", {configs = dep_configs})
        end

        -- KNOWN GAP (v0.1.0): VRI-Framework declares its vendored GaussForge/spz as separate
        -- static-lib targets with set_default(false), so `xmake install` skips them and only
        -- vrf.lib is packaged. Everything except the gaussian-splat loader links fine; calling
        -- that path yields undefined gf::/spz symbols. Deliberately NOT adding them to `links`
        -- here: naming libs the package does not ship turns a clear undefined-symbol error into
        -- a confusing "cannot open GaussForge.lib". (The vasset package has the same gap.)
        -- The real fix belongs upstream and is targeted for v0.1.1.
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {
            vrf_build_examples = false,
            vrf_build_tests    = false,
            vrf_window_sdl3    = package:config("sdl3"),
            vrf_window_glfw    = package:config("glfw"),
            vrf_with_imgui     = package:config("imgui"),
            vrf_with_openxr    = package:config("openxr"),
            vrf_with_vplot     = package:config("vplot"),
            vrf_with_tracy     = package:config("tracy"),
            vrf_loader_ktx2    = package:config("ktx2"),
            vrf_loader_draco   = package:config("draco"),
            vrf_bake_bc7       = package:config("bake_bc7"),
            vrf_backend_vulkan = package:config("vulkan"),
            vrf_backend_gl     = package:config("gl"),
            vrf_backend_wgpu   = package:config("wgpu"),
            vrf_backend_d3d12  = package:config("d3d12"),
            vrf_backend_metal  = package:config("metal"),
        }
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        -- Compile-only: a link test would need the platform Vulkan loader here.
        assert(package:has_cxxincludes("vrf/vrf.hpp", {configs = {languages = "c++23"}}))
    end)
