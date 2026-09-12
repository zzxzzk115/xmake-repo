set_project("shader-package-consumer")
set_languages("cxx23")
add_rules("mode.debug", "mode.release")
set_policy("package.precompiled", false)
add_repositories("package-under-test " .. path.absolute("../..", os.scriptdir()))
add_repositories("upstream https://github.com/zzxzzk115/xmake-repo.git backup")
if is_plat("windows") then
    set_runtimes(is_mode("debug") and "MTd" or "MT")
    add_requireconfs("**", {configs = {runtimes = is_mode("debug") and "MTd" or "MT"}})
end
add_requires("vrf b9db9278b8b8cdeb8edc5fd26ceff355f2cae705")
add_requires("vasset 340e64a4c654a23cd6a15ee5798cb8fd2acc1c44", {configs = {link_importers = true}})
-- The importer needs the compiler library; resolve one configuration for runtime and importer.
add_requireconfs("**.vshadersystem", {override = true, version = "v1.2.1", configs = {vshaderc_lib = true}})

target("shader-package-consumer")
    set_kind("binary")
    add_files("main.cpp")
    add_packages("vrf", "vasset")
