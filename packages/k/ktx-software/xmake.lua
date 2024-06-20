package("ktx-software")

    set_homepage("https://github.com/KhronosGroup/KTX-Software")
    set_description("KTX (Khronos Texture) Library and Tools")
	
	set_license("Apache-2.0")

    set_urls("https://github.com/KhronosGroup/KTX-Software/archive/refs/tags/$(version).tar.gz",
             "https://github.com/KhronosGroup/KTX-Software.git")

    add_versions("v4.3.2", "74a114f465442832152e955a2094274b446c7b2427c77b1964c85c173a52ea1f")

    if is_plat("linux", "bsd") then
        add_syslinks("m", "pthread")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DKTX_FEATURE_TOOLS=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        
        import("package.tools.cmake").install(package, configs)
    end)