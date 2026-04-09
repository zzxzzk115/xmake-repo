package("vshadersystem")
    set_homepage("https://github.com/zzxzzk115/vshadersystem")
    set_description("vshadersystem is a standalone shader compilation and material reflection pipeline.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/vshadersystem/archive/refs/tags/$(version).tar.gz", {alias = "source"})
    add_urls("https://github.com/zzxzzk115/vshadersystem.git", {alias = "git"})

    add_versions("source:v0.6.2", "73a381c343f856030574cc787f7e30d4d6e020db26cef40413ba7f6fd7170560")
    add_versions("source:v0.8.1", "7abcc865f5c5df541128f0527a99dca24e26bdad3faca246c09b802c33e40efe")
    add_versions("source:v0.7.2", "a6e268d2cbc770e6ed8ffc8c554a9898db54ff7e2b045ee0af595286bce925fb")
    add_versions("git:v0.8.1", "v0.8.1")
    add_versions("git:v0.7.2", "v0.7.2")

    on_load(function (package)
        if package:version():ge("0.7.2") then
            local version = tostring(package:version())
            local prebuilt
            if package:version():ge("0.8.0") then
                prebuilt = {
                    ["android-arm64-v8a"] = "6f05d27ac6d9dcfedbe6ed56c7bf717434f679a8f25f2f5471a439741cf85deb",
                    ["android-armeabi-v7a"] = "386ba7f61e950b0e3e544f732e1ad219f268d7837face80aff28108a2a2f7e6c",
                    ["android-x86_64"] = "c52d2f2a04a73c24a6b7b39090111167a45d345d205b51d401fdd68efeb2d62d",
                    ["linux-arm64"] = "3872bc3e5f74baaa94d638cf1e7922d865aaef97ae4a0595b8bc3bcb75f23062",
                    ["linux-x86"] = "2e7c639d35e088858fde7468b11533cd329292872d551fc2a394f9eddd8f3d25",
                    ["linux-i386"] = "2e7c639d35e088858fde7468b11533cd329292872d551fc2a394f9eddd8f3d25",
                    ["linux-x64"] = "311fd785015439ed94c0ebd12f2bf4b5d75bee08d2e8d518157d573f6188489b",
                    ["linux-x86_64"] = "311fd785015439ed94c0ebd12f2bf4b5d75bee08d2e8d518157d573f6188489b",
                    ["macosx-arm64"] = "2395beeb0c9249ffc9a10dded85fc1d496e5ccc5b18bc1a16e006d8abd70bed4",
                    ["wasm-wasm32"] = "374b57517b8182373e3cc9137477d4ac3cdec870e9df5d2f48d80cf197958bd9",
                    ["windows-x64"] = "a1af3d4f8dff5628ec1dfcabefb61a173504b4f1bb20271fe1397b8fa1f332dd",
                    ["windows-x86_64"] = "a1af3d4f8dff5628ec1dfcabefb61a173504b4f1bb20271fe1397b8fa1f332dd",
                    ["mingw-x64"] = "a1af3d4f8dff5628ec1dfcabefb61a173504b4f1bb20271fe1397b8fa1f332dd",
                    ["mingw-x86_64"] = "a1af3d4f8dff5628ec1dfcabefb61a173504b4f1bb20271fe1397b8fa1f332dd"
                }
            else
                prebuilt = {
                    ["android-arm64-v8a"] = "7315bd9e0ef9e7273c0aab5eded48643b73e2b25988e9f64329ba8cebc0f5dfa",
                    ["android-armeabi-v7a"] = "f26fc0d1c44d02eee48c3d8dd72fbc7391f4908959722597929a399fd8bebbaa",
                    ["android-x86_64"] = "88baf88b1d7e355fecca91024256d5c7550947b97431b784f9326fa597d9923a",
                    ["linux-arm64"] = "8aa78814126817c050be017417a65f14e44a0862548fb8400dc5a4fd4b799e35",
                    ["linux-x86"] = "cbb311058c66ea9d2814956f76fe2de8360652a327ac36ea14b7a645188e49ef",
                    ["linux-i386"] = "cbb311058c66ea9d2814956f76fe2de8360652a327ac36ea14b7a645188e49ef",
                    ["linux-x64"] = "c999c454b9c9bca8e2b635a9695638d686a7f2bb6313c4f477876236fd9fbdb1",
                    ["linux-x86_64"] = "c999c454b9c9bca8e2b635a9695638d686a7f2bb6313c4f477876236fd9fbdb1",
                    ["macosx-arm64"] = "588aa4912dab2c4120a1fba5e32e02f748c0155a7097beed4589e614c12f95be",
                    ["wasm-wasm32"] = "62ab22f3d811c11287222593fa14e23b90517a324b8762a52c4b33e38e1d38c6",
                    ["windows-x64"] = "dc350f9755cdaaba1da319a414105927d152b3ef3e9417e9e8b2af2b8fd26d0c",
                    ["windows-x86_64"] = "dc350f9755cdaaba1da319a414105927d152b3ef3e9417e9e8b2af2b8fd26d0c",
                    ["mingw-x64"] = "dc350f9755cdaaba1da319a414105927d152b3ef3e9417e9e8b2af2b8fd26d0c",
                    ["mingw-x86_64"] = "dc350f9755cdaaba1da319a414105927d152b3ef3e9417e9e8b2af2b8fd26d0c"
                }
            end
            local assets = {
                ["linux-x64"] = "linux-x86_64",
                ["windows-x64"] = "windows-x64",
                ["mingw-x64"] = "windows-x64",
                ["mingw-x86_64"] = "windows-x64",
                ["windows-x86_64"] = "windows-x64",
                ["wasm-wasm32"] = "wasm-wasm32"
            }
            local key = package:plat() .. "-" .. package:arch()
            local sha = prebuilt[key]
            assert(sha, "package(vshadersystem): unsupported prebuilt target: " .. key)
            local asset = assets[key] or key
            package:set("urls", "https://github.com/zzxzzk115/vshadersystem/releases/download/$(version)/vshadersystem-prebuilt-$(version)-" .. asset .. ".zip")
            package:add("versions", version, sha)
            package:add("links", "vshadersystem", "spirv-tools", "tint")
            package:add("deps", "spirv-cross vulkan-sdk-1.4.335", {configs = {shared = true, debug = false}, system = false, public = true})
            package:add("deps", "glslang 1.4.335+0", {configs = {debug = false}, system = false, public = true})
            package:add("deps", "xxhash", {public = true})
            package:add("links", "xxhash")
            if package:is_cross() then
                package:add("deps", "vshadersystem~host", {kind = "binary", host = true, private = true})
            end
        else
            package:add("deps", "spirv-cross vulkan-sdk-1.4.309", {configs = { shared = true, debug = false }, system = false, public = true})
            package:add("deps", "glslang 1.4.309+0", {configs = { debug = false }, system = false, public = true})
            package:add("deps", "xxhash", {public = true})
        end
        package:addenv("PATH", "bin")
    end)

    on_install(function (package)
        if package:version():ge("0.7.2") then
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
        if package:version():ge("0.7.2") and not package:is_cross() then
            os.vrun("vshaderc --help")
        end
        if package:is_cross() or package:is_binary() then
            return
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
