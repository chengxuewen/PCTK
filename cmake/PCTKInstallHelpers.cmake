# Wraps install() command. In a prefix build, simply passes along arguments to install().
# In a non-prefix build, handles association of targets to export names, and also calls export().
function(pctk_install)
    set(flags)
    set(options EXPORT DESTINATION NAMESPACE)
    set(multiopts TARGETS)
    cmake_parse_arguments(arg "${flags}" "${options}" "${multiopts}" ${ARGN})

    if(arg_TARGETS)
        set(is_install_targets TRUE)
    endif()

    # In a prefix build, always invoke install() without modification.
    # In a non-prefix build, pass install(TARGETS) commands to allow
    # association of targets to export names, so we can later use the export names
    # in export() commands.
    if(PCTK_WILL_INSTALL OR is_install_targets)
        install(${ARGV})
    endif()

    # When install(EXPORT) is called, also call export(EXPORT)
    # to generate build tree target files.
    if(NOT is_install_targets AND arg_EXPORT)
        # For prefixed builds (both top-level and per-repo) export build tree CMake Targets files so
        # they can be used in CMake ExternalProjects. One such case is examples built as
        # ExternalProjects as part of the PCTK build.
        # In a top-level build the exported config files are placed under pctkbase/lib/cmake.
        # In a per-repo build, they will be placed in each repo's build dir/lib/cmake.
        if(PCTK_WILL_INSTALL)
            pctk_path_join(arg_DESTINATION "${PCTK_BUILD_DIR}" "${arg_DESTINATION}")
        endif()

        set(namespace_option "")
        if(arg_NAMESPACE)
            set(namespace_option NAMESPACE ${arg_NAMESPACE})
        endif()
        export(EXPORT ${arg_EXPORT} ${namespace_option} FILE "${arg_DESTINATION}/${arg_EXPORT}.cmake")
    endif()
endfunction()