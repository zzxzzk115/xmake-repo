package("enkits")
    set_homepage("https://github.com/dougbinks/enkiTS")
    set_description("A permissively licensed C and C++ Task Scheduler for creating parallel programs.")
    set_license("zlib")

    add_urls("https://github.com/dougbinks/enkiTS/archive/refs/tags/$(version).tar.gz",
             "https://github.com/dougbinks/enkiTS.git")

    add_versions("v1.12", "8373b6199d56816bd3ba58432eae74e2ebd5afcfdffb723073cc34730b189fd5")
    add_versions("v1.11", "b57a782a6a68146169d29d180d3553bfecb9f1a0e87a5159082331920e7d297e")
    add_versions("v1.10", "578f285fc7c2744bf831548f35b855c6ab06c0d541d08c9cc50b6b72a250811a")

    -- Fixed upstream after v1.12: a missing <cstdlib> (libc++, Emscripten), and Dependency's move constructor leaving
    -- the moved-from object linked, which breaks a task's dependency list when a container of them grows.
    add_patches("v1.12", "https://github.com/dougbinks/enkiTS/commit/4cba61a045d8e759bd35e5d85691bf9f7271f822.patch",
                "2eefc495058ef13eb74406825467ab520aab570411cd1a6912a58d0520528329")
    add_patches("v1.12", "https://github.com/dougbinks/enkiTS/commit/404a3bf8f855039dfff2052184d6308655286c07.patch",
                "1b41cc960b317836dd58b9c9c8178f32bc2f64a30af57aa19210a9dafc9fc733")

    add_deps("cmake")
    add_links("enkiTS")
    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "rt")
    end

    on_load(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "ENKITS_DLL")
        end
        if package:version() and package:version():lt("1.12.0") then
            package:add("linkdirs", "lib/enkiTS")
        end
    end)

    on_install(function (package)
        if package:is_plat("linux") then
            io.replace("src/TaskScheduler.h", "#include <functional>", "#include <functional>\n#include <initializer_list>\n", {plain = true})
        end

        local configs = {"-DENKITS_BUILD_EXAMPLES=OFF", "-DENKITS_INSTALL=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DENKITS_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets([[
            void test() {
                enki::TaskScheduler g_TS;
                g_TS.Initialize();
            }
        ]], {configs = {languages = "c++17"}, includes = "enkiTS/TaskScheduler.h"}))
    end)
