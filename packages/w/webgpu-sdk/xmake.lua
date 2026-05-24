package("webgpu-sdk")
    set_homepage("https://github.com/zzxzzk115/webgpu-sdk")
    set_description("Reusable WebGPU C/C++ SDK bundle for desktop and WASM.")
    set_license("MIT")

    if is_plat("windows") and is_arch("x64", "x86_64") then
        add_urls("https://github.com/zzxzzk115/webgpu-sdk/releases/download/$(version)/webgpu-sdk-prebuilt-$(version)-windows-x64.zip")
        add_versions("v0.1.2", "11b772d579907e9566e2b6cfc276f2d507cce2c14fa53a450c78e10e61152ec2")
        add_versions("v0.1.1", "b81240fb5f3abef67fb4f790d5bc9752cc4db3737df94f9a0b995c020c891600")
    elseif is_plat("linux") and is_arch("x86_64") then
        add_urls("https://github.com/zzxzzk115/webgpu-sdk/releases/download/$(version)/webgpu-sdk-prebuilt-$(version)-linux-x86_64.zip")
        add_versions("v0.1.2", "b85956165cfa7ed7dab792d6a864a7e4c16940f5d8244171920d6e358783b45f")
        add_versions("v0.1.1", "851f2ccf2f0ac635d19633cc8a59f754e3d86381fdd7d4216519ab362febb7f9")
    elseif is_plat("macosx") and is_arch("arm64") then
        add_urls("https://github.com/zzxzzk115/webgpu-sdk/releases/download/$(version)/webgpu-sdk-prebuilt-$(version)-macosx-arm64.zip")
        add_versions("v0.1.2", "fe9eeae884b689ac253f4e54dcbc948184267041a2e6ddee4fe9bf7bb22ca4c1")
        add_versions("v0.1.1", "9924c56d785554ba6f76a0741adc3cf845af8ef101252239287152328ba32758")
    elseif is_plat("wasm") and is_arch("wasm32") then
        add_urls("https://github.com/zzxzzk115/webgpu-sdk/releases/download/$(version)/webgpu-sdk-prebuilt-$(version)-wasm-wasm32.zip")
        add_versions("v0.1.2", "0035fe4493b67bf0ae09fa705dc650cd1efff8d570ad81f65878d6739e4873d0")
        add_versions("v0.1.1", "e9188df90c2397dc114c31df4605342a75d7c01425c5c317f97ef7b49ab5e1ad")
    end

    add_includedirs("include", "include/webgpu")

    on_load(function (package)
        package:add("links", "glfw3webgpu")
        if not package:is_plat("wasm") then
            package:add("links", "wgpu_native")
            package:add("deps", "glfw", {public = true})
            package:addenv("PATH", "lib")
            if package:is_plat("windows") then
                package:add("syslinks", "d3dcompiler", "ws2_32", "userenv", "ntdll", "bcrypt", "opengl32", "propsys", "runtimeobject", "ole32", "oleaut32")
            elseif package:is_plat("linux") then
                package:add("syslinks", "dl", "pthread", "m")
            end
            if package:is_plat("linux", "macosx") then
                package:add("rpathdirs", package:installdir("lib"), {public = true})
            end
        else
            -- Emscripten removed -sUSE_WEBGPU; use emdawnwebgpu port to provide <webgpu/webgpu.h>.
            package:add("cflags", "--use-port=emdawnwebgpu", {force = true, public = true})
            package:add("cxxflags", "--use-port=emdawnwebgpu", {force = true, public = true})
            package:add("ldflags", "--use-port=emdawnwebgpu", "-sUSE_GLFW=3", {force = true, public = true})
        end
        if package:is_plat("macosx") then
            package:add("syslinks", "objc")
            package:add("frameworks", "Cocoa", "Metal", "MetalKit", "QuartzCore")
        end
    end)

    on_install(function (package)
        local version = tostring(package:version())
        local rootdir = os.dirs("webgpu-sdk-prebuilt-" .. version .. "-*")[1]
        if not rootdir then
            rootdir = os.dirs(path.join("prebuilt", "webgpu-sdk-prebuilt-" .. version .. "-*"))[1]
        end
        assert(rootdir, "package(webgpu-sdk): cannot find prebuilt root directory")
        os.cp(path.join(rootdir, "*"), package:installdir())
    end)

    on_test(function (package)
        if package:is_plat("wasm") then
            return
        end
        if package:is_cross() then
            return
        end

        assert(package:check_cxxsnippets({test = [[
            #include <GLFW/glfw3.h>
            #include <glfw3webgpu.h>
            #include <webgpu/webgpu.h>

            void test()
            {
                auto init_fn = &glfwInit;
                auto surface_fn = &glfwGetWGPUSurface;

                WGPUInstanceDescriptor desc{};
                WGPUInstance instance = wgpuCreateInstance(&desc);
                (void)instance;
                (void)init_fn;
                (void)surface_fn;
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
