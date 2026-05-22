package("vshadersystem")
    set_homepage("https://github.com/zzxzzk115/vshadersystem")
    set_description("vshadersystem is a standalone shader compilation and material reflection pipeline.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/vshadersystem/archive/refs/tags/$(version).tar.gz", {alias = "source"})
    add_urls("https://github.com/zzxzzk115/vshadersystem.git", {alias = "git"})

    add_versions("source:v0.8.4", "4916c6957069cb92c57e89f5748f8c345eef4d58795e8f96aa8e284aa2a00387")
    add_versions("source:v0.8.3", "e7b561234f1cc7a5d8048684baaa5f4f74ece3fbd3d0b96da6c8a77d1e1c84d2")
    add_versions("source:v0.8.2", "b449a24d364a5c4b15b8cbb53144abf14723bb863b2cd330b99273d26cddb4db")
    add_versions("source:v0.7.2", "a6e268d2cbc770e6ed8ffc8c554a9898db54ff7e2b045ee0af595286bce925fb")
    add_versions("source:v0.6.2", "73a381c343f856030574cc787f7e30d4d6e020db26cef40413ba7f6fd7170560")
    add_versions("git:v0.8.4", "v0.8.4")
    add_versions("git:v0.8.3", "v0.8.3")
    add_versions("git:v0.8.2", "v0.8.2")
    add_versions("git:v0.7.2", "v0.7.2")

    local function _windows_prebuilt_asset(package)
        if not package:is_plat("windows") or not package:is_arch("x64", "x86_64") then
            return
        end
        if package:debug() or package:has_runtime("MDd", "MTd") then
            return
        end

        local runtime = package:has_runtime("MT") and "mt" or "md"
        local toolset = "14.29"
        local msvc = package:toolchain("msvc")
        local vs_toolset = msvc and msvc:config("vs_toolset")
        if vs_toolset and vs_toolset:startswith("14.44") then
            toolset = "latest"
        end
        return "windows-x64-msvc-" .. toolset .. "-" .. runtime
    end

    local function _prebuilt_asset(package)
        local windows_asset = _windows_prebuilt_asset(package)
        if windows_asset then
            return windows_asset
        end
        if package:is_plat("windows", "mingw") then
            return
        end

        local assets = {
            ["linux-x64"] = "linux-x86_64",
            ["windows-x86_64"] = "windows-x64",
            ["wasm-wasm32"] = "wasm-wasm32"
        }
        local key = package:plat() .. "-" .. package:arch()
        return assets[key] or key
    end

    on_load(function (package)
        if package:version():ge("0.7.2") then
            local version = tostring(package:version())
            local asset = _prebuilt_asset(package)
            if asset then
                local prebuilt
                if package:version():ge("0.8.4") then
                    prebuilt = {
                        ["android-arm64-v8a"] = "3840a16b088f86665efdeb19f6e88802a276c3fea6f98fed5198ac0880ea547c",
                        ["android-armeabi-v7a"] = "ff7c5c6c7408edcddd085cc47726da058e9cce6865e63a078bc0520b8e944c0b",
                        ["android-x86_64"] = "a4d4f9c878ac0f46b6fc803cffc59c752876601b3ebe09426783888cc992ee6f",
                        ["linux-arm64"] = "6a2fa8d464a63bc7f0b5582c74302684ae542638aa3b6bd5d08e74dc0eb06993",
                        ["linux-x86"] = "a7157f22dd889dfce9f86bb509a634ed184da349e1eb0c036d1ac9ba6b2e79ce",
                        ["linux-i386"] = "a7157f22dd889dfce9f86bb509a634ed184da349e1eb0c036d1ac9ba6b2e79ce",
                        ["linux-x64"] = "0577c570da0845914a06cd2541308185a051b0a244876002d02ec9e000f59793",
                        ["linux-x86_64"] = "0577c570da0845914a06cd2541308185a051b0a244876002d02ec9e000f59793",
                        ["macosx-arm64"] = "5d50ab4889e736d776559ca8d83c8bbe965a0393d33e75d3549bbb48d5676186",
                        ["wasm-wasm32"] = "282fe19a4a552cde6fcaae7c1b2a552f3bd8c7bbf1591f693735bd318172df0e",
                        ["windows-x64-msvc-14.29-md"] = "ed90208b09d430465ea7995592faf09cb2cbece7a3e4d74152cebb0615a9d45b",
                        ["windows-x64-msvc-14.29-mt"] = "26689181967623c7bb4872272b6c2eccc2512356c0cd587bdb3c7a9c750d28ac",
                        ["windows-x64-msvc-latest-md"] = "253972b3ce2b515ecd8ed275fd5326b76521a4a3bd7197c2180d77c3c27bb51e",
                        ["windows-x64-msvc-latest-mt"] = "85a6b6ef065af5d2671ed170470f9ef5e7fdbc54161ed67ba953901829614e5a"
                    }
                elseif package:version():ge("0.8.3") then
                    prebuilt = {
                        ["android-arm64-v8a"] = "d826930746d762331baef188795934b209ebc2c4d98b671da6d63898228a1d36",
                        ["android-armeabi-v7a"] = "aeab8bc578a136f66367d3b678fba072e32c5b629bb40b856a3768b4d32a692c",
                        ["android-x86_64"] = "b6e335c2c1b8a5f1ce7b28209fe6cfc10f5f64fadb4615afc61a8a3f5c4cffea",
                        ["linux-arm64"] = "eeef60702509b1c5e7d671bff10b74816ee3ee47681c45749959523b3f158552",
                        ["linux-x86"] = "39be4a1e4e9b47539f9661fa7bfe06858eb5bb3c8cc1b271edc66c600a33c5b8",
                        ["linux-i386"] = "39be4a1e4e9b47539f9661fa7bfe06858eb5bb3c8cc1b271edc66c600a33c5b8",
                        ["linux-x64"] = "5552a8fafd6ce3a1b3d527aa5ad4974bd1e51a812e804318fbb18d972972d918",
                        ["linux-x86_64"] = "5552a8fafd6ce3a1b3d527aa5ad4974bd1e51a812e804318fbb18d972972d918",
                        ["macosx-arm64"] = "f79af0fa73d29da7bcbcd37957cbd5600f61027cd6c79a0ec2dc04b1c196e71a",
                        ["wasm-wasm32"] = "45ff1bc171fa1679cd38aad29b248975d2a6468eea0b32115e79f432ab783195",
                        ["windows-x64-msvc-14.29-md"] = "2110834ac251140f2afeb0a75d53faf101af9de5a25c04f92091b69e75f17f58",
                        ["windows-x64-msvc-14.29-mt"] = "3df886d261fc52b8af96926c5f2e0df303d573ee2f5c2631239cb42ab8ef2542",
                        ["windows-x64-msvc-latest-md"] = "bc40a4e9b5847ed61ef18a7b0331cc6a7247eefa218d8cf2e224509674578d86",
                        ["windows-x64-msvc-latest-mt"] = "0095f59566b76e8c2c33e0b7ba10d34b7ff40cb4f0feef5938c61f2ad6d4a258"
                    }
                elseif package:version():ge("0.8.0") then
                    prebuilt = {
                        ["android-arm64-v8a"] = "3a5f5ed0582da3daf6e7f4d80291c54584235a1cc9a9e54cd2f483c439856844",
                        ["android-armeabi-v7a"] = "cbd7bdd6d5a51236599decb52e8eecbd6f02cbc2f29404e5666a51cd12c6b2ac",
                        ["android-x86_64"] = "ef6f589008a72e53c89953dff33f954f8950de074f8b97de1a44ad83e882f38f",
                        ["linux-arm64"] = "d99976e1e34851faea6f3193c0106894bb37a73be8d4b9d42d25d18a0f576218",
                        ["linux-x86"] = "5dc44b4ad35af20ea900c0615a96ad2a5e837d38b748fa58dbf535cc61407acb",
                        ["linux-i386"] = "5dc44b4ad35af20ea900c0615a96ad2a5e837d38b748fa58dbf535cc61407acb",
                        ["linux-x64"] = "936ecb003c482490cc05191da3f745875e16786477d79d6c7bb18c6057670cd6",
                        ["linux-x86_64"] = "936ecb003c482490cc05191da3f745875e16786477d79d6c7bb18c6057670cd6",
                        ["macosx-arm64"] = "04c11326ee06adcff019042bd15125337474f99f99d8c82d6cf1583b373fe3b0",
                        ["wasm-wasm32"] = "0b92eab22415335ce46e86c8cab4ca9e19ea5b239b6c5201a28a05aa71093f70",
                        ["windows-x64"] = "c9b1773dad2c2a4ea610840171843f7f9cc4e6e51034f44833264c4a2236b796",
                        ["windows-x86_64"] = "c9b1773dad2c2a4ea610840171843f7f9cc4e6e51034f44833264c4a2236b796",
                        ["mingw-x64"] = "c9b1773dad2c2a4ea610840171843f7f9cc4e6e51034f44833264c4a2236b796",
                        ["mingw-x86_64"] = "c9b1773dad2c2a4ea610840171843f7f9cc4e6e51034f44833264c4a2236b796"
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
                local sha = prebuilt[asset]
                assert(sha, "package(vshadersystem): unsupported prebuilt target: " .. asset)
                package:set("urls", "https://github.com/zzxzzk115/vshadersystem/releases/download/$(version)/vshadersystem-prebuilt-$(version)-" .. asset .. ".zip")
                package:add("versions", version, sha)
            end
            package:add("links", "vshadersystem", "spirv-tools", "tint")
            local dep_configs = {debug = false}
            if package:is_plat("windows") and package:runtimes() then
                dep_configs.runtimes = package:runtimes()
            end
            package:add("deps", "spirv-cross vulkan-sdk-1.4.335", {configs = dep_configs, system = false, public = true})
            package:add("deps", "glslang 1.4.335+0", {configs = dep_configs, system = false, public = true})
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
        local asset = _prebuilt_asset(package)
        if package:version():ge("0.7.2") and asset then
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
            if package:is_plat("windows") and package:runtimes() then
                configs.runtimes = package:runtimes()
            end
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
