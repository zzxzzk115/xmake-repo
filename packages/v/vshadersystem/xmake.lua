package("vshadersystem")
    set_homepage("https://github.com/zzxzzk115/vshadersystem")
    set_description("vshadersystem is a standalone shader compilation and material reflection pipeline.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/vshadersystem/archive/refs/tags/$(version).tar.gz", {alias = "source"})
    add_urls("https://github.com/zzxzzk115/vshadersystem.git", {alias = "git"})

    add_versions("source:v0.6.2", "73a381c343f856030574cc787f7e30d4d6e020db26cef40413ba7f6fd7170560")
    add_versions("source:v0.7.0", "df3633ba9dfb75a000999f45ca26a519cdaf9359e748204e65a09fcf49a15caf")
    add_versions("git:v0.7.0", "v0.7.0")

    on_load(function (package)
        if package:version():ge("0.7.0") then
            local prebuilt = {
                ["android-arm64-v8a"] = "3a73b901f79605a59dd2f921018d8a0c30827d76c118a7769a1c3a0692f27262",
                ["android-armeabi-v7a"] = "10d0b52d309d052400f28d2ffb21a239b6df20bc265bc8831ccab211121628e3",
                ["android-x86_64"] = "0ac91f42e151cbc74665dd82ec5a3c57ed9f42a61454b03e1a10a1fc578a0a4b",
                ["linux-arm64"] = "3b4d9510e172d43350c69ce04e32407933f8ff620eee6401b2e59c493120626f",
                ["linux-x86"] = "9ea96b63f31de6c854175162dc78e43bdb72f66c5b22c5ad2b27c339c6578781",
                ["linux-i386"] = "9ea96b63f31de6c854175162dc78e43bdb72f66c5b22c5ad2b27c339c6578781",
                ["linux-x64"] = "4fff2349cd434b51c363bc5d91eb1a4bf3bf918aec76f289e197437140dcd343",
                ["linux-x86_64"] = "4fff2349cd434b51c363bc5d91eb1a4bf3bf918aec76f289e197437140dcd343",
                ["macosx-arm64"] = "5c23fed7c5ae3460e80ee7860a2cd9731747e2b9c9c6482d22a17f9b51b7d619",
                ["windows-arm64"] = "41c1a62815c5dfcb604ae3366be4176aed1e9ca0abf4fc0c205b8811e2ec4953",
                ["windows-x64"] = "34c5cf8d30e244e5a3be9ae3f54cc71ef46bb4738be8ef5326e96a517743ff31",
                ["windows-x86_64"] = "34c5cf8d30e244e5a3be9ae3f54cc71ef46bb4738be8ef5326e96a517743ff31",
                ["mingw-x64"] = "34c5cf8d30e244e5a3be9ae3f54cc71ef46bb4738be8ef5326e96a517743ff31",
                ["mingw-x86_64"] = "34c5cf8d30e244e5a3be9ae3f54cc71ef46bb4738be8ef5326e96a517743ff31"
            }
            local assets = {
                ["linux-x64"] = "linux-x86_64",
                ["windows-x64"] = "windows-x64",
                ["mingw-x64"] = "windows-x64",
                ["mingw-x86_64"] = "windows-x64",
                ["windows-x86_64"] = "windows-x64"
            }
            local key = package:plat() .. "-" .. package:arch()
            local sha = prebuilt[key]
            assert(sha, "package(vshadersystem): unsupported prebuilt target: " .. key)
            local asset = assets[key] or key
            package:set("urls", "https://github.com/zzxzzk115/vshadersystem/releases/download/$(version)/vshadersystem-prebuilt-$(version)-" .. asset .. ".zip")
            package:add("versions", "v0.7.0", sha)
            package:add("links", "vshadersystem", "spirv-tools", "tint")
            package:add("deps", "spirv-cross vulkan-sdk-1.4.335", {configs = {shared = true, debug = false}, system = false, public = true})
            package:add("deps", "glslang 1.4.335+0", {configs = {debug = false}, system = false, public = true})
            package:add("deps", "xxhash", {public = true})
            package:add("links", "xxhash")
        else
            package:add("deps", "spirv-cross vulkan-sdk-1.4.309", {configs = { shared = true, debug = false }, system = false, public = true})
            package:add("deps", "glslang 1.4.309+0", {configs = { debug = false }, system = false, public = true})
            package:add("deps", "xxhash", {public = true})
        end
        package:addenv("PATH", "bin")
    end)

    on_install(function (package)
        if package:version():ge("0.7.0") then
            local version = tostring(package:version())
            local rootdir = os.dirs("vshadersystem-prebuilt-" .. version .. "-*")[1]
            if not rootdir then
                rootdir = os.dirs(path.join("prebuilt", "vshadersystem-prebuilt-" .. version .. "-*"))[1]
            end
            assert(rootdir, "package(vshadersystem): cannot find prebuilt root directory")
            os.cp(path.join(rootdir, "*"), package:installdir())
        else
            local configs = {
                vshadersystem_build_examples = false,
            }
            import("package.tools.xmake").install(package, configs)
        end
    end)

    on_test(function (package)
        if package:version():ge("0.7.0") and not package:is_plat("android") then
            os.vrun("vshaderc --help")
        end
        assert(package:check_cxxsnippets({test = [[
            #include <vshadersystem/system.hpp>
            #include <iostream>

            using namespace vshadersystem;

            int main()
            {
                const char* source = R"(

            #version 460

            #pragma vultra material

            #pragma vultra param baseColor default(1,1,1,1)

            layout(location = 0) out vec4 outColor;

            void main()
            {
                outColor = vec4(1,0,0,1);
            }

            )";

                BuildRequest req;

                req.source.virtualPath = "test.frag.vshader";
                req.source.sourceText  = source;

                req.options.stage = ShaderStage::eFrag;

                auto r = build_single_shader(req);

                if (!r.isOk())
                    return 1;

                if (r.value().binary.spirv.empty())
                    return 1;

                return 0;
            }
        ]]}, {configs = {languages = "c++23"}}))
    end)
