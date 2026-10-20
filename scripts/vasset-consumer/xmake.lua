set_project("vasset-package-consumer")
set_languages("cxx23")
add_rules("mode.debug", "mode.release")
set_policy("package.precompiled", false)

-- Resolve the recipe under review, rather than a cached remote repository.
add_repositories("package-under-test " .. path.absolute("../..", os.scriptdir()))
add_requires("vasset v0.4.1", {
    system = false,
    configs = {importers = false, link_importers = false, debug = is_mode("debug")}
})

target("vasset-package-consumer")
    set_kind("binary")
    add_files("main.cpp")
    add_packages("vasset")
