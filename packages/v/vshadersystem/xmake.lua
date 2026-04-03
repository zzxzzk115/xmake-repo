package("vshadersystem")
    set_homepage("https://github.com/zzxzzk115/vshadersystem")
    set_description("vshadersystem is a standalone shader compilation and material reflection pipeline.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/vshadersystem/archive/refs/tags/$(version).tar.gz", {alias = "source"})
    add_urls("https://github.com/zzxzzk115/vshadersystem.git", {alias = "git"})

    add_versions("source:v0.6.2", "73a381c343f856030574cc787f7e30d4d6e020db26cef40413ba7f6fd7170560")
    add_versions("source:v0.7.1", "d501a2051679b3fad158e9560704f2ee49541d55e0d0681ee3613eb18e2b57b8")
    add_versions("git:v0.7.1", "v0.7.1")

    on_load(function (package)
        if package:version():ge("0.7.1") then
            local prebuilt = {
                ["android-arm64-v8a"] = "885d57e6d5251b0a2b979f153e5aebdda28f0f920068c19775c664e0f2099974",
                ["android-armeabi-v7a"] = "679891b3b6ce811a407bbf94f70a78cb482c8b05e48c530851d5e427c1c7cd59",
                ["android-x86_64"] = "d73afcf02a0d0c167ad32c4d6a4f9161509c85c3d8bbe8b9aac9710d74f5f137",
                ["linux-arm64"] = "e106b809d404fc3a60658a96c24871b64a676680867711339e364bd2585af79e",
                ["linux-x86"] = "afa8ab72f2122bf5ab1775189be1dcb23a4fb7c3d9eb590995a22fe4b80ce9d3",
                ["linux-i386"] = "afa8ab72f2122bf5ab1775189be1dcb23a4fb7c3d9eb590995a22fe4b80ce9d3",
                ["linux-x64"] = "03aa22242670d2addc3c73d40a9ebb0db81d98f40436fdbaf81bd52c25203502",
                ["linux-x86_64"] = "03aa22242670d2addc3c73d40a9ebb0db81d98f40436fdbaf81bd52c25203502",
                ["macosx-arm64"] = "193c9662b8bdc433e8e6a496ec9bde78d62c4ac2652b2a3470629074656d426d",
                ["windows-arm64"] = "103d7643189f8b389cfe749804a127765e25efe25d89db6d06179f2b08946415",
                ["windows-x64"] = "e0cb0c7be0c9deea8398f290ffe8225ed11753c14cfba818a909711f11bf9b97",
                ["windows-x86_64"] = "e0cb0c7be0c9deea8398f290ffe8225ed11753c14cfba818a909711f11bf9b97",
                ["mingw-x64"] = "e0cb0c7be0c9deea8398f290ffe8225ed11753c14cfba818a909711f11bf9b97",
                ["mingw-x86_64"] = "e0cb0c7be0c9deea8398f290ffe8225ed11753c14cfba818a909711f11bf9b97"
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
            package:add("versions", "v0.7.1", sha)
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
        if package:version():ge("0.7.1") then
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
        if package:version():ge("0.7.1") and not package:is_plat("android") then
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
