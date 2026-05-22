package("vshadersystem")
    set_homepage("https://github.com/zzxzzk115/vshadersystem")
    set_description("vshadersystem is a standalone shader compilation and material reflection pipeline.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/vshadersystem/archive/refs/tags/$(version).tar.gz", {alias = "source"})
    add_urls("https://github.com/zzxzzk115/vshadersystem.git", {alias = "git"})

    add_versions("source:v0.8.3", "62d6dc48d483dc9a91fb8d71211e5e2d63b39be9e4856dbea36bf46fe322618d")
    add_versions("source:v0.8.2", "b449a24d364a5c4b15b8cbb53144abf14723bb863b2cd330b99273d26cddb4db")
    add_versions("source:v0.7.2", "a6e268d2cbc770e6ed8ffc8c554a9898db54ff7e2b045ee0af595286bce925fb")
    add_versions("source:v0.6.2", "73a381c343f856030574cc787f7e30d4d6e020db26cef40413ba7f6fd7170560")
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
        local toolset = "latest"
        local msvc = package:toolchain("msvc")
        local vs_toolset = msvc and msvc:config("vs_toolset")
        if vs_toolset and vs_toolset:startswith("14.29") then
            toolset = "14.29"
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
                if package:version():ge("0.8.3") then
                    prebuilt = {
                        ["android-arm64-v8a"] = "205461044b63b935a0c5e46473aff9876aef8d21c4c956bbcc47f58260e0060f",
                        ["android-armeabi-v7a"] = "13c859fb2b9e29d84a05566448510ec4b6422953e4ef3050258b6bfccbfe92ed",
                        ["android-x86_64"] = "9653d716ee7f2626a3acab0a55fdae802d86c31d342203170c5a61af878626b8",
                        ["linux-arm64"] = "e88e8010097165cf42f1975cf11923009c0ca2283f3587bf596995f38066070d",
                        ["linux-x86"] = "23fa9559053b72b0abf108f3b1ed70481cb779b10e3aae674146aa796e7186e1",
                        ["linux-i386"] = "23fa9559053b72b0abf108f3b1ed70481cb779b10e3aae674146aa796e7186e1",
                        ["linux-x64"] = "bc4e122b6def1020372afe4eb6f54f4eab46b02a6ee88addb86166d159be81fb",
                        ["linux-x86_64"] = "bc4e122b6def1020372afe4eb6f54f4eab46b02a6ee88addb86166d159be81fb",
                        ["macosx-arm64"] = "31e01ca09456d0b793abbfc23e9027cfc94cf9b780349c39a65e9852d4fa7fc9",
                        ["wasm-wasm32"] = "a517a75853f0d2f49527d661cef68155a1fb081033058571df6c9826c0bb29a4",
                        ["windows-x64-msvc-14.29-md"] = "2f1889f2b7f6a46c6aaae39bebe86fc9e2ad90b5e399f4871c5152e81b94dbc3",
                        ["windows-x64-msvc-14.29-mt"] = "61b24bfbb36f7495a37da108c9dd4fe3b9d7e521e6f755a4a6dc4fe41223b256",
                        ["windows-x64-msvc-latest-md"] = "5446e58b0083f62b6976d8f151e2a4f1ea4f3994a2983fb055d860ea500a8e83",
                        ["windows-x64-msvc-latest-mt"] = "357c7fb204784f4d9c64f0ef311bda71db94857b8f047d66497817f1732e107d"
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
