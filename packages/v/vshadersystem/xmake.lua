package("vshadersystem")
    set_homepage("https://github.com/zzxzzk115/vshadersystem")
    set_description("vshadersystem is a standalone shader compilation and material reflection pipeline.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/vshadersystem/archive/refs/tags/$(version).tar.gz", {alias = "source"})
    add_urls("https://github.com/zzxzzk115/vshadersystem.git", {alias = "git"})

    add_versions("source:v0.11.0", "a1f71250cc0abf06bd26ded0c120ffd9db541d5ab1e70a7d838f2c095a96cca4")
    add_versions("source:v0.10.2", "12da825bbc7aaeb60831f8709f6b131197aaf45a4b65e5eed7861bc9b886993f")
    add_versions("source:v0.10.1", "cbf3dadea0179a367165c42075b5d526427c229f4e5e4958f7fe7eaa16eac291")
    add_versions("source:v0.10.0", "4b1215e439d59a7c27aa5d12dd0e7e4181e8e3fee63dd31829bc7447970b5f54")
    add_versions("source:v0.9.3", "c1f7b7cfc9c7eb3e0b8a566087ff0d9209230e09fb9eb78c2ba60f1528267a38")
    add_versions("source:v0.9.2", "7c7ed36ca82a665d478f1b89b335becf87362bb0f03ceacac4c4f2fa64216cfc")
    add_versions("source:v0.9.1", "ec426ba25083b97093a1045196f189ba453582b468484ffaacecf18ba4a4a708")
    add_versions("source:v0.9.0", "b83e62a29db8e6b9b20640a51c1874f4bdab976d7fe6aca3fed1e15e2d66d4a9")
    add_versions("source:v0.8.4", "4916c6957069cb92c57e89f5748f8c345eef4d58795e8f96aa8e284aa2a00387")
    add_versions("source:v0.8.3", "e7b561234f1cc7a5d8048684baaa5f4f74ece3fbd3d0b96da6c8a77d1e1c84d2")
    add_versions("source:v0.8.2", "b449a24d364a5c4b15b8cbb53144abf14723bb863b2cd330b99273d26cddb4db")
    add_versions("source:v0.7.2", "a6e268d2cbc770e6ed8ffc8c554a9898db54ff7e2b045ee0af595286bce925fb")
    add_versions("source:v0.6.2", "73a381c343f856030574cc787f7e30d4d6e020db26cef40413ba7f6fd7170560")
    add_versions("git:v0.11.0", "v0.11.0")
    add_versions("git:v0.10.2", "v0.10.2")
    add_versions("git:v0.10.1", "v0.10.1")
    add_versions("git:v0.10.0", "v0.10.0")
    add_versions("git:v0.9.3", "v0.9.3")
    add_versions("git:v0.9.2", "v0.9.2")
    add_versions("git:v0.9.1", "v0.9.1")
    add_versions("git:v0.9.0", "v0.9.0")
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

        local msvc = package:toolchain("msvc")
        local vs_toolset = msvc and msvc:config("vs_toolset")
        if not vs_toolset then
            return
        end

        local runtime = package:has_runtime("MT") and "mt" or "md"
        local toolset
        if vs_toolset:startswith("14.29") then
            toolset = "14.29"
        elseif vs_toolset:startswith("14.44") then
            toolset = "latest"
        else
            -- Do not fall back to an older MSVC prebuilt. vshadersystem exposes
            -- STL-heavy reflection data, so mixing toolsets can crash in release.
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
        if package:version():ge("0.7.2") then
            local version = tostring(package:version())
            local asset = _prebuilt_asset(package)
            if asset then
                local prebuilt
                if package:version():ge("0.11.0") then
                    prebuilt = {
                        ["android-arm64-v8a"] = "1b24b2438206cc042dcc189266cc8ddd0f8ac67531c91e38542a91ff1e639c62",
                        ["android-armeabi-v7a"] = "bf7fd1c3e089b793b13337185e97f6a5a253cf786b53830dd40b14a9646b6212",
                        ["android-x86_64"] = "3685cbd6abde385b2381075e71224ba5093fd0b0613f804e0a6c832795faa362",
                        ["linux-arm64"] = "d5dc88a3a5413f391d3da9e798972d11ee65eff4fc179ce9c6918509c06e771e",
                        ["linux-x86"] = "125a6a7584668a9a4b7506c9efaa1df4dca605e396be2d95e30a8d09f0781c83",
                        ["linux-i386"] = "125a6a7584668a9a4b7506c9efaa1df4dca605e396be2d95e30a8d09f0781c83",
                        ["linux-x64"] = "7c0ce671ae90ef2d480e931bde765be46be58bcd08d91648242fcd3998df4523",
                        ["linux-x86_64"] = "7c0ce671ae90ef2d480e931bde765be46be58bcd08d91648242fcd3998df4523",
                        ["macosx-arm64"] = "66688711f4f7039c5d7eed91525c1ecce2278d504fd5fd22c59e66e393ff94f0",
                        ["wasm-wasm32"] = "0b76331071ea462630101223a27a0f5f88562e19e8f36b14c82756e5bb444ea9",
                        ["windows-x64-msvc-14.29-md"] = "101e40101673bcb9a95a1b26599b09d9c46a2e3a495e2d9634b9d364ecfda963",
                        ["windows-x64-msvc-14.29-mt"] = "c1bce8c4867cc5b9055c25b11482e6737e180644f8cdaf4555c333c3ff5ed3fb",
                        ["windows-x64-msvc-latest-md"] = "0b3f80561f4ea046510f2f2b6e556c0c441e2a31a9be9ab19ac6e95bd61cb6ac",
                        ["windows-x64-msvc-latest-mt"] = "7490224218282f8f757f5f03d7a27d0020711cf4d8335a51f59d2358bd98c747"
                    }
                elseif package:version():ge("0.10.2") then
                    prebuilt = {
                        ["android-arm64-v8a"] = "a975ad5eaa9db2ea8bc6f102bd8292082611d6be82cca52333b643166a6adc22",
                        ["android-armeabi-v7a"] = "c6371c8e7e053ba9fda7b646c5408a4d3dd75c1141bd838f1015ea54a972cd9f",
                        ["android-x86_64"] = "b41e93528465eb5ec13a7ef1793cb5573f4db82443415abb7ae33a3f5f765715",
                        ["linux-arm64"] = "5caec1fc7c6a829fae148dd1ea5df2cb2e5d78ab47eef78b452b6e37dcd39b7b",
                        ["linux-x86"] = "463140ffa53fdb501de476b0e1fe63f8e4af0a5e720ffae50f0422cce5aebd15",
                        ["linux-i386"] = "463140ffa53fdb501de476b0e1fe63f8e4af0a5e720ffae50f0422cce5aebd15",
                        ["linux-x64"] = "149280ef5e775756aa7afc9d164832e398c7d996dfc6ef4bda4a5effca358c86",
                        ["linux-x86_64"] = "149280ef5e775756aa7afc9d164832e398c7d996dfc6ef4bda4a5effca358c86",
                        ["macosx-arm64"] = "061e7c484368009d97e6ead7806ae2151640ab1df739f031aa8673d605ff9c0b",
                        ["wasm-wasm32"] = "d4867dac0040bad41703498013050648a6134e27882b453d4b18da17cdf5e97e",
                        ["windows-x64-msvc-14.29-md"] = "c3a2eeb7b6c2fb5c3f3ab256d56752ecccd879820036e03862d0a8a445ba4855",
                        ["windows-x64-msvc-14.29-mt"] = "8518f1130623d6e550a963290336a6f3815c5488b293422593a612e26219836d",
                        ["windows-x64-msvc-latest-md"] = "38f12d179d87c9c2b0dec0a1882faa65d02fd618e17409807fbde772744e0e3c",
                        ["windows-x64-msvc-latest-mt"] = "1c23c12e648b045e0baeb47180979f57daa9bb036ef67aa653e0036dfbba68c1"
                    }
                elseif package:version():ge("0.10.1") then
                    prebuilt = {
                        ["android-arm64-v8a"] = "32ce934685c1f973774130af69564241e3fd346bc8a01bb4dbe1f466d8254fa2",
                        ["android-armeabi-v7a"] = "df93b1af2a03cfc51ada44762d5967c5f2a858350074fc3f5e7a60c599bddce7",
                        ["android-x86_64"] = "f07b35f2a2f41dd3d10ad5010390705c80a402ba996326454bd74a207d4129b5",
                        ["linux-arm64"] = "55c5b8b4c4d8ede360b673bfdcc724d9c1bd9fc54d3c6b2a33e7a57f47951c2b",
                        ["linux-x86"] = "7f36d9a08333d9086cec640b86615d9361a3db8fe2631f2a10e874b38f1c90c5",
                        ["linux-i386"] = "7f36d9a08333d9086cec640b86615d9361a3db8fe2631f2a10e874b38f1c90c5",
                        ["linux-x64"] = "11b06c4b6ece454a540e35b995d0d94264111e86cae007ac1f1ad85aea948195",
                        ["linux-x86_64"] = "11b06c4b6ece454a540e35b995d0d94264111e86cae007ac1f1ad85aea948195",
                        ["macosx-arm64"] = "e881451cf296f2c3633a2f3e0f32966e90f7ef06f79dcf305d51fce7258b3657",
                        ["wasm-wasm32"] = "e36972b794d44a99fd01e9ca59c4a0144212344fa2941b4e8d08aaa1b1c3930a",
                        ["windows-x64-msvc-14.29-md"] = "5afcff60d74fd17726097e63a8326b1688c1b21c344bbc1efceb7f7bef5bb178",
                        ["windows-x64-msvc-14.29-mt"] = "44f405a8bef1088a3e8b7667709c3e3446202783d72e3015c202af6617dcdabc",
                        ["windows-x64-msvc-latest-md"] = "2667275aa4fccbff81d5761265825de2494d99caefcfbc34e7cef3e529f39683",
                        ["windows-x64-msvc-latest-mt"] = "6444419c6c45cb9207b25fa2b291b9645cea9d13b826e0fbe2410c9356cf6c86"
                    }
                elseif package:version():ge("0.10.0") then
                    prebuilt = {
                        ["android-arm64-v8a"] = "4d81432adae4a0917b9171b1d9cf96d9b4aadcabad53930fa75883d501c0c1d9",
                        ["android-armeabi-v7a"] = "76cb46933e35ed7659ca5e9bd1e7e48665fcd8adb2fb883c3ecf8c42137fd2c1",
                        ["android-x86_64"] = "ccd31a0def74ce94822e6eabd511f18f843ff6300d353238006e2615dfaaab9b",
                        ["linux-arm64"] = "421fb6fc37e44682cd8c3d987b31177b443993439568730e8832c1a914ddec03",
                        ["linux-x86"] = "2c95458ddfe7cc95504bb25a3d84b801f75656165fb80e2be0a04c63ba37b633",
                        ["linux-i386"] = "2c95458ddfe7cc95504bb25a3d84b801f75656165fb80e2be0a04c63ba37b633",
                        ["linux-x64"] = "b505901dfa4fd12eeaf529c91b22d241666a939f4243aa112b26c2d39b2a13c8",
                        ["linux-x86_64"] = "b505901dfa4fd12eeaf529c91b22d241666a939f4243aa112b26c2d39b2a13c8",
                        ["macosx-arm64"] = "7ecf4c97584ad291c915938f6bf2c44427120962d6069d33d61763dfda153e73",
                        ["wasm-wasm32"] = "90808fa9f3b30986b28f1f6adaf6a13b1bc1979bb4efa7c2b81407896520471d",
                        ["windows-x64-msvc-14.29-md"] = "20f1ccf0f5b6970f0ec807a7767e1c738989f8d9cd77fd7f41e7238294fb64b2",
                        ["windows-x64-msvc-14.29-mt"] = "c567a52fd53fd911f9179e6e00053c706f14ef566c2366f0dd32aa343bba10e8",
                        ["windows-x64-msvc-latest-md"] = "30244cd5097a72e82f6480a60709625ae987af31c2b67f319eb73534a67cd443",
                        ["windows-x64-msvc-latest-mt"] = "a0adb01810d0827b72646a42d7f74502b53af5022c247dc8093a8e91ade90a07"
                    }
                elseif package:version():ge("0.9.3") then
                    prebuilt = {
                        ["android-arm64-v8a"] = "cb823ea08b119901f0379344772d21534726585b21d787a3df463eaecaab4218",
                        ["android-armeabi-v7a"] = "65db5d400c4587c04dad6db3d86e6c91bf6febc50e06cf5f7733629976c51e1c",
                        ["android-x86_64"] = "4a0c6fd38ff763359ecae201f2b29841b8c2bb64a06fb196fc70561f7960079a",
                        ["linux-arm64"] = "7d61616c2088e960deb0b2720a9e65960003078b05bbda578f3007d2ad133615",
                        ["linux-x86"] = "4dc2eb65d0be102d46c353fa451868da6e6a759744185a154d3c7d374c633a64",
                        ["linux-i386"] = "4dc2eb65d0be102d46c353fa451868da6e6a759744185a154d3c7d374c633a64",
                        ["linux-x64"] = "ca3f08a490d56191868929482d026d8be5f538b0219e3c2df6ca1ba06e78b150",
                        ["linux-x86_64"] = "ca3f08a490d56191868929482d026d8be5f538b0219e3c2df6ca1ba06e78b150",
                        ["macosx-arm64"] = "e2d9c9231d0407168e7af25865536bfaa2803429e6fe9ddf90c69a09ad3b9961",
                        ["wasm-wasm32"] = "b6098943abb52ae7214caa4cfdbb0428558c19c5cd59bbd5ce3cd54674f87ecb",
                        ["windows-x64-msvc-14.29-md"] = "f03468a29f4814b7aeab0f6a0c9c3a2dc35e6c50a194edb0e908e07cb400bce4",
                        ["windows-x64-msvc-14.29-mt"] = "3c6788bf1833a4745d959729ed52bb38a4424443a569dfed27e494056bccd6ae",
                        ["windows-x64-msvc-latest-md"] = "a27c8a5cd7b66318cc764acaacd3a0b3c7bc9c63ba1ea602f25932b0f9fcc8cc",
                        ["windows-x64-msvc-latest-mt"] = "f2839ab8baffac8870d99a76ca5c9024a2d1cd9b04e798c3bc5db26d523d4e8e"
                    }
                elseif package:version():ge("0.9.2") then
                    prebuilt = {
                        ["android-arm64-v8a"] = "7912da2d8bde6329ef4eee6f5b91aa5f479119f4fbb850d57e9b8a9e2e8e99a7",
                        ["android-armeabi-v7a"] = "7cb0576afea9ba9538289bc9b7529e9c65d4cbcc41eb47cda84da105b5230613",
                        ["android-x86_64"] = "6483c4a1b0bbd53eb31febf8c0d1395daf9efe2a278140d756298db0b8efbf61",
                        ["linux-arm64"] = "affc339428d69fe10d9fb8df9d7fc48a0332c36c86f04ebdd6660c98913b1ec2",
                        ["linux-x86"] = "3686d1f839750dcc04812eb96939f801ea2d3752afa19734047f980b8abfd84f",
                        ["linux-i386"] = "3686d1f839750dcc04812eb96939f801ea2d3752afa19734047f980b8abfd84f",
                        ["linux-x64"] = "a39b61761660b35a1f2d93b0e18ca1ca94d8665357681199af362c1917637617",
                        ["linux-x86_64"] = "a39b61761660b35a1f2d93b0e18ca1ca94d8665357681199af362c1917637617",
                        ["macosx-arm64"] = "18c8031b83f4ed960b40dff7068dfc4688ae18547332cd3e94f2cea33886decf",
                        ["wasm-wasm32"] = "d5de65af8935d63f56ca95b256b286f84b6e73cba87e79e95195354c2853a82e",
                        ["windows-x64-msvc-14.29-md"] = "c564bf44edbd5f47d33aebc3d2a95f0ac4ade11d47610b9087c2a61c607dd6f0",
                        ["windows-x64-msvc-14.29-mt"] = "b31e0c6f29198cf7fef40193dc1b9eb4b50a35516bee0088873d2154ec787257",
                        ["windows-x64-msvc-latest-md"] = "d679eaaf7cce47c2d9cac8097fc729dd4d3746ec4d817fce51ca1a0a16d0957f",
                        ["windows-x64-msvc-latest-mt"] = "461b68a77c3372a616d8c569c5e57b96f3b9bfdb9df0152a84e428cc249e5dcf"
                    }
                elseif package:version():ge("0.9.1") then
                    prebuilt = {
                        ["android-arm64-v8a"] = "5aa298d33565543c8053f4353d97897d0bd6b26efc511dd26f1d28a8930e5227",
                        ["android-armeabi-v7a"] = "f343c67d23f4544eddd2a9505eb403c28a1a05823112097a89c683175d81b11f",
                        ["android-x86_64"] = "e36448a72c44426bebfc8ee1d3b1b9f284951b74a909ead1dc7265d33919e3b9",
                        ["linux-arm64"] = "c65c65d4e111c00475888dddcb4d8eccb7d287dbe80ce4ca7583446aaabb471d",
                        ["linux-x86"] = "bb27bed1c5043d09428b1a1b382c032936bfd07819c6e0c37ae5eb46dc0ec0f2",
                        ["linux-i386"] = "bb27bed1c5043d09428b1a1b382c032936bfd07819c6e0c37ae5eb46dc0ec0f2",
                        ["linux-x64"] = "21aa94156c954489dcbaf0a27dc3b43dd7f6b290674f442190b2f1d8b5d51d8e",
                        ["linux-x86_64"] = "21aa94156c954489dcbaf0a27dc3b43dd7f6b290674f442190b2f1d8b5d51d8e",
                        ["macosx-arm64"] = "ba901c7fa53825d7f0fbe1c8a8e0f7d3dcda3e365f9080b24d45f03bf2f2ffd3",
                        ["wasm-wasm32"] = "108243abf41716cced70ea0df410640cf2e36daffd9d55f018df7748f76241f0",
                        ["windows-x64-msvc-14.29-md"] = "759a572733933b73658cd4ba7d81912b188208e4c5deec544e01a8a5c1b3ee96",
                        ["windows-x64-msvc-14.29-mt"] = "777a9754eb3686c44d00282e93d00e45a9325c3a911e4fffd2fcff17993be462",
                        ["windows-x64-msvc-latest-md"] = "367d4070670a7f2270db674a5687d2b938972a4069f7f35fc8d43664a4af3589",
                        ["windows-x64-msvc-latest-mt"] = "4006f6ea1a369383233cf21bdd1c893ff207788462d16398ad9806b8b96618bd"
                    }
                elseif package:version():ge("0.9.0") then
                    prebuilt = {
                        ["android-arm64-v8a"] = "839d1c814725837347454e337b48d7e476faa4a378aac497bb18e9b8e15ffc88",
                        ["android-armeabi-v7a"] = "86240a3fe8176037598572484a1d2e2391c46c2915f9183e66d1143d7c3f6faf",
                        ["android-x86_64"] = "367b8c5aebfc9cf635a0c101327e6da701456c42999f6e04a3ae5f10258ad4c2",
                        ["linux-arm64"] = "48db8c534d720fe60f7b61c7aba15ac18ad797376cea7b9cef70ff1d09d95916",
                        ["linux-x86"] = "8d254d837db4a0921da08f38d1cae127053662ba2ac9e811585b912f0abbde87",
                        ["linux-i386"] = "8d254d837db4a0921da08f38d1cae127053662ba2ac9e811585b912f0abbde87",
                        ["linux-x64"] = "bcae2e14e82aa62e84043cc5dc43274ce7bc66f59af1bef4191e7ffe956f0ff8",
                        ["linux-x86_64"] = "bcae2e14e82aa62e84043cc5dc43274ce7bc66f59af1bef4191e7ffe956f0ff8",
                        ["macosx-arm64"] = "854baf79bd56a9fc8097e5c7e8bc3948dd05e979606fbd97631f254448b10ed3",
                        ["wasm-wasm32"] = "f4ffce8db332858070d3a2427d868e3a84a66877c6c03ad73d43435b65d93668",
                        ["windows-x64-msvc-14.29-md"] = "d78d646c223ed2895daf6d713b38e52215d2e585cc34f720fd352d6983f54e1c",
                        ["windows-x64-msvc-14.29-mt"] = "704cc68e83a9f03b6eb758411977ce1e9912ca1bc8c3de67976aafdf5c36017b",
                        ["windows-x64-msvc-latest-md"] = "737a5638cc6534fbb07ecf0c93e7829b4006acb55d62920b569abef533c86e7e",
                        ["windows-x64-msvc-latest-mt"] = "489076ce7cc633229220b39460582820048da6288a78c56d36045c7b3aeae736"
                    }
                elseif package:version():ge("0.8.4") then
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
        -- v0.11.0+ requires an explicit shader id on the BuildRequest.
        local id_line = package:version():ge("0.11.0") and [[req.id = "test/probe";]] or ""
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
]] .. id_line .. [[

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
