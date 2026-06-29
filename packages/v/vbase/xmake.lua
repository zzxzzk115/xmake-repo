package("vbase")
    set_homepage("https://github.com/zzxzzk115/vbase")
    set_description("VBase - core utilities (logging, assertions, types) for the Vultra ecosystem.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/vbase/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zzxzzk115/vbase.git")

    add_versions("v0.2.1", "78a0011512541069c25d36169af9ea28dcfb1fbc607c0b39c10262271796c064")

    -- vbase/config.hpp #errors unless these are defined by the build system. The library's target
    -- sets them as public defines for in-workspace builds; a package must re-export them so
    -- consumers compiling against the headers get them too (VBASE_DEBUG matches the build mode).
    on_load(function (package)
        package:add("defines", "VBASE_DEBUG=" .. (package:is_debug() and "1" or "0"))
        package:add("defines", "VBASE_USE_EXCEPTIONS=0", "VBASE_ENABLE_RTTI=0", "VBASE_ASSERT_LEVEL=2")
    end)

    on_install(function (package)
        import("package.tools.xmake").install(package, {VBase_build_examples = false})
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("vbase/api.hpp", {configs = {languages = "c++23"}}))
    end)
