add_rules("mode.debug", "mode.release")
add_rules("utils.install.cmake_importfiles")
set_languages("cxx20")

target("fg")
    set_kind("$(kind)")
    add_files("src/*.cpp")
    add_headerfiles("include/(fg/*.hpp)", "include/(fg/*.inl)")
    add_includedirs("include", "include/fg", {public = true})