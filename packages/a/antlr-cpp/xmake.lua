package("antlr-cpp")
    set_homepage("https://github.com/antlr/antlr4")
    set_description("ANTLR (ANother Tool for Language Recognition) is a powerful parser generator for reading, processing, executing, or translating structured text or binary files.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/antlr/antlr4/archive/refs/tags/$(version).tar.gz",
             "https://github.com/antlr/antlr4.git")

    add_versions("4.13.1", "7ed420ff2c78d62883875c442d75f32e73bc86c8")

    if is_plat("linux", "bsd") then
        add_syslinks("m", "pthread")
    end

    add_deps("cmake")

    on_install(function (package)
        os.cd(path.join("runtime", "Cpp"))

        local configs = {"-DANTLR_BUILD_CPP_TESTS=OFF", "-DWITH_STATIC_CRT=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        
        import("package.tools.cmake").install(package, configs)
    end)