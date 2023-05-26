

#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_clear_repo_known_libraries)
    set(PCTK_REPO_KNOWN_LIBRARIES "" CACHE INTERNAL "Known current repo PCTK libraries" FORCE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_add_repo_known_library)
    if(NOT (${ARGN} IN_LIST PCTK_REPO_KNOWN_LIBRARIES))
        set(PCTK_REPO_KNOWN_LIBRARIES ${PCTK_REPO_KNOWN_LIBRARIES} ${ARGN}
            CACHE INTERNAL "Known current repo PCTK libraries" FORCE)
    endif()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_get_repo_known_libraries out_var)
    set("${out_var}" "${PCTK_REPO_KNOWN_LIBRARIES}" PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
macro(pctk_internal_append_known_libraries_with_tools library)
    if(NOT ${library} IN_LIST PCTK_KNOWN_LIBRARIES_WITH_TOOLS)
        set(PCTK_KNOWN_LIBRARIES_WITH_TOOLS "${PCTK_KNOWN_LIBRARIES_WITH_TOOLS};${library}"
            CACHE INTERNAL "Known PCTK libraries with tools" FORCE)
        set(PCTK_KNOWN_LIBRARIES_${library}_TOOLS ""
            CACHE INTERNAL "Known PCTK libraries ${library} tools" FORCE)
    endif()
endmacro()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
macro(pctk_internal_append_known_library_tool library tool)
    if(NOT ${tool} IN_LIST PCTK_KNOWN_LIBRARIES_${library}_TOOLS)
        list(APPEND PCTK_KNOWN_LIBRARIES_${library}_TOOLS "${tool}")
        set(PCTK_KNOWN_LIBRARIES_${library}_TOOLS "${PCTK_KNOWN_LIBRARIES_${library}_TOOLS}"
            CACHE INTERNAL "Known PCTK library ${library} tools" FORCE)
    endif()
endmacro()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
macro(pctk_build_repo_begin)
    pctk_build_internals_set_up_private_api()

    # Prevent installation in non-prefix builds.
    # We need to associate targets with export names, and that is only possible to do with the
    # install(TARGETS) command. But in a non-prefix build, we don't want to install anything.
    # To make sure that developers don't accidentally run make install, add bail out code to
    # cmake_install.cmake.
#    if(NOT PCTK_WILL_INSTALL)
#        # In a top-level build, print a message only in pctkbase, which is the first repository.
#        if(NOT PCTK_SUPERBUILD OR (PROJECT_NAME STREQUAL "PCTKBase"))
#            install(CODE [[message(FATAL_ERROR
#                    "PCTK was configured as non-prefix build. "
#                    "Installation is not supported for this arrangement.")]])
#        endif()
#
#        install(CODE [[return()]])
#    endif()

#    pctk_enable_cmake_languages()

    pctk_internal_generate_binary_strip_wrapper()

#    # Add global docs targets that will work both for per-repo builds, and super builds.
#    if(NOT TARGET docs)
#        add_custom_target(docs)
#        add_custom_target(prepare_docs)
#        add_custom_target(generate_docs)
#        add_custom_target(html_docs)
#        add_custom_target(qch_docs)
#        add_custom_target(install_html_docs)
#        add_custom_target(install_qch_docs)
#        add_custom_target(install_docs)
#        add_dependencies(html_docs generate_docs)
#        add_dependencies(docs html_docs qch_docs)
#        add_dependencies(install_docs install_html_docs install_qch_docs)
#    endif()

    # Add global pctk_plugins, qpa_plugins and qpa_default_plugins convenience custom targets.
    # Internal executables will add a dependency on the qpa_default_plugins target,
    # so that building and running a test ensures it won't fail at runtime due to a missing qpa
    # plugin.
#    if(NOT TARGET pctk_plugins)
#        add_custom_target(pctk_plugins)
#        add_custom_target(pctk_pa_plugins)
#        add_custom_target(pctk_pa_default_plugins)
#    endif()
#
#    string(TOLOWER ${PROJECT_NAME} project_name_lower)
#
#    set(pctk_repo_targets_name ${project_name_lower})
#    set(pctk_docs_target_name docs_${project_name_lower})
#    set(pctk_docs_prepare_target_name prepare_docs_${project_name_lower})
#    set(pctk_docs_generate_target_name generate_docs_${project_name_lower})
#    set(pctk_docs_html_target_name html_docs_${project_name_lower})
##    set(pctk_docs_qch_target_name qch_docs_${project_name_lower})
#    set(pctk_docs_install_html_target_name install_html_docs_${project_name_lower})
#    set(pctk_docs_install_qch_target_name install_qch_docs_${project_name_lower})
#    set(pctk_docs_install_target_name install_docs_${project_name_lower})
#
#    add_custom_target(${pctk_docs_target_name})
#    add_custom_target(${pctk_docs_prepare_target_name})
#    add_custom_target(${pctk_docs_generate_target_name})
##    add_custom_target(${pctk_docs_qch_target_name})
#    add_custom_target(${pctk_docs_html_target_name})
#    add_custom_target(${pctk_docs_install_html_target_name})
#    add_custom_target(${pctk_docs_install_qch_target_name})
#    add_custom_target(${pctk_docs_install_target_name})
#
#    add_dependencies(${pctk_docs_generate_target_name} ${pctk_docs_prepare_target_name})
#    add_dependencies(${pctk_docs_html_target_name} ${pctk_docs_generate_target_name})
#    add_dependencies(${pctk_docs_target_name} ${pctk_docs_html_target_name} ${pctk_docs_qch_target_name})
#    add_dependencies(${pctk_docs_install_target_name} ${pctk_docs_install_html_target_name} ${pctk_docs_install_qch_target_name})
#
#    # Make top-level prepare_docs target depend on the repository-level prepare_docs_<repo> target.
#    add_dependencies(prepare_docs ${pctk_docs_prepare_target_name})
#
#    # Make top-level install_*_docs targets depend on the repository-level install_*_docs targets.
#    add_dependencies(install_html_docs ${pctk_docs_install_html_target_name})
##    add_dependencies(install_qch_docs ${pctk_docs_install_qch_target_name})
#
#    # Add host_tools meta target, so that developrs can easily build only tools and their
#    # dependencies when working in pctkbase.
#    if(NOT TARGET host_tools)
#        add_custom_target(host_tools)
#        add_custom_target(bootstrap_tools)
#    endif()
#
#    # Add benchmark meta target. It's collection of all benchmarks added/registered by
#    # 'pctk_internal_add_benchmark' helper.
#    if(NOT TARGET benchmark)
#        add_custom_target(benchmark)
#    endif()
endmacro()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
macro(pctk_build_repo_end)
    if(NOT PCTK_BUILD_STANDALONE_TESTS)
        # Delayed actions on some of the PCTK targets:
        include(PCTKPostProcess)

        # Install the repo-specific cmake find modules.
        pctk_path_join(__pctk_repo_install_dir ${PCTK_CONFIG_INSTALL_DIR} ${INSTALL_CMAKE_NAMESPACE})
        pctk_path_join(__pctk_repo_build_dir ${PCTK_CONFIG_BUILD_DIR} ${INSTALL_CMAKE_NAMESPACE})

        if(NOT PROJECT_NAME STREQUAL "PCTKBase")
            if(IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
                pctk_copy_or_install(DIRECTORY cmake/
                    DESTINATION "${__pctk_repo_install_dir}"
                    FILES_MATCHING PATTERN "Find*.cmake"
                    )
                if(PCTK_SUPERBUILD AND PCTK_WILL_INSTALL)
                    file(COPY cmake/
                        DESTINATION "${__pctk_repo_build_dir}"
                        FILES_MATCHING PATTERN "Find*.cmake"
                        )
                endif()
            endif()
        endif()

        if(NOT PCTK_SUPERBUILD)
            pctk_print_feature_summary()
        endif()
    endif()

    pctk_build_internals_add_toplevel_targets()

    if(NOT PCTK_SUPERBUILD)
        pctk_print_build_instructions()
    endif()
endmacro()