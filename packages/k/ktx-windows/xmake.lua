package("ktx-windows")
    set_homepage("https://github.com/zzxzzk115/ktx-windows")
    set_description("Prebuilt KTX library for Windows.")
    set_license("MIT")

    add_urls("https://github.com/zzxzzk115/ktx-windows.git")

    add_versions("2025.09.11", "8ece71d8ff41619cceeb2d82a0ae90fdf915d39f")

    add_links("ktx")

    on_load(function (package)
		package:addenv("PATH", path.join(package:installdir(), "bin"))
    end)

    on_install(function (package)
		-- copy include, lib, and bin directories to install directory
		os.cp(path.join("KTX-Software", package:plat(), package:arch(), "include"), package:installdir())
		os.cp(path.join("KTX-Software", package:plat(), package:arch(), "lib"), package:installdir())
		os.cp(path.join("KTX-Software", package:plat(), package:arch(), "bin"), package:installdir())
    end)

    on_test(function (package)
		assert(package:has_cfuncs("ktxErrorString", {includes = "ktx.h"}))
    end)