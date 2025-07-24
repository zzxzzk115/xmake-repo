package("fg")

    set_homepage("https://github.com/skaarj1989/FrameGraph/")
    set_description("Renderer agnostic frame graph library.")
    set_license("MIT")

    add_urls("https://github.com/skaarj1989/FrameGraph/archive/refs/tags/$(version).tar.gz",
             "https://github.com/skaarj1989/FrameGraph.git")

    add_includedirs("include", "include/fg")

    on_install(function (package)
        local configs = {}
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)
