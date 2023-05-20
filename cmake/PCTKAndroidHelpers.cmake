

#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_android_apply_arch_suffix target)
    get_target_property(target_type ${target} TYPE)
    if (target_type STREQUAL "SHARED_LIBRARY" OR target_type STREQUAL "MODULE_LIBRARY")
        set_property(TARGET "${target}" PROPERTY SUFFIX "_${CMAKE_ANDROID_ARCH_ABI}.so")
    elseif (target_type STREQUAL "STATIC_LIBRARY")
        set_property(TARGET "${target}" PROPERTY SUFFIX "_${CMAKE_ANDROID_ARCH_ABI}.a")
    endif()
endfunction()