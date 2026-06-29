package("vfilesystem")
    set_homepage("https://github.com/zzxzzk115/vfilesystem")
    set_description("VFileSystem - a virtual filesystem (physical/memory backends, VFS mounts) for the Vultra ecosystem.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/vfilesystem/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zzxzzk115/vfilesystem.git")

    add_versions("v0.2.0", "83ea4c98252c06229116777db05f9a955a8c790f33ade2f001c0f43fc380f341")

    add_deps("vtask")

    on_install(function (package)
        import("package.tools.xmake").install(package, {VFileSystem_build_examples = false})
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("vfilesystem/interfaces/ifilesystem.hpp", {configs = {languages = "c++23"}}))
    end)
