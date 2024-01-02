package("hjson-cpp")
    set_homepage("https://github.com/hjson/hjson-cpp")
    set_description("Hjson for C++")
    set_license("MIT")

    add_urls("https://github.com/hjson/hjson-cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/hjson/hjson-cpp.git")

    add_versions("2.4.1", "3c34b598c5e36b486d630fc9658a97f9b11e7a11")

    if is_plat("linux", "bsd") then
        add_syslinks("m", "pthread")
    end

    add_deps("cmake")
    add_includedirs("include")

    on_install(function (package)
        os.trycp(path.join("include", "hjson"), package:installdir("include"))
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                Hjson::Value val1;
                val1["zeta"] = 1;
                val1["y"] = 2;
                val1.move(0, 2);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "hjson/hjson.h"}))
    end)

