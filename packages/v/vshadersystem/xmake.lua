package("vshadersystem")
    set_homepage("https://github.com/zzxzzk115/vshadersystem")
    set_description("vshadersystem is a standalone shader compilation and material reflection pipeline.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/vshadersystem/archive/refs/tags/$(version).tar.gz", {alias = "source"})
    add_urls("https://github.com/zzxzzk115/vshadersystem.git", {alias = "git"})

    add_versions("source:v0.6.2", "73a381c343f856030574cc787f7e30d4d6e020db26cef40413ba7f6fd7170560")
    add_versions("source:v0.8.0", "7b2f6d3cfc5173b8b4cf6963c4a03951d21d67b57ab3b09600c4a606b4a3a995")
    add_versions("source:v0.7.2", "a6e268d2cbc770e6ed8ffc8c554a9898db54ff7e2b045ee0af595286bce925fb")
    add_versions("git:v0.8.0", "v0.8.0")
    add_versions("git:v0.7.2", "v0.7.2")

    on_load(function (package)
        if package:version():ge("0.7.2") then
            local version = tostring(package:version())
            local prebuilt
            if package:version():ge("0.8.0") then
                prebuilt = {
                    ["android-arm64-v8a"] = "c59225e6e05978f815fd23671ff196d11931eb22f9d62f4f5eac87e1c8ef74e2",
                    ["android-armeabi-v7a"] = "e9b1541d0cc7a66665dec0a0b597626c6c8ed704f82b1c812be40409507249bf",
                    ["android-x86_64"] = "175f860c2ec5852b9b5fa9456642a588b90c62077499d3331f655915fdbeaa82",
                    ["linux-arm64"] = "98f9014db3a3cb67337c791fbc43ffb1cc735c732ae53c55ad3b97f633b5f419",
                    ["linux-x86"] = "780795142f9311b3e28a654d2b25ab980965d34ca1914a532e008e2db5415a14",
                    ["linux-i386"] = "780795142f9311b3e28a654d2b25ab980965d34ca1914a532e008e2db5415a14",
                    ["linux-x64"] = "d42a67db2efde5cdb7007678032643dc33f10e52002e97d1bdd01d010639c652",
                    ["linux-x86_64"] = "d42a67db2efde5cdb7007678032643dc33f10e52002e97d1bdd01d010639c652",
                    ["macosx-arm64"] = "24f9cb0fb26a38b60a215fcbfb2571590df1ebbd5c383d08e696c82ce0788f79",
                    ["wasm-wasm32"] = "408d8b34594e20e260dae85b7fb6e02e1b7af8162930cf9c48779aafe58d4399",
                    ["windows-arm64"] = "ffc9a57b60f92eb0c1d0bbd0fae005b3cf44702f68674e028877f3024e72156b",
                    ["windows-x64"] = "f43123d294f217926ce8f8fe3479850be861d5afce38c8f2253361f0e9215316",
                    ["windows-x86_64"] = "f43123d294f217926ce8f8fe3479850be861d5afce38c8f2253361f0e9215316",
                    ["mingw-x64"] = "f43123d294f217926ce8f8fe3479850be861d5afce38c8f2253361f0e9215316",
                    ["mingw-x86_64"] = "f43123d294f217926ce8f8fe3479850be861d5afce38c8f2253361f0e9215316"
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
                    ["windows-arm64"] = "e700c0f62605811e85ac9936b397376d0220deaa89fb640c18ae4ce6333e980f",
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
