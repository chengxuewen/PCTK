
#-----------------------------------------------------------------------------------------------------------------------
# This function stores the list of PCTK targets a library depend on,
# along with their version info, for usage in ${target}Depends.cmake file
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_register_target_dependencies target public_libs private_libs)
    get_target_property(target_deps "${target}" _pctk_target_deps)
    if(NOT target_deps)
        set(target_deps "")
    endif()

    get_target_property(target_type ${target} TYPE)
    set(lib_list ${public_libs})

    set(target_is_shared FALSE)
    set(target_is_static FALSE)
    if(target_type STREQUAL "SHARED_LIBRARY")
        set(target_is_shared TRUE)
    elseif(target_type STREQUAL "STATIC_LIBRARY")
        set(target_is_static TRUE)
    endif()

    # Record 'pctk::Foo'-like private dependencies of static library targets, this will be used to
    # generate find_dependency() calls.
    #
    # Private static library dependencies will become $<LINK_ONLY:> dependencies in
    # INTERFACE_LINK_LIBRARIES.
    if(target_is_static)
        list(APPEND lib_list ${private_libs})
    endif()

    foreach(lib IN LISTS lib_list)
        if("${lib}" MATCHES "^pctk::(.*)")
            set(lib "${CMAKE_MATCH_1}")
            pctk_internal_get_package_name_of_target("${lib}" package_name)
            pctk_internal_get_package_version_of_target("${lib}" package_version)
            list(APPEND target_deps "${package_name}\;${package_version}")
        endif()
    endforeach()

    # Record 'pctk::Foo'-like shared private dependencies of shared library targets.
    #
    # Private shared library dependencies are listed in the target's
    # IMPORTED_LINK_DEPENDENT_LIBRARIES and used in rpath-link calculation.
    # We filter out static libraries and common platform targets, but include both SHARED and
    # INTERFACE libraries. INTERFACE libraries in most cases will be FooPrivate libraries.
    if(target_is_shared AND private_libs)
        foreach(lib IN LISTS private_libs)
            message(lib=${lib})
            if("${lib}" MATCHES "^pctk::(.*)")
                set(lib_namespaced "${lib}")
                set(lib "${CMAKE_MATCH_1}")

                get_target_property(lib_type "${lib_namespaced}" TYPE)
                if(NOT lib_type STREQUAL "STATIC_LIBRARY")
                    pctk_internal_get_package_name_of_target("${lib}" package_name)
                    pctk_internal_get_package_version_of_target("${lib}" package_version)
                    list(APPEND target_deps "${package_name}\;${package_version}")
                endif()
            endif()
        endforeach()
    endif()

    set_target_properties("${target}" PROPERTIES _pctk_target_deps "${target_deps}")
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Get the CMake package name that contains / exported the PCTK module target.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_get_package_name_of_target target package_name_out_var)
    # Get the package name from the module's target property.
    # If not set, fallback to a name based on the target name.
    #
    # TODO: Remove fallback once sufficient time has passed, aka all developers updated
    # their builds not to contain stale FooDependencies.cmakes files without the
    # _pctk_package_name property.
    set(package_name "")
    set(package_name_default "${INSTALL_CMAKE_NAMESPACE}${target}")
    set(target_namespaced "${PCTK_CMAKE_EXPORT_NAMESPACE}::${target}")
    message(target_namespaced=${target_namespaced})
    if(TARGET "${target_namespaced}")
        get_target_property(package_name_from_prop "${target_namespaced}" _pctk_package_name)
        if(package_name_from_prop)
            set(package_name "${package_name_from_prop}")
        endif()
    endif()
    message(package_name=${package_name})
    if(NOT package_name)
        message(WARNING
            "Could not find target ${target_namespaced} to query its package name. "
            "Defaulting to package name ${package_name_default}. Consider re-arranging the "
            "project structure to ensure the target exists by this point.")
        set(package_name "${package_name_default}")
    endif()

    set(${package_name_out_var} "${package_name}" PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Try to get the CMake package version of a PCTK target.
#
# Query the target's _pctk_package_version property, or try to read it from the CMake package version
# variable set from calling find_package(PCTK6${target}).
# Not all targets will have a find_package _VERSION variable, for example if the target is an
# executable.
# A heuristic is used to handle PCTKFooPrivate module targets.
# If no version can be found, fall back to ${PROJECT_VERSION} and issue a warning.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_get_package_version_of_target target package_version_out_var)
    # Try to get the version from the target.
    # Try the Private target first and if it doesn't exist, try the non-Private target later.
    if(TARGET "${PCTK_CMAKE_EXPORT_NAMESPACE}::${target}")
        get_target_property(package_version "${PCTK_CMAKE_EXPORT_NAMESPACE}::${target}" _pctk_package_version)
    endif()

    # Try to get the version from the corresponding package version variable.
    if(NOT package_version)
        set(package_version "${${PCTK_CMAKE_EXPORT_NAMESPACE}${target}_VERSION}")
    endif()

    # Try non-Private target.
    if(NOT package_version AND target MATCHES "(.*)Private$")
        set(target "${CMAKE_MATCH_1}")
    endif()

    if(NOT package_version AND TARGET "${PCTK_CMAKE_EXPORT_NAMESPACE}::${target}")
        get_target_property(package_version "${PCTK_CMAKE_EXPORT_NAMESPACE}::${target}" _pctk_package_version)
    endif()

    if(NOT package_version)
        set(package_version "${${PCTK_CMAKE_EXPORT_NAMESPACE}${target}_VERSION}")
    endif()

    if(NOT package_version)
        set(package_version "${PROJECT_VERSION}")
        if(FEATURE_developer_build)
            message(WARNING
                "Could not determine package version of target ${target}. "
                "Defaulting to project version ${PROJECT_VERSION}.")
        endif()
    endif()

    set(${package_version_out_var} "${package_version}" PARENT_SCOPE)
endfunction()

