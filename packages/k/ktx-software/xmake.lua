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

    add_deps("cmake", "shaderc v2022.2")

    on_install(function (package)
        local configs = {
            "-DKTX_FEATURE_KTX1=ON",
            "-DKTX_FEATURE_KTX2=ON",
            "-DKTX_FEATURE_VK_UPLOAD=ON",
            "-DKTX_FEATURE_TOOLS=OFF",
            "-DKTX_FEATURE_DOC=OFF",
            "-DKTX_FEATURE_JNI=OFF",
            "-DKTX_FEATURE_PY=OFF",
            "-DKTX_FEATURE_TESTS=OFF",
            "-DKTX_FEATURE_TOOLS_CTS=OFF",
            "-DKTX_FEATURE_GL_UPLOAD=OFF",
            -- "-DKTX_FEATURE_STATIC_LIBRARY=" .. (package:config("shared") and "OFF" or "ON")
        }
        
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        import("package.tools.cmake").install(package, configs)
    end)