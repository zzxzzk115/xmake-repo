package("vtask")
    set_homepage("https://github.com/zzxzzk115/vtask")
    set_description("VTask - an enkiTS-based task scheduler for the Vultra ecosystem.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/vtask/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zzxzzk115/vtask.git")

    add_versions("v0.1.0", "e664e8078ed797a018de8ca85269a20cbe4f2b056d954314d885cb0b1edda22b")

    add_deps("vbase", "enkits")

    on_install(function (package)
        import("package.tools.xmake").install(package, {vtask_build_examples = false})
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("vtask/scheduler.hpp", {configs = {languages = "c++23"}}))
    end)
