package("vasset")
    set_homepage("https://github.com/zzxzzk115/vasset")
    set_description("VAsset - the asset pipeline (mesh/texture/material/audio/animation, VPK, importers + CLI) for the Vultra ecosystem.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/vasset/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zzxzzk115/vasset.git")

    add_versions("v0.4.0", "d02d14bdbe1835a64c019eaed18bbb575d7ba9c59863083526b7ff12e358dfe9")

    -- The runtime lib (loadMesh/loadTexture/VPK) is what most consumers link. The importer side
    -- (assimp/ozz/vshadersystem) builds the vasset-cli cook tool; turn it off for a leaner runtime
    -- consumer that only loads cooked assets.
    add_configs("importers", {description = "Build the importer targets + vasset-cli.", default = true, type = "boolean"})

    -- Runtime deps (the vasset runtime target's public packages) -- propagated to consumers.
    add_deps("vfilesystem", {public = true})
    add_deps("glm", "stb", "xxhash", "meshoptimizer", "tinyexr", "zstd", {public = true})
    add_deps("miniaudio 0.11.25", {public = true})

    on_load(function (package)
        -- ktx (+ opencl) mirror the vasset runtime target configs.
        local ktx_opencl = not package:is_plat("android", "wasm", "iphoneos")
        package:add("deps", "ktx", {configs = {decoder = true, opencl = ktx_opencl, shared = false, vulkan = true}, public = true})
        if ktx_opencl then
            package:add("deps", "opencl", {public = true})
        end

        -- Importer/CLI build deps (private: needed to build vasset-cli, not to link the runtime).
        local importers = package:config("importers")
            and not package:is_plat("android")
            and (not package:is_plat("wasm"))
        if importers then
            package:add("deps", "assimp", {configs = {shared = false, draco = package:is_plat("windows")}, private = true})
            package:add("deps", "ozz-animation", {configs = {tools = false, fbx = false, gltf = false, data = false}, private = true})
            package:add("deps", "vshadersystem v0.11.3", {private = true})
        end

        -- Runtime link set: the runtime lib + its vendored dds-ktx. The importer libs and the
        -- vasset-cli binary are not link targets for consumers (the CLI is reached via PATH).
        package:add("links", "vasset", "dds-ktx")

        -- GLM configuration the vasset headers are compiled against.
        package:add("defines", "GLM_FORCE_DEPTH_ZERO_TO_ONE", "GLM_ENABLE_EXPERIMENTAL", "GLM_FORCE_RADIANS")
        package:addenv("PATH", "bin")
    end)

    on_install(function (package)
        local configs = {
            vasset_build_examples = false,
            vasset_build_tests    = false,
        }
        if not package:config("importers") then
            configs.vasset_enable_wasm_import = false
        end
        if package:is_plat("windows") and package:runtimes() then
            configs.runtimes = package:runtimes()
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("vasset/vmesh.hpp", {configs = {languages = "c++23"}}))
    end)
