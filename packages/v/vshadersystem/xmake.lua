package("vshadersystem")
    set_homepage("https://github.com/zzxzzk115/vshadersystem")
    set_description("vshadersystem is a standalone shader compilation and material reflection pipeline.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/vshadersystem/archive/refs/tags/$(version).tar.gz", {alias = "source"})
    add_urls("https://github.com/zzxzzk115/vshadersystem.git", {alias = "git"})

    -- Only the current line (v1.0.x, Slang) and the last v0.x (v0.11.3) are kept; older
    -- releases were pruned to keep this package maintainable.
    add_versions("source:v1.2.0", "0ddfd958fe0a22f2a146c85e164919d14603dadab5dd643a801c5395eb605c27")
    add_versions("source:v1.1.0", "c9bfb7404cb0981249299c2d737a2bd847b8b96f0b84cd0a3ccfa378aa0318c5")
    add_versions("source:v1.0.1", "dae7d84a50ce7e655bb312c981cc48e633d6a6a5c80f401ac76b0e09dfdefaf4")
    add_versions("source:v1.0.0", "f6951fa34e2f8dab62d7a17dfcd58aed1f4b4ae015a107bbee4de39833c32f15")
    add_versions("source:v0.11.3", "b899ef123964aa15a99440d5cbf32671081bc647bfb3c3c52ebd2eeda65ff779")
    add_versions("git:v1.2.0", "v1.2.0")
    add_versions("git:v1.1.0", "v1.1.0")
    add_versions("git:v1.0.1", "v1.0.1")
    add_versions("git:v1.0.0", "v1.0.0")
    add_versions("git:v0.11.3", "v0.11.3")

    -- Expose vshaderc-lib (the offline Slang compile library behind the vshaderc CLI) so consumers
    -- can compile shaders in-process instead of shelling out -- e.g. an asset importer. v1.0.0+ only
    -- (the build API the CLI uses); pulls the Slang runtime, hence opt-in.
    add_configs("vshaderc_lib", {description = "Link vshaderc-lib for in-process Slang shader compilation.", default = false, type = "boolean"})

    -- Lowest full MSVC toolset version the "latest" prebuilt is link-compatible with.
    -- The "latest" release artifact is built on the windows-latest runner with an
    -- *unpinned* MSVC (ilammy/msvc-dev-cmd picks the newest installed toolset), so its
    -- objects reference whatever __std_* vectorized STL helpers that toolset emits.
    -- Those symbols are additive: a consumer can only link it when its own STL static
    -- lib (libcpmt.lib / msvcprt.lib) is >= the producer toolset. Matching on the
    -- "14.44" major.minor prefix alone is unsafe because a 14.44 GA install (e.g.
    -- 14.44.35207, _MSVC_STL_UPDATE 202503L) lacks symbols like __std_replace_copy_2
    -- that the newer producer toolset relies on. Keep this in sync with the toolset
    -- the latest prebuilt was actually compiled with (see release_prebuilt.yaml CI log).
    local LATEST_PREBUILT_FLOOR = "14.51.36231"

    -- numeric ">=" over dotted version strings ("14.44.35207" vs "14.51.36231")
    local function _toolset_ge(v, floor)
        local function parse(s)
            local t = {}
            for n in s:gmatch("%d+") do
                t[#t + 1] = tonumber(n)
            end
            return t
        end
        local a, b = parse(v), parse(floor)
        for i = 1, math.max(#a, #b) do
            local x, y = a[i] or 0, b[i] or 0
            if x ~= y then
                return x > y
            end
        end
        return true
    end

    local function _windows_prebuilt_asset(package)
        if not package:is_plat("windows") or not package:is_arch("x64", "x86_64") then
            return
        end
        if package:debug() or package:has_runtime("MDd", "MTd") then
            return
        end

        local msvc = package:toolchain("msvc")
        local vs_toolset = msvc and msvc:config("vs_toolset")
        if not vs_toolset then
            return
        end

        local runtime = package:has_runtime("MT") and "mt" or "md"
        local toolset
        if vs_toolset:startswith("14.29") then
            -- pinned 14.29 prebuilt (CI builds this with toolset 14.29 explicitly)
            toolset = "14.29"
        elseif vs_toolset:startswith("14.44") then
            -- pinned 14.44 prebuilt (CI builds this with toolset 14.44, i.e. the
            -- 14.44.35207 GA STL). All 14.44.x patches share the same STL symbol
            -- floor, so a prefix match is safe here.
            toolset = "14.44"
        elseif _toolset_ge(vs_toolset, LATEST_PREBUILT_FLOOR) then
            toolset = "latest"
        else
            -- Toolset older than the "latest" prebuilt's: linking it would fail with
            -- unresolved __std_* externs. Do not fall back to an older/mismatched MSVC
            -- prebuilt either -- vshadersystem exposes STL-heavy reflection data, so
            -- mixing toolsets can crash in release. Fall through to a source build.
            return
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
        local version = tostring(package:version())
        local asset = _prebuilt_asset(package)
        if asset then
            local prebuilt
            if package:version():ge("1.2.0") then
                prebuilt = {
                    ["android-arm64-v8a"] = "1353258cc5f45af7b1c56d3368eb0d84c0fa8db0c4ff81515f7c76bdce9dea20",
                    ["android-armeabi-v7a"] = "c79d5e06cd4aa3d996934a4cbf5499fd3cc22720987c720627d1a96376a8a7c1",
                    ["android-x86_64"] = "5f16b37d2e0ed5c0aa63715d5e57cf0e62545844759732e3eee768c2ace5450b",
                    ["linux-arm64"] = "ab2a061df6481ddf8499a76dbb85b5acc8e14553f6c81efd4cf2234ea0ff410b",
                    ["linux-x86"] = "a20494c629bc6ff8852a6b30864fa3354d5ea51bcb89fe5cd9345c821c0c5083",
                    ["linux-i386"] = "a20494c629bc6ff8852a6b30864fa3354d5ea51bcb89fe5cd9345c821c0c5083",
                    ["linux-x64"] = "3fa542ac7ce280cead908ad87329449d82edd5c147b5ff73b52b828418f9b213",
                    ["linux-x86_64"] = "3fa542ac7ce280cead908ad87329449d82edd5c147b5ff73b52b828418f9b213",
                    ["macosx-arm64"] = "d606be8c21f8fb5d0232fa8d638e636963df9ca8b58999d734a4589a0602b5ff",
                    ["wasm-wasm32"] = "e4be00ab136ae2a496a0f251a98346f131f44523939c8a527d36f346c207fdca",
                    ["windows-x64-msvc-14.29-md"] = "ff63e683f0e35b49a10221cbb419285892c869adf3d0f9518ff6c1e6d2d9e298",
                    ["windows-x64-msvc-14.29-mt"] = "51b27ef95c29c04c4f0f55235e33199ea738fce35869070b9145f9721480528c",
                    ["windows-x64-msvc-14.44-md"] = "80fbc9f5796a5483bc22e43f263c631e8f97f7c32b24cedf1afa26530415a894",
                    ["windows-x64-msvc-14.44-mt"] = "28df0a6774ec46bd99bf551bab969cc9e22db430afe8364a26e0fbc513125632",
                    ["windows-x64-msvc-latest-md"] = "0ffb9ae8e997f5e553139e1c70030239a170ec2767443c4ba4a5c56c6ec6c0ad",
                    ["windows-x64-msvc-latest-mt"] = "0bbcb389950a7fe6be29f500059b3bf42087c1c8cf72b9fcb6bd0b7f342505f7"
                }
            elseif package:version():ge("1.1.0") then
                prebuilt = {
                    ["android-arm64-v8a"] = "4f7268314d6c5c688dc8ee7a2399b6100ed60bd64f654f745ad90be4eed52616",
                    ["android-armeabi-v7a"] = "dbc3abac51db94cb8d590be4d2439d4a5f57109a61a31e5ae256606dd1d9d359",
                    ["android-x86_64"] = "aa4524c070892647ceefe423d13d1bbef9b93aadc2307716a98bd6abec397a6f",
                    ["linux-arm64"] = "ad463e48ac9a89b5f0cc191df0256c1fcab4f014dfc47e0a16991ce053ced33a",
                    ["linux-x86"] = "850e5baa2110fa129d5a9caa587d3d8f391792ea321b8b5ecdeda596f151c2ca",
                    ["linux-i386"] = "850e5baa2110fa129d5a9caa587d3d8f391792ea321b8b5ecdeda596f151c2ca",
                    ["linux-x64"] = "8e7b1be2db19d0cdc13d56022ae29be58dd70fc7728611148d6c30687568eee1",
                    ["linux-x86_64"] = "8e7b1be2db19d0cdc13d56022ae29be58dd70fc7728611148d6c30687568eee1",
                    ["macosx-arm64"] = "f29d2bbcccc04e718d93f1967218fb8d51648996231abae1f438a89277b20d80",
                    ["wasm-wasm32"] = "6475eae4320fe57cfd470e03a4eb7d3db818c1e9b604ed9c9ecf68c418465159",
                    ["windows-x64-msvc-14.29-md"] = "8ae2a35ea0da22103b58eef5c325cedc9a1384abe789d9e59b0433abb5c59ead",
                    ["windows-x64-msvc-14.29-mt"] = "b2157673b3c894007e62a523f558b938fcb7be83b9767b8860214b5f3dc47d55",
                    ["windows-x64-msvc-14.44-md"] = "8d639f243a9b332728cb5d02484faa9ee703660c244c5f52cbffbbe0423b95a0",
                    ["windows-x64-msvc-14.44-mt"] = "6ba48e109bd80b8bc6454d51ef75e9c533a743ee2144532fdcbd1eb5f7c96bd5",
                    ["windows-x64-msvc-latest-md"] = "f9d923b3eec5737ed9e79c0f4843059a8add7bfcc84d3458e2c6e0c13917962d",
                    ["windows-x64-msvc-latest-mt"] = "f42506651418f7eacc636eacbaaa4b69448f696791e731a07edd7fc179943936"
                }
            elseif package:version():ge("1.0.1") then
                prebuilt = {
                    ["android-arm64-v8a"] = "ecc0d6b2621775c1df65c5f3f550d83eeb45424bc8d336c57d6fde1e433aae9c",
                    ["android-armeabi-v7a"] = "8da9700a2c56ad6d68b26dd5b106034bd14ff607ff56ded4ff40783670f77d24",
                    ["android-x86_64"] = "44e790b35d46650dbe14b597931f7b465bc7bb01f82da5d94de99362510fb111",
                    ["linux-arm64"] = "5931d8949943005c2d411df27dd834d99f24d31b3a94d87ed8dc002374846e35",
                    ["linux-x86"] = "47de4ea4e4d2bf46fe12ecfb4dd4af68097ef6f8edc39cb71c4b08f1de4d4d2c",
                    ["linux-i386"] = "47de4ea4e4d2bf46fe12ecfb4dd4af68097ef6f8edc39cb71c4b08f1de4d4d2c",
                    ["linux-x64"] = "01b606000c52a67fd2a09adb6e76b548ed5fa3ec6aa53ba7b2754aed3d6d185a",
                    ["linux-x86_64"] = "01b606000c52a67fd2a09adb6e76b548ed5fa3ec6aa53ba7b2754aed3d6d185a",
                    ["macosx-arm64"] = "a276a07a090eaa1ab0b4242f5ac8ebc3c5550303e92a98986352b0ad77196e29",
                    ["wasm-wasm32"] = "2f36161bbbe792555f302daa393ac1dbea8c28a7af3bcc20eef43dccfd560da0",
                    ["windows-x64-msvc-14.29-md"] = "0b5ad08fb2b43e1ba94100ed3bece77f2d9eb9838f3b4e441339602dd16b0528",
                    ["windows-x64-msvc-14.29-mt"] = "f06102a7707c7522b35e76219f5f1b66bb9cefa6e12725e1668680897e06b18d",
                    ["windows-x64-msvc-14.44-md"] = "0ee2827749fb1a2510e7593fe7d51f1744698deebc450f5a07d662fc141a78fa",
                    ["windows-x64-msvc-14.44-mt"] = "2f8e97c69ea1ba476ae56fb8fd2cc28fc91db40ae8f0361d044d897a23cf69d8",
                    ["windows-x64-msvc-latest-md"] = "996e91782c75e1f6bb31eaf2710664fb848d7f2b8f926e4c89c80dd5974503fc",
                    ["windows-x64-msvc-latest-mt"] = "b29d63c7fe5ef886fccef45e9b767e4ec1b00e2b850a68e487faf503d5437e99"
                }
            elseif package:version():ge("1.0.0") then
                prebuilt = {
                    ["android-arm64-v8a"] = "96ee80f0363c2e58d58c36c734ad08b8b91e1fb8b67a4161644034861c4fdbd0",
                    ["android-armeabi-v7a"] = "5000888191ca77f111bf9714d657b038fb50c63c70e11195307a8e306c1ce052",
                    ["android-x86_64"] = "32145a3f069253cbd0e4452ef4b2ece08a85dd5b143b5cd2e1fb0da8b3105ec5",
                    ["linux-arm64"] = "d1bb8d9aca3d918c791231cd7405862697662a000091627e7fe096c581278776",
                    ["linux-x86"] = "4ebe121e8ffc786a1b86c38a7e2c4ec723d48ed9147f7bee30a069f3e20d80b0",
                    ["linux-i386"] = "4ebe121e8ffc786a1b86c38a7e2c4ec723d48ed9147f7bee30a069f3e20d80b0",
                    ["linux-x64"] = "1c48c1ea1490764b248a27df734a9d64d60269270a254a081a34fa509b34e00a",
                    ["linux-x86_64"] = "1c48c1ea1490764b248a27df734a9d64d60269270a254a081a34fa509b34e00a",
                    ["macosx-arm64"] = "e814884097bc3b28ca862cd3c97066c0f05a5d5ab6da394f7b210b25d2662cac",
                    ["wasm-wasm32"] = "bfda616ccb971a06eb7d12face629b296b87bb0511b5effb46f71c1a400a0e2b",
                    ["windows-x64-msvc-14.29-md"] = "8c251656a2d862a9a2175096a4f39ef2c3c8b89c733a714ad856cf856ae2a1c7",
                    ["windows-x64-msvc-14.29-mt"] = "8d1d8d4b5dd245fae34c978357ecfbcfdc210940a1a6ad637dab2a33336860b0",
                    ["windows-x64-msvc-14.44-md"] = "b61f939325b6776c671e9fad81f0780aac6049852383d60e27a78025a130fcd7",
                    ["windows-x64-msvc-14.44-mt"] = "254a279b745925a60a706acf6c299f721c90179a0e751e77b2671209285f0b33",
                    ["windows-x64-msvc-latest-md"] = "3ad5d363ab70b7d4db18fb6ce0f046ad59e6e0f418a123d5e9fa587664d94d37",
                    ["windows-x64-msvc-latest-mt"] = "4629f6e43daf478d1759c46d0349f48d4edc6c5e6ca331427f77fd166e40bb17"
                }
            else
                -- v0.11.3
                prebuilt = {
                    ["android-arm64-v8a"] = "054a589139626b50ea9a40fca9562fad8e922d72686c4b81e30f3d9e2ad48b0f",
                    ["android-armeabi-v7a"] = "5061e3a75b0981ba59ad6be5420f7e9abde3554998980d91827c744cb82ad746",
                    ["android-x86_64"] = "ef6603221f3ad38328ead8b4dff4a5f864871acdcd4790e370f0034f123fa9b3",
                    ["linux-arm64"] = "4c1981d9d922079e9a644ab608021b61574ea473c327c773a5b248e37cfa325a",
                    ["linux-x86"] = "c9638a9bebf09584429da5afcec1facc1e31189df7afc39117d1158cdef5724c",
                    ["linux-i386"] = "c9638a9bebf09584429da5afcec1facc1e31189df7afc39117d1158cdef5724c",
                    ["linux-x64"] = "f603d5bf9270e5a5cb9ab7703b37758b85115ea38c96270b826aeff846905aaa",
                    ["linux-x86_64"] = "f603d5bf9270e5a5cb9ab7703b37758b85115ea38c96270b826aeff846905aaa",
                    ["macosx-arm64"] = "110c889262964b77f3d074ee10b1867cc1e49dbde0bc9a170faf87dcfa03213f",
                    ["wasm-wasm32"] = "6856dbe0432d636fbcde8b853372ff3c16c1eca7468ec22790c2a093e6b361de",
                    ["windows-x64-msvc-14.29-md"] = "35cc9abbfc177a81535e6cf77d306de32ca5ace216681a7c1a294fe1878b614d",
                    ["windows-x64-msvc-14.29-mt"] = "8d663d36255a08075db96a294c0deb77e907c439f51d67b6aa2cdcd7e44a2c3b",
                    ["windows-x64-msvc-14.44-md"] = "06cf475cd19c79ef1bc0a70a49249adf77cbedc17c28ac57c25baf175e1c311d",
                    ["windows-x64-msvc-14.44-mt"] = "4ca91581f8dce76ee1ea14c7703aaede1f9b5646d9efd378149118970b7089a7",
                    ["windows-x64-msvc-latest-md"] = "69d6bc9a71333c8e1d95142e090a34c4597fbdb6d43b8a567bd0ffe9a7ebaccb",
                    ["windows-x64-msvc-latest-mt"] = "4ca9adb0511cae52a14828e5492ec019788cc664508deaabd6d0807ca2f00430"
                }
            end
            local sha = prebuilt[asset]
            assert(sha, "package(vshadersystem): unsupported prebuilt target: " .. asset)
            package:set("urls", "https://github.com/zzxzzk115/vshadersystem/releases/download/$(version)/vshadersystem-prebuilt-$(version)-" .. asset .. ".zip")
            package:add("versions", version, sha)
        end
        -- naga (SPIR-V->WGSL) is a host-only cook dep statically linked into the vshaderc tool
        -- and referenced only by wgsl.cpp, which the runtime/Vulkan consumer (e.g. libvultra)
        -- never pulls. So consumers link only vshadersystem here.
        -- Offline Slang compile lib (vshaderc-lib) for in-process shader compilation. Listed before
        -- vshadersystem (it depends on the runtime lib). The lib + vshaderc/ headers are already
        -- installed; this just links them + the Slang SDK. v1.0.0+ only.
        if package:config("vshaderc_lib") and package:version():ge("1.0.0") then
            package:add("links", "vshaderc-lib")
            package:add("deps", "slang-prebuilt 2026.11", {public = true})
        end
        package:add("links", "vshadersystem")
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
        package:addenv("PATH", "bin")
    end)

    on_install(function (package)
        local asset = _prebuilt_asset(package)
        if asset then
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

        -- With vshaderc_lib, bundle the Slang runtime (DLLs/.dylib/.so + standard modules) into THIS
        -- package's bin, so it ships inside the consumer-visible vshadersystem package. slang-prebuilt
        -- is otherwise a package-of-a-package and invisible to consumers, so they could neither find
        -- nor deploy the Slang shared libs the linked vshaderc-lib needs at runtime. Consumers then
        -- copy this bin next to their exe (+ @rpath/$ORIGIN) -- see the vshadersystem examples.
        if package:config("vshaderc_lib") and package:version():ge("1.0.0") then
            local slang = package:dep("slang-prebuilt")
            if slang and slang:installdir() then
                local sdir   = slang:installdir()
                local bindir = package:installdir("bin")
                os.mkdir(bindir)
                for _, f in ipairs(os.files(path.join(sdir, "bin", "*"))) do os.trycp(f, bindir) end
                for _, d in ipairs(os.dirs(path.join(sdir, "bin", "*"))) do os.trycp(d, bindir) end
                for _, so in ipairs(os.files(path.join(sdir, "lib", "*.so*"))) do os.trycp(so, bindir) end
                for _, dy in ipairs(os.files(path.join(sdir, "lib", "*.dylib"))) do os.trycp(dy, bindir) end
            end
        end
    end)

    on_test(function (package)
        -- v1.0.0 moved the consumer-facing runtime API to vsh_format.hpp; the old
        -- system.hpp/compiler.hpp/build_single_shader API is gone. Desktop hosts still ship
        -- the vshaderc CLI; cross/Android/WASM are runtime-loader-only.
        if package:version():ge("1.0.0") then
            if not package:is_cross() and not package:is_plat("android", "wasm") then
                os.vrun("vshaderc --help")
            end
            -- The ~host cook tool is a binary package (vshaderc only, no consumer headers); only the
            -- library packages ship vsh_format.hpp. Asserting it on the binary host tool wrongly fails
            -- cross builds (e.g. WASM pulling vshadersystem~host), so skip the header check there --
            -- mirroring the v0.x branch below, which early-returns for is_cross()/is_binary().
            if not package:is_binary() then
                assert(package:has_cxxincludes("vshadersystem/vsh_format.hpp", {configs = {languages = "c++23"}}))
            end
            return
        end
        if not package:is_cross() then
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
                    req.id = "test/probe";

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
