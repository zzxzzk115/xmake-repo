package("vasset")
    set_homepage("https://github.com/zzxzzk115/vasset")
    set_description("VAsset - the asset pipeline (mesh/texture/material/audio/animation, VPK, importers + CLI) for the Vultra ecosystem.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/vasset/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zzxzzk115/vasset.git")

    add_versions("v0.4.1", "b5b6635e4decb5e49f6b14eb5c80e507b9b27df45e606351bbb4d68e4942724d")
    add_versions("v0.4.0", "d02d14bdbe1835a64c019eaed18bbb575d7ba9c59863083526b7ff12e358dfe9")

    -- The runtime lib (loadMesh/loadTexture/VPK) is what most consumers link. The importer side
    -- (assimp/ozz/vshadersystem) builds the vasset-cli cook tool; turn it off for a leaner runtime
    -- consumer that only loads cooked assets.
    add_configs("importers", {description = "Build the importer targets + vasset-cli.", default = true, type = "boolean"})

    -- Off by default: most consumers only load cooked assets and reach the cook tool via PATH. Turn
    -- on to LINK the importer side (vasset-import + assimp/ozz/vshadersystem) into the consumer, for
    -- in-process import/cook/pack via the vasset C ABI -- e.g. an editor or a runtime that supports
    -- dynamic import. Heavier (pulls assimp/ozz), hence opt-in.
    add_configs("link_importers", {description = "Link the importer libs for in-process import/cook/pack.", default = false, type = "boolean"})

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

        -- Importer/CLI build deps. Private by default (needed to build vasset-cli, not to link the
        -- runtime); made public when link_importers, so the importer lib resolves assimp/ozz/vsh.
        local importers = package:config("importers")
            and not package:is_plat("android")
            and (not package:is_plat("wasm"))
        local link_importers = importers and package:config("link_importers")
        if importers then
            local imp_private = not link_importers
            package:add("deps", "assimp", {configs = {shared = false, draco = package:is_plat("windows")}, private = imp_private})
            package:add("deps", "ozz-animation", {configs = {tools = false, fbx = false, gltf = false, data = false}, private = imp_private})
            package:add("deps", "vshadersystem v0.11.3", {private = imp_private})
        end

        -- Link set. With link_importers, expose the importer lib + its vendored libs (GaussForge/spz)
        -- so consumers can call vasset's import/cook/pack C ABI in-process (vasset-import is built
        -- separately from the runtime vasset lib). The importer lib comes first -- it depends on the
        -- runtime lib. Without link_importers, only the runtime lib + dds-ktx (CLI reached via PATH).
        if link_importers then
            package:add("links", "vasset-import", "GaussForge", "spz")
        end
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
