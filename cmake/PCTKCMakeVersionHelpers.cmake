
# Returns the oldest CMake version for which NEW policies should be enabled.
# It can be older than the minimum supported or computed CMake version, as it
# is only used for policy settings. The currently running CMake must not be
# older than this version though (doing so will result in an error).
function(pctk_internal_get_min_new_policy_cmake_version out_var)
    # PCTK_MIN_NEW_POLICY_CMAKE_VERSION is set either in .cmake.conf or in
    # PCTKBuildInternalsExtras.cmake when building a child repo.
    set(lower_version "${PCTK_MIN_NEW_POLICY_CMAKE_VERSION}")
    set(${out_var} "${lower_version}" PARENT_SCOPE)
endfunction()


# Returns the latest CMake version for which NEW policies should be enabled.
# This cannot be less than the minimum CMake policy version or we will end up
# specifying a version range with the max less than the min.
function(pctk_internal_get_max_new_policy_cmake_version out_var)
    # PCTK_MAX_NEW_POLICY_CMAKE_VERSION is set either in .cmake.conf or in
    # PCTKBuildInternalsExtras.cmake when building a child repo.
    set(upper_version "${PCTK_MAX_NEW_POLICY_CMAKE_VERSION}")
    pctk_internal_get_min_new_policy_cmake_version(lower_version)
    if(upper_version VERSION_LESS lower_version)
        set(upper_version ${lower_version})
    endif()
    set(${out_var} "${upper_version}" PARENT_SCOPE)
endfunction()