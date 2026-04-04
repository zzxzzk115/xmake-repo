package("webgpu-sdk")
    set_homepage("https://github.com/zzxzzk115/webgpu-sdk")
    set_description("Reusable WebGPU C/C++ SDK bundle for desktop and WASM.")
    set_license("MIT")

    if is_plat("windows") and is_arch("x64", "x86_64") then
        add_urls("https://github.com/zzxzzk115/webgpu-sdk/releases/download/$(version)/webgpu-sdk-prebuilt-$(version)-windows-x64.zip")
        add_versions("v0.1.0", "7cc0140f77d6a57a037a64707f5ab633a351eb0879fbaf85675c7f2a173d722d")
    elseif is_plat("linux") and is_arch("x86_64") then
        add_urls("https://github.com/zzxzzk115/webgpu-sdk/releases/download/$(version)/webgpu-sdk-prebuilt-$(version)-linux-x86_64.zip")
        add_versions("v0.1.0", "85459227cab53d25e0eed3ad052a9591fb00264909906abf8b2bdbd8c827e066")
    elseif is_plat("macosx") and is_arch("arm64") then
        add_urls("https://github.com/zzxzzk115/webgpu-sdk/releases/download/$(version)/webgpu-sdk-prebuilt-$(version)-macosx-arm64.zip")
        add_versions("v0.1.0", "ebb310fcebcfc6c14a011d3d6bb31d8dab96d1000b3636e4d030e0a0c386cec5")
    elseif is_plat("wasm") and is_arch("wasm32") then
        add_urls("https://github.com/zzxzzk115/webgpu-sdk/releases/download/$(version)/webgpu-sdk-prebuilt-$(version)-wasm-wasm32.zip")
        add_versions("v0.1.0", "6f2dc130f9649bd9e7a2eabfb38008adb5b65e3b96cb13056df07aa045fb83a6")
    end

    add_includedirs("include", "include/webgpu")

    on_load(function (package)
        package:add("links", "glfw3webgpu")
        if not package:is_plat("wasm") then
            package:add("links", "wgpu_native")
            package:add("deps", "glfw", {public = true})
        else
            package:add("ldflags", "-sUSE_WEBGPU", "-sUSE_GLFW=3", {force = true, public = true})
        end
        if package:is_plat("macosx") then
            package:add("syslinks", "objc")
            package:add("frameworks", "Cocoa", "QuartzCore")
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
        package:add("ldflags", "-Wl,-rpath," .. package:installdir("lib"), {force = true, public = true})
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
