
macro(_pctk_internal_setup_pctk_host_path
    host_path_required
    initial_pctk_host_path
    initial_pctk_host_path_cmake_dir
    )
    # Set up PCTK_HOST_PATH and do sanity checks.
    # A host path is required when cross-compiling but optional when doing a native build.
    # Requiredness can be overridden via variable.
    if(DEFINED PCTK_REQUIRE_HOST_PATH_CHECK)
        set(_pctk_platform_host_path_required "${PCTK_REQUIRE_HOST_PATH_CHECK}")
    else()
        set(_pctk_platform_host_path_required "${host_path_required}")
    endif()

    if(_pctk_platform_host_path_required)
        # PCTK_HOST_PATH precedence:
        # - cache variable / command line option
        # - environment variable
        # - initial PCTK_HOST_PATH when pctkbase was configured (and the directory exists)
        if(NOT DEFINED PCTK_HOST_PATH)
            if(DEFINED ENV{PCTK_HOST_PATH})
                set(PCTK_HOST_PATH "$ENV{PCTK_HOST_PATH}" CACHE PATH "")
            elseif(NOT "${initial_pctk_host_path}" STREQUAL "" AND EXISTS "${initial_pctk_host_path}")
                set(PCTK_HOST_PATH "${initial_pctk_host_path}" CACHE PATH "")
            endif()
        endif()

        if(NOT PCTK_HOST_PATH STREQUAL "")
            get_filename_component(_pctk_platform_host_path_absolute "${PCTK_HOST_PATH}" ABSOLUTE)
        endif()

        if("${PCTK_HOST_PATH}" STREQUAL "" OR NOT EXISTS "${_pctk_platform_host_path_absolute}")
            message(FATAL_ERROR
                "To use a cross-compiled Qt, please set the PCTK_HOST_PATH cache variable to the "
                "location of your host Qt installation.")
        endif()

        # PCTK_HOST_PATH_CMAKE_DIR is needed to work around the rerooting issue when looking for host
        # tools. See REROOT_PATH_ISSUE_MARKER.
        # Prefer initially configured path if none was explicitly set.
        if(NOT DEFINED PCTK_HOST_PATH_CMAKE_DIR)
            if(NOT "${initial_pctk_host_path_cmake_dir}" STREQUAL ""
                AND EXISTS "${initial_pctk_host_path_cmake_dir}")
                set(PCTK_HOST_PATH_CMAKE_DIR "${initial_pctk_host_path_cmake_dir}" CACHE PATH "")
            else()
                # First try to auto-compute the location instead of requiring to set
                # PCTK_HOST_PATH_CMAKE_DIR explicitly.
                set(__pctk_candidate_host_path_cmake_dir "${PCTK_HOST_PATH}/lib/cmake")
                if(__pctk_candidate_host_path_cmake_dir
                    AND EXISTS "${__pctk_candidate_host_path_cmake_dir}")
                    set(PCTK_HOST_PATH_CMAKE_DIR
                        "${__pctk_candidate_host_path_cmake_dir}" CACHE PATH "")
                endif()
            endif()
        endif()

        if(NOT PCTK_HOST_PATH_CMAKE_DIR STREQUAL "")
            get_filename_component(_pctk_platform_host_path_cmake_dir_absolute
                "${PCTK_HOST_PATH_CMAKE_DIR}" ABSOLUTE)
        endif()

        if("${PCTK_HOST_PATH_CMAKE_DIR}" STREQUAL ""
            OR NOT EXISTS "${_pctk_platform_host_path_cmake_dir_absolute}")
            message(FATAL_ERROR
                "To use a cross-compiled Qt, please set the PCTK_HOST_PATH_CMAKE_DIR cache variable "
                "to the location of your host Qt installation lib/cmake directory.")
        endif()
    endif()
endmacro()


# Create Depends.cmake & Depends.h files for all modules and plug-ins.
function(pctk_internal_create_depends_files)
    pctk_internal_get_repo_known_libraries(repo_known_libraries)
    message(------pctk_internal_create_depends_files:repo_known_libraries=${repo_known_libraries})

    #    # This is used for substitution in the configured file.
    #    set(target "${INSTALL_CMAKE_NAMESPACE}")
    #
    #    # This is the actual target we're querying.
    #    set(actual_target Platform)
    #    get_target_property(public_depends "${actual_target}" INTERFACE_LINK_LIBRARIES)
    #    unset(depends)
    #    unset(optional_public_depends)
    #
    #    # We need to collect third party deps that are set on the public Platform target,
    #    # like Threads::Threads.
    #    # This mimics find_package part of the CONFIG += thread assignment in mkspecs/features/pctk.prf.
    #    pctk_collect_third_party_deps(${actual_target})
    #
    #    # For Threads we also need to write an extra variable assignment.
    #    set(third_party_extra "")
    #    if(third_party_deps MATCHES "Threads")
    #        string(APPEND third_party_extra "if(NOT PCTK_NO_THREADS_PREFER_PTHREAD_FLAG)
    #                                            set(THREADS_PREFER_PTHREAD_FLAG TRUE)
    #                                         endif()")
    #    endif()

    pctk_internal_determine_if_host_info_package_needed(platform_requires_host_info_package)
    message(platform_requires_host_info_package=${platform_requires_host_info_package})
    if(platform_requires_host_info_package)
        # TODO: Figure out how to make the initial PCTK_HOST_PATH var relocatable in relation
        # to the target CMAKE_INSTALL_DIR, if at all possible to do so in a reliable way.
        get_filename_component(pctk_host_path_absolute "${PCTK_HOST_PATH}" ABSOLUTE)
        get_filename_component(pctk_host_path_cmake_dir_absolute "${PCTK${PCTK_NAMESPACE_VERSION}HostInfo_DIR}/.." ABSOLUTE)
    endif()

    #    if(third_party_deps OR platform_requires_host_info_package)
    #        # Setup build and install paths.
    #        set(path_suffix "${INSTALL_CMAKE_NAMESPACE}")
    #
    #        pctk_path_join(config_build_dir ${PCTK_CONFIG_BUILD_DIR} ${path_suffix})
    #        pctk_path_join(config_install_dir ${PCTK_CONFIG_INSTALL_DIR} ${path_suffix})
    #
    #        # Configure and install QtDependencies file.
    #        configure_file(
    #            "${PCTK_CMAKE_DIR}/QtConfigDependencies.cmake.in"
    #            "${config_build_dir}/${target}Dependencies.cmake"
    #            @ONLY
    #        )
    #
    #        pctk_install(FILES
    #            "${config_build_dir}/${target}Dependencies.cmake"
    #            DESTINATION "${config_install_dir}"
    #            COMPONENT Devel
    #            )
    #    endif()

    foreach(target ${repo_known_libraries})
        pctk_internal_create_library_depends_file(${target})
    endforeach()

    foreach(target ${PCTK_KNOWN_PLUGINS})
        pctk_internal_create_plugin_depends_file(${target})
    endforeach()
endfunction()


function(pctk_internal_determine_if_host_info_package_needed out_var)
    set(needed FALSE)

    # If a PCTK_HOST_PATH is provided when configuring PCTK, we assume it's a cross build
    # and thus we require the PCTK_HOST_PATH to be provided also when using the cross-built PCTK.
    # This tells the PCTKConfigDependencies file to do appropriate requirement checks.
    if(NOT "${PCTK_HOST_PATH}" STREQUAL "" AND NOT PCTK_NO_REQUIRE_HOST_PATH_CHECK)
        set(needed TRUE)
    endif()
    set(${out_var} "${needed}" PARENT_SCOPE)
endfunction()
