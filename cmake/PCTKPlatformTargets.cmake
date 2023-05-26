# Defines the public PCTK::platform target, which serves as a dependency for all internal PCTK target
# as well as user projects consuming PCTK.
function(pctk_internal_setup_public_platform_target)
    pctk_internal_get_platform_definition_include_dir(
        install_interface_definition_dir
        build_interface_definition_dir)
    message(INSTALL_CMAKE_NAMESPACE=${INSTALL_CMAKE_NAMESPACE})
    ## PCTK::platform Target:
    add_library(platform INTERFACE)
    add_library(PCTK::platform ALIAS platform)
    add_library(${INSTALL_CMAKE_NAMESPACE}::platform ALIAS platform)
    target_include_directories(platform
        INTERFACE
        $<BUILD_INTERFACE:${build_interface_definition_dir}>
        $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>
        $<INSTALL_INTERFACE:${install_interface_definition_dir}>
        $<INSTALL_INTERFACE:${INSTALL_INCLUDEDIR}>)
    target_compile_definitions(platform INTERFACE ${PCTK_PLATFORM_DEFINITIONS})

    set_target_properties(platform PROPERTIES _pctk_package_version "${PROJECT_VERSION}")
    set_property(TARGET platform
        APPEND PROPERTY
        EXPORT_PROPERTIES "_pctk_package_version")

    # When building on android we need to link against the logging library
    # in order to satisfy linker dependencies. Both of these libraries are part of
    # the NDK.
    if(ANDROID)
        target_link_libraries(platform INTERFACE log)
    endif()

    if(PCTK_FEATURE_STDLIB_LIBCPP)
        target_compile_options(platform INTERFACE "$<$<COMPILE_LANGUAGE:CXX>:-stdlib=libc++>")
        set(libc_link_option "-stdlib=libc++")
        if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.18")
            set(libc_link_option "$<$<LINK_LANGUAGE:CXX>:-stdlib=libc++>")
        endif()
        target_link_options(platform INTERFACE "${libc_link_option}")
    endif()
    if(PCTK_FEATURE_NO_DIRENT_EXTERN_ACCESS)
        target_compile_options(platform INTERFACE "$<$<CXX_COMPILER_ID:GNU>:-mno-direct-extern-access>")
        target_compile_options(platform INTERFACE "$<$<CXX_COMPILER_ID:Clang>:-fno-direct-access-external-data>")
    endif()

    pctk_set_msvc_cplusplus_options(platform INTERFACE)

    # Propagate minimum C++ 17 via platform to PCTK consumers (apps), after the global features are computed.
    pctk_set_language_standards_interface_compile_features(platform)

    # By default enable utf8 sources for both PCTK and PCTK consumers. Can be opted out.
    pctk_enable_utf8_sources(platform)

    # By default enable unicode on WIN32 platforms for both PCTK and PCTK consumers. Can be opted out.
    pctk_internal_enable_unicode_defines(platform)

    # Generate a pkgconfig for pctk_platform.
    pctk_internal_generate_pkg_config_file(platform) ###TODO
endfunction()


function(pctk_internal_get_platform_definition_include_dir install_interface build_interface)
    # Used by consumers of prefix builds via INSTALL_INTERFACE (relative path).
    #    set(${install_interface} "${INSTALL_MKSPECSDIR}/${PCTK_QMAKE_TARGET_MKSPEC}" PARENT_SCOPE)

    # Used by pctkbase in prefix builds via BUILD_INTERFACE
    set(build_interface_base_dir "${CMAKE_CURRENT_LIST_DIR}/../mkspecs")

    # Used by pctkbase and consumers in non-prefix builds via BUILD_INTERFACE
    if(NOT PCTK_WILL_INSTALL)
        set(build_interface_base_dir "${PCTK_BUILD_DIR}/${INSTALL_MKSPECSDIR}")
    endif()

    #    get_filename_component(build_interface_dir "${build_interface_base_dir}/${PCTK_QMAKE_TARGET_MKSPEC}" ABSOLUTE)
    set(${build_interface} "${build_interface_dir}" PARENT_SCOPE)
endfunction()


pctk_internal_setup_public_platform_target()