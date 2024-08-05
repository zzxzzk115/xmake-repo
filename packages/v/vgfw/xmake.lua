package("vgfw")
    set_homepage("https://github.com/zzxzzk115/vgfw")
    set_description("VGFW (V Graphics FrameWork) is a header-only library designed for rapidly creating graphics prototypes.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/vgfw/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zzxzzk115/vgfw.git")
	
	add_versions("v1.1.1", "51dfda6e280523ea50c59a2f7ff5a325f196b157d598709a6f145071c91b6160")

    add_deps("fg", "glad", "glfw", "glm", "spdlog", "stb", "tinyobjloader", "tinygltf")
	add_deps("imgui v1.90.8-docking", {configs = {glfw = true, opengl3 = true, wchar32 = true}})

    if is_plat("linux") then
        add_syslinks("dl")
    end

    on_install("windows", "linux", function (package)
        import("package.tools.xmake").install(package)
    end)
