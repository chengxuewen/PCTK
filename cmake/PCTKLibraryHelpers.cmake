
#-----------------------------------------------------------------------------------------------------------------------
# pctk_internal_get_add_library_keywords macro
#-----------------------------------------------------------------------------------------------------------------------
macro(pctk_internal_get_add_library_keywords option_args single_args multi_args)
    set(${option_args}
        STATIC
        EXCEPTIONS
        HEADER_LIBRARY
        INTERNAL_LIBRARY
        DISABLE_TOOLS_EXPORT
        SKIP_DEPENDS_INCLUDE
        NO_SYNC_PCTK
        NO_LIBRARY_HEADERS
        NO_PRIVATE_LIBRARY
        NO_CONFIG_HEADER_FILE
        NO_ADDITIONAL_TARGET_INFO)
    set(${single_args}
        LIBRARY_INCLUDE_NAME
        LIBRARY_INTERFACE_NAME
        CONFIG_LIBRARY_NAME
        PRECOMPILED_HEADER
        CONFIGURE_FILE_PATH
        CPP_EXPORT_HEADER_BASE_NAME
        EXTERNAL_HEADERS_DIR
        CONFIGURE_RESET
        ${PCTK_DEFAULT_TARGET_INFO_ARGS})
    set(${multi_args}
        EXTRA_CMAKE_FILES
        EXTRA_CMAKE_INCLUDES
        NO_PCH_SOURCES
        EXTERNAL_HEADERS
        ${PCTK_DEFAULT_PUBLIC_ARGS}
        ${PCTK_DEFAULT_PRIVATE_ARGS})
endmacro()


#-----------------------------------------------------------------------------------------------------------------------
# This is the main entry function for creating a PCTK library, that typically consists of a library, public header files,
# private header files and configurable features.
#
# A CMake target with the specified target parameter is created. If the current source directory has a configure.cmake
# file, then that is also processed for feature definition and testing. Any features defined as well as any features
# coming from dependencies to this library are imported into the scope of the calling feature.
#
# Target is without leading "PCTK". So e.g. the "PCTKCore" library has the target "Core".
#
# Options:
#   NO_ADDITIONAL_TARGET_INFO
#     Don't generate a PCTK*AdditionalTargetInfo.cmake file.
#     The caller is responsible for creating one.
#
#   LIBRARY_INTERFACE_NAME
#     The custom name of the library interface. This name is used as a part of the include paths
#     associated with the library and other interface names. The default value is the target name.
#     If the INTERNAL_MODULE option is specified, LIBRARY_INTERFACE_NAME is not specified and the
#     target name ends with the suffix 'Private', the LIBRARY_INTERFACE_NAME value defaults to the
#     non-suffixed target name, e.g.:
#        For the SomeInternalModulePrivate target, the LIBRARY_INTERFACE_NAME will be SomeInternalModule
#
#   HEADER_LIBRARY
#     Creates an interface library instead of following the PCTK configuration default. Mutually
#     exclusive with STATIC.
#
#   STATIC
#     Creates a static library instead of following the PCTK configuration default. Mutually exclusive with HEADER_LIBRARY.
#
#   EXTERNAL_HEADERS
#     A explicit list of non PCTK headers (like 3rdparty) to be installed.
#     Note this option overrides install headers used as PUBLIC_HEADER by cmake install(TARGET).
#
#   EXTERNAL_HEADERS_DIR
#     A library directory with non pctk headers (like 3rdparty) to be installed.
#     Note this option overrides install headers used as PUBLIC_HEADER by cmake install(TARGET)
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_add_library target)
    pctk_internal_get_add_library_keywords(library_option_args library_single_args library_multi_args)
    pctk_parse_all_arguments(arg "pctk_internal_add_library"
        "${library_option_args}"
        "${library_single_args}"
        "${library_multi_args}"
        ${ARGN})

    set(is_internal_library FALSE)
    if(arg_INTERNAL_LIBRARY)
        set(is_internal_library TRUE)
        set(arg_INTERNAL_LIBRARY "INTERNAL_LIBRARY")
        set(arg_NO_PRIVATE_LIBRARY TRUE)
        # Assume the interface name of the internal library should be the library name without the 'Private' suffix.
        if(NOT arg_LIBRARY_INTERFACE_NAME)
            if(target MATCHES "(.*)Private$")
                set(arg_LIBRARY_INTERFACE_NAME "${CMAKE_MATCH_1}")
            else()
                message(WARNING "The internal library target should end with the 'Private' suffix.")
            endif()
        endif()
        message(arg_INTERNAL_LIBRARY=${arg_INTERNAL_LIBRARY})
        message(arg_LIBRARY_INTERFACE_NAME=${arg_LIBRARY_INTERFACE_NAME})
    else()
        unset(arg_INTERNAL_LIBRARY)
    endif()

    if(NOT arg_LIBRARY_INTERFACE_NAME)
        set(arg_LIBRARY_INTERFACE_NAME "${target}")
    endif()

    if(NOT arg_CONFIGURE_RESET)
        set(arg_CONFIGURE_RESET OFF)
    endif()

    ### Define Targets:
    if(arg_HEADER_LIBRARY)
        set(type_to_create INTERFACE)
    elseif(arg_STATIC)
        set(type_to_create STATIC)
    else()
        set(type_to_create "") # Use default depending on PCTK configuration.
    endif()
    message(type_to_create=${type_to_create})

    # add target library. If type_to_create is empty, it will be set afterwards
    pctk_internal_add_library("${target}" ${type_to_create} ${arg_SOURCES})
    pctk_internal_mark_as_internal_library("${target}")
    get_target_property(target_type ${target} TYPE)
    # Distinguish target_type
    set(is_interface_lib 0)
    set(is_shared_lib 0)
    set(is_static_lib 0)
    if(target_type STREQUAL "INTERFACE_LIBRARY")
        set(is_interface_lib 1)
    elseif(target_type STREQUAL "STATIC_LIBRARY")
        set(is_static_lib 1)
    elseif(target_type STREQUAL "SHARED_LIBRARY")
        set(is_shared_lib 1)
    else()
        message(FATAL_ERROR "Invalid target type '${target_type}' for PCTK library '${target}'")
    endif()

    if(NOT arg_NO_SYNC_PCTK AND NOT arg_NO_LIBRARY_HEADERS AND arg_LIBRARY_INCLUDE_NAME)
        # pctk_internal_library_info uses this property if it's set, so it must be specified before the
        # pctk_internal_library_info call.
        set_target_properties(${target} PROPERTIES _pctk_library_include_name ${arg_LIBRARY_INCLUDE_NAME})
    endif()
    set_target_properties(${target} PROPERTIES
        _pctk_library_interface_name "${arg_LIBRARY_INTERFACE_NAME}"
        _pctk_package_version "${PROJECT_VERSION}"
        _pctk_package_name "${INSTALL_CMAKE_NAMESPACE}${target}")
    set(export_properties
        "_pctk_library_interface_name"
        "_pctk_package_version"
        "_pctk_package_name")
    if(NOT is_internal_library)
        set_target_properties(${target} PROPERTIES __pctk_is_public_library TRUE)
        list(APPEND export_properties "__pctk_is_public_library")
        if(NOT ${arg_NO_PRIVATE_LIBRARY})
            set_target_properties(${target} PROPERTIES _pctk_private_library_target_name "${target}Private")
            list(APPEND export_properties "_pctk_private_library_target_name")
        endif()
    endif()
    set_property(TARGET ${target} APPEND PROPERTY EXPORT_PROPERTIES "${export_properties}")

    pctk_internal_library_info(library "${target}")
    pctk_internal_add_repo_known_library("${target}")

    if(arg_INTERNAL_LIBRARY)
        set_target_properties(${target} PROPERTIES _pctk_is_internal_library TRUE)
        set_property(TARGET ${target} APPEND PROPERTY EXPORT_PROPERTIES _pctk_is_internal_library)
    endif()

    if(NOT arg_CONFIG_LIBRARY_NAME)
        set(arg_CONFIG_LIBRARY_NAME "${target}")
    endif()
    set(library_config_header "pctk${arg_CONFIG_LIBRARY_NAME}Config.h")
    set(library_config_private_header "pctk${arg_CONFIG_LIBRARY_NAME}Config_p.h")

    # Library define needs to take into account the config library name.
    string(TOUPPER "${arg_CONFIG_LIBRARY_NAME}" library_define_infix)
    string(REPLACE "-" "_" library_define_infix "${library_define_infix}")
    string(REPLACE "." "_" library_define_infix "${library_define_infix}")
    set(property_prefix "INTERFACE_")
    if(NOT arg_HEADER_LIBRARY)
        set(property_prefix "")
    endif()
    if(arg_INTERNAL_LIBRARY)
        string(APPEND arg_CONFIG_LIBRARY_NAME "Private")
    endif()
    set_target_properties(${target} PROPERTIES _pctk_config_library_name "${arg_CONFIG_LIBRARY_NAME}")
    set_property(TARGET "${target}" APPEND PROPERTY EXPORT_PROPERTIES _pctk_config_library_name)

    set(is_framework 0)
    if(PCTK_FEATURE_FRAMEWORK AND NOT ${arg_HEADER_LIBRARY} AND NOT ${arg_STATIC})
        set(is_framework 1)
        set_target_properties(${target} PROPERTIES
            FRAMEWORK TRUE
            FRAMEWORK_VERSION "A" # Not based on PCTK major version
            MACOSX_FRAMEWORK_IDENTIFIER org.pctk-project.${library}
            MACOSX_FRAMEWORK_BUNDLE_VERSION ${PROJECT_VERSION}
            MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR})
        pctk_internal_get_framework_info(fw ${target})
    endif()

    if(NOT PCTK_FEATURE_NO_DIRENT_EXTERN_ACCESS AND PCTK_FEATURE_REDUCE_RELOCATIONS AND UNIX AND NOT is_interface_lib)
        # On x86 and x86-64 systems with ELF binaries (especially Linux), due to a new optimization in GCC 5.x in
        # combination with a recent version of GNU binutils, compiling PCTK applications with -fPIE is no longer enough.
        # Applications now need to be compiled with the -fPIC option if the PCTK option \"reduce relocations\" is active.
        target_compile_options(${target} INTERFACE -fPIC)
        if(GCC AND is_shared_lib)
            target_link_options(${target} PRIVATE LINKER:-Bsymbolic-functions)
        endif()
    endif()

    if((PCTK_FEATURE_LTCG OR CMAKE_INTERPROCEDURAL_OPTIMIZATION) AND GCC AND is_static_lib)
        # CMake <= 3.19 appends -fno-fat-lto-objects for all library types if CMAKE_INTERPROCEDURAL_OPTIMIZATION is
        # enabled. Static libraries need the opposite compiler option.
        # (https://gitlab.kitware.com/cmake/cmake/-/issues/21696)
        target_compile_options(${target} PRIVATE -ffat-lto-objects)
    endif()

    pctk_internal_add_target_aliases("${target}")
    pctk_skip_warnings_are_errors_when_repo_unclean("${target}")
    pctk_internal_apply_strict_cpp("${target}")

    # No need to compile PCTK_IMPORT_PLUGIN-containing files for non-executables.
    if(is_static_lib)
        pctk_internal_disable_static_default_plugins("${target}")
    endif()

    # Add Private target to link against the private headers:
    set(target_private "${target}Private")
    if(NOT ${arg_NO_PRIVATE_LIBRARY})
        add_library("${target_private}" INTERFACE)
        pctk_internal_add_target_aliases("${target_private}")
        set_target_properties(${target_private} PROPERTIES
            _pctk_config_library_name ${arg_CONFIG_LIBRARY_NAME}Private
            _pctk_package_version "${PROJECT_VERSION}"
            _pctk_package_name "${INSTALL_CMAKE_NAMESPACE}${target}"
            _pctk_is_private_library TRUE
            _pctk_public_library_target_name "${target}")
        set(export_properties
            "_pctk_config_library_name"
            "_pctk_package_version"
            "_pctk_package_name"
            "_pctk_is_private_library"
            "_pctk_public_library_target_name")
        set_property(TARGET "${target_private}" APPEND PROPERTY EXPORT_PROPERTIES "${export_properties}")
    endif()

    if(NOT arg_HEADER_LIBRARY)
        set_target_properties(${target} PROPERTIES
            LIBRARY_OUTPUT_DIRECTORY "${PCTK_BUILD_DIR}/${INSTALL_LIBDIR}"
            RUNTIME_OUTPUT_DIRECTORY "${PCTK_BUILD_DIR}/${INSTALL_BINDIR}"
            ARCHIVE_OUTPUT_DIRECTORY "${PCTK_BUILD_DIR}/${INSTALL_LIBDIR}"
            VERSION ${PROJECT_VERSION}
            SOVERSION ${PROJECT_VERSION_MAJOR})
        pctk_set_target_info_properties(${target} ${ARGN})
        pctk_handle_multi_config_output_dirs("${target}")

        if(NOT PCTK_BUILD_SHARED_LIBS AND PCTK_SYSTEM_LINUX)
            # Horrible workaround for static build failures due to incorrect static library link order. By increasing
            # the multiplicity to 3, each library cycle will be repeated 3 times on the link line, reducing the
            # probability of undefined symbols at link time.
            # These failures are only observed on Linux with the ld linker (not sure about ld.gold).
            # Allow opting out and modifying the value via cache value,  in case if we urgently need to increase it
            # without waiting for the PCTK change to propagate to other dependent repos.
            # The proper fix will be to get rid of the cycles in the future.
            set(default_link_cycle_multiplicity "3")
            if(DEFINED PCTK_LINK_CYCLE_MULTIPLICITY)
                set(default_link_cycle_multiplicity "${PCTK_LINK_CYCLE_MULTIPLICITY}")
            endif()
            if(default_link_cycle_multiplicity)
                set_property(TARGET "${target}" PROPERTY LINK_INTERFACE_MULTIPLICITY "${default_link_cycle_multiplicity}")
            endif()
        endif()

        if(arg_SKIP_DEPENDS_INCLUDE)
            set_target_properties(${target} PROPERTIES _pctk_library_skip_depends_include TRUE)
            set_property(TARGET "${target}" APPEND PROPERTY EXPORT_PROPERTIES _pctk_library_skip_depends_include)
        endif()
        if(is_framework)
            set_target_properties(${target} PROPERTIES OUTPUT_NAME ${fw_name})
        else()
            set_target_properties(${target} PROPERTIES
                OUTPUT_NAME "${INSTALL_CMAKE_NAMESPACE}${library_interface_name}${PCTK_LIBINFIX}")
        endif()

        pctk_set_common_target_properties(${target})

        if(WIN32 AND PCTK_BUILD_SHARED_LIBS)
            pctk_internal_generate_win32_rc_file(${target})
        endif()
    endif()

    # Library headers:
    set_property(TARGET "${target}" APPEND PROPERTY EXPORT_PROPERTIES _pctk_library_has_headers)
    if(${arg_NO_LIBRARY_HEADERS} OR ${arg_NO_SYNC_PCTK})
        set_target_properties("${target}" PROPERTIES _pctk_library_has_headers OFF)
    else()
        set_property(TARGET ${target} APPEND PROPERTY EXPORT_PROPERTIES _pctk_library_include_name)
        set_target_properties("${target}" PROPERTIES _pctk_library_include_name "${library_include_name}")

        # Use PCTK_BUILD_DIR for the sync pctk.
        pctk_internal_sync_headers(${target})
        set_target_properties("${target}" PROPERTIES _pctk_library_has_headers ON)
        #        message(library_build_interface_include_dir=${library_build_interface_include_dir})

        if(arg_EXTERNAL_HEADERS)
            list(APPEND library_headers_public ${arg_EXTERNAL_HEADERS})
        endif()

        set_property(TARGET ${target} APPEND PROPERTY _pctk_library_timestamp_dependencies "${library_headers_public}")

        # We should not generate export headers if library is defined as pure STATIC.
        # Static libraries don't need to export their symbols, and corner cases when sources are
        # also used in shared libraries, should be handled manually.
        if(arg_GENERATE_CPP_EXPORTS AND NOT arg_STATIC)
            if(arg_CPP_EXPORT_HEADER_BASE_NAME)
                set(cpp_export_header_base_name "CPP_EXPORT_HEADER_BASE_NAME;${arg_CPP_EXPORT_HEADER_BASE_NAME}")
            endif()
            if(arg_GENERATE_PRIVATE_CPP_EXPORTS)
                set(generate_private_cpp_export "GENERATE_PRIVATE_CPP_EXPORTS")
            endif()
            pctk_internal_generate_cpp_global_exports(${target} ${library_define_infix}
                "${cpp_export_header_base_name}"
                "${generate_private_cpp_export}")
        endif()

        set(library_depends_header "${library_build_interface_include_dir}/pctk${target}Depends.h")
        set(library_header "${CMAKE_CURRENT_SOURCE_DIR}/include/${library}")
        if(NOT EXISTS "${library_header}")
            set(once_macro "_PCTK${library_upper}_LIBRARY_H")
            string(APPEND contents "#ifndef ${once_macro}\n#define ${once_macro}\n\n\n#endif\n")
            file(GENERATE OUTPUT "${library_header}" CONTENT "${contents}")
        endif()
        list(APPEND library_headers_public "${CMAKE_CURRENT_SOURCE_DIR}/include/${library}")
        if(is_framework)
            if(NOT is_interface_lib)
                set(public_headers_to_copy "${library_headers_public}" "${library_depends_header}")
                pctk_copy_framework_headers(${target} PUBLIC "${public_headers_to_copy}")
                pctk_copy_framework_headers(${target} PRIVATE "${library_headers_private}")
            endif()
        else()
            set_property(TARGET ${target} APPEND PROPERTY PUBLIC_HEADER "${library_headers_public}")
            set_property(TARGET ${target} APPEND PROPERTY PUBLIC_HEADER ${library_depends_header})
            set_property(TARGET ${target} APPEND PROPERTY PRIVATE_HEADER "${library_headers_private}")
        endif()
        if(NOT ${arg_HEADER_LIBRARY})
            set_property(TARGET "${target}" PROPERTY MODULE_HEADER "${library_build_interface_include_dir}/${library_include_name}")
        endif()
    endif()

    if(NOT arg_HEADER_LIBRARY)
        # Plugin types associated to a library
        if(NOT "x${arg_PLUGIN_TYPES}" STREQUAL "x")
            # Reset the variable containing the list of plugins for the given plugin type
            foreach(plugin_type ${arg_PLUGIN_TYPES})
                pctk_get_sanitized_plugin_type("${plugin_type}" plugin_type)
                set_property(TARGET "${target}" APPEND PROPERTY LIBRARY_PLUGIN_TYPES "${plugin_type}")
                pctk_internal_add_pctk_repo_known_plugin_types("${plugin_type}")
            endforeach()

            # Export the plugin types.
            set_property(TARGET ${target} APPEND PROPERTY EXPORT_PROPERTIES LIBRARY_PLUGIN_TYPES)
        endif()
    endif()

    pctk_internal_library_deprecation_level(deprecation_define)

    if(NOT arg_HEADER_LIBRARY)
        #        pctk_autogen_tools_initial_setup(${target}) ###TODO:rcc autogen?
    endif()

    set(private_includes
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>"
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>"
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>"
        ${arg_INCLUDE_DIRECTORIES})

    set(public_includes "")
    set(public_headers_list "public_includes")
    if(is_framework)
        set(public_headers_list "private_includes")
    endif()

    # Make sure the BUILD_INTERFACE include paths come before the framework headers, so that the
    # the compiler prefers the build dir includes.
    #
    # Make sure to add non-framework "build_dir/include" as an include path for moc to find the
    # currently built library headers. qmake does this too.
    # Framework-style include paths are found by moc when pctkAutoxx.xx detects frameworks by
    # looking at an include path and detecting a "PCTKFoo.framework/Headers" path.
    # Make sure to create such paths for both the the BUILD_INTERFACE and the INSTALL_INTERFACE.
    #
    # Only add syncpctk headers if they exist.
    # This handles cases like QmlDevToolsPrivate which do not have their own headers, but borrow them
    # from another library.
    if(NOT arg_NO_SYNC_PCTK AND NOT arg_NO_LIBRARY_HEADERS)
        # Don't include private headers unless they exist, aka syncpctk created them.
        if(library_headers_private)
            list(APPEND private_includes
                "$<BUILD_INTERFACE:${library_build_interface_versioned_include_dir}>"
                "$<BUILD_INTERFACE:${library_build_interface_versioned_inner_include_dir}>")
        endif()

        list(APPEND public_includes
            # For the syncpctk headers
            "$<BUILD_INTERFACE:${repo_build_interface_include_dir}>"
            "$<BUILD_INTERFACE:${library_build_interface_include_dir}>")
        #        message(private_includes=${private_includes})
        #        message(library_headers_private=${library_headers_private})
    endif()

    if(is_framework)
        set(fw_install_dir "${INSTALL_LIBDIR}/${fw_dir}")
        set(fw_install_header_dir "${INSTALL_LIBDIR}/${fw_header_dir}")
        set(fw_output_header_dir "${PCTK_BUILD_DIR}/${fw_install_header_dir}")
        list(APPEND public_includes
            # Add the framework Headers subdir, so that non-framework-style includes work. The
            # BUILD_INTERFACE Headers symlink was previously claimed not to exist at the relevant
            # time, and a fully specified Header path was used instead. This doesn't seem to be a
            # problem anymore.
            "$<BUILD_INTERFACE:${fw_output_header_dir}>"
            "$<INSTALL_INTERFACE:${fw_install_header_dir}>"

            # Add the lib/Foo.framework dir as an include path to let CMake generate
            # the -F compiler flag for framework-style includes to work.
            # Make sure it is added AFTER the lib/Foo.framework/Headers include path,
            # to mitigate issues like PCTKBUG-101718 and PCTKBUG-101775 where an include like
            # #include <pctk_core> might cause moc to include the pctk_core framework shared library
            # instead of the actual header.
            "$<INSTALL_INTERFACE:${fw_install_dir}>")
    endif()

    if(NOT arg_NO_LIBRARY_HEADERS AND NOT arg_NO_SYNC_PCTK)
        # For the syncpctk headers
        list(APPEND ${public_headers_list} "$<INSTALL_INTERFACE:${library_install_interface_include_dir}>")

        # To support finding PCTK library includes that are not installed into the main PCTK prefix.
        # Use case: A PCTK library built by Conan installed into a prefix other than the main prefix.
        # This does duplicate the include path set on PCTK::platform target, but CMake is smart
        # enough to deduplicate the include paths on the command line.
        # Frameworks are automatically handled by CMake in cmLocalGenerator::GetIncludeFlags()
        # by additionally passing the 'PCTKFoo.framework/..' dir with an -iframework argument.
        list(APPEND ${public_headers_list} "$<INSTALL_INTERFACE:${INSTALL_INCLUDEDIR}>")
    endif()
    list(APPEND ${public_headers_list} ${arg_PUBLIC_INCLUDE_DIRECTORIES})

    set(header_library)
    if(arg_HEADER_LIBRARY)
        set(header_library "HEADER_LIBRARY")

        # Provide a *_timestamp target that can be used to trigger the build of custom_commands.
        set(timestamp_file "${CMAKE_CURRENT_BINARY_DIR}/timestamp")
        add_custom_command(OUTPUT "${timestamp_file}"
            COMMAND ${CMAKE_COMMAND} -E touch "${timestamp_file}"
            DEPENDS "$<TARGET_PROPERTY:${target},_pctk_library_timestamp_dependencies>"
            VERBATIM)
        add_custom_target(${target}_timestamp ALL DEPENDS "${timestamp_file}")
    endif()

    set(defines_for_extend_target "")

    if(NOT arg_HEADER_LIBRARY)
        list(APPEND defines_for_extend_target
            PCTK_NO_CAST_TO_ASCII PCTK_ASCII_CAST_WARNINGS
            PCTK_DEPRECATED_WARNINGS
            PCTK_BUILDING_PCTK
            PCTK_BUILD_${library_define_infix}_LIB ### FIXME: use PCTK_BUILD_ADDON for Add-ons or remove if we don't have add-ons anymore
            ${deprecation_define})
    endif()

    # pctk_internal_add_repo_local_defines("${target}")
    pctk_internal_extend_target("${target}"
        ${header_library}
        SOURCES
        ${arg_SOURCES}
        INCLUDE_DIRECTORIES
        ${private_includes}
        PUBLIC_INCLUDE_DIRECTORIES
        ${public_includes}
        PUBLIC_DEFINES
        ${arg_PUBLIC_DEFINES}
        DEFINES
        ${arg_DEFINES}
        ${defines_for_extend_target}
        PUBLIC_LIBRARIES ${arg_PUBLIC_LIBRARIES}
        LIBRARIES ${arg_LIBRARIES}
        PRIVATE_LIBRARY_INTERFACE ${arg_PRIVATE_LIBRARY_INTERFACE}
        FEATURE_DEPENDENCIES ${arg_FEATURE_DEPENDENCIES}
        COMPILE_OPTIONS ${arg_COMPILE_OPTIONS}
        PUBLIC_COMPILE_OPTIONS ${arg_PUBLIC_COMPILE_OPTIONS}
        LINK_OPTIONS ${arg_LINK_OPTIONS}
        PUBLIC_LINK_OPTIONS ${arg_PUBLIC_LINK_OPTIONS}
        PRECOMPILED_HEADER ${arg_PRECOMPILED_HEADER}
        NO_PCH_SOURCES ${arg_NO_PCH_SOURCES})

    # The public library define is not meant to be used when building the library itself, it's only meant to be used for
    # consumers of the library, thus we can't use pctk_internal_extend_target()'s PUBLIC_DEFINES option.
    target_compile_definitions(${target} INTERFACE PCTK_${library_define_infix}_LIB)

    if(NOT arg_EXCEPTIONS AND NOT ${arg_HEADER_LIBRARY})
        pctk_internal_set_exceptions_flags("${target}" FALSE)
    elseif(arg_EXCEPTIONS)
        pctk_internal_set_exceptions_flags("${target}" TRUE)
    endif()

    set(configure_file "${CMAKE_CURRENT_SOURCE_DIR}/configure.cmake")
    if(arg_CONFIGURE_FILE_PATH)
        set(configure_file "${arg_CONFIGURE_FILE_PATH}")
    endif()
    if(EXISTS "${configure_file}" AND NOT arg_NO_CONFIG_HEADER_FILE)
        pctk_configure_library_begin(
            LIBRARY "${target}"
            PUBLIC_FILE "include/${library_config_header}"
            PRIVATE_FILE "include/private/${library_config_private_header}"
            PUBLIC_DEPENDENCIES ${arg_FEATURE_DEPENDENCIES}
            PRIVATE_DEPENDENCIES ${arg_FEATURE_DEPENDENCIES})
        pctk_configure_reset(${arg_CONFIGURE_RESET})
        include(${configure_file})
        pctk_configure_library_end("${target}")

        set_property(TARGET "${target}" APPEND PROPERTY
            PUBLIC_HEADER "${CMAKE_CURRENT_BINARY_DIR}/include/${library_config_header}")
        set_property(TARGET "${target}" APPEND PROPERTY
            PRIVATE_HEADER "${CMAKE_CURRENT_BINARY_DIR}/include/private/${library_config_private_header}")
    endif()

    ###TODO:Del
    if(NOT arg_HEADER_LIBRARY)
        if(DEFINED library_headers_private)
            pctk_internal_add_linker_version_script("${target}" PRIVATE_HEADERS ${library_headers_private})
        else()
            pctk_internal_add_linker_version_script("${target}")
        endif()
    endif()

    # Handle injections. Aka create forwarding headers for certain headers that have been automatically generated in
    # the build dir (for example pctkCoreConfig.h, pctkCoreConfigPrivate.h, etc)
    # library_headers_injections come from the pctk_internal_sync_headers() call.
    # extra_library_injections come from the pctk_configure_library_end() call.
    set(final_injections "")
    if(library_headers_injections)
        string(APPEND final_injections "${library_headers_injections} ")
    endif()
    if(extra_library_injections)
        string(APPEND final_injections "${extra_library_injections} ")
    endif()
    #    message(final_injections=${final_injections})
    if(final_injections)
        pctk_install_injections(${target} "${PCTK_BUILD_DIR}" "${PCTK_INSTALL_DIR}" ${final_injections})
    endif()

    # Handle creation of cmake files for consumers of find_package().
    set(path_suffix "${INSTALL_CMAKE_NAMESPACE}${target}")
    pctk_path_join(config_build_dir ${PCTK_CONFIG_BUILD_DIR} ${path_suffix})
    pctk_path_join(config_install_dir ${PCTK_CONFIG_INSTALL_DIR} ${path_suffix})

    set(extra_cmake_files)
    set(extra_cmake_includes)
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/${INSTALL_CMAKE_NAMESPACE}${target}Macros.cmake")
        list(APPEND extra_cmake_files "${CMAKE_CURRENT_LIST_DIR}/${INSTALL_CMAKE_NAMESPACE}${target}Macros.cmake")
        list(APPEND extra_cmake_includes "${INSTALL_CMAKE_NAMESPACE}${target}Macros.cmake")
    endif()
    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/${INSTALL_CMAKE_NAMESPACE}${target}ConfigExtras.cmake.in")
        if(target STREQUAL Core)
            set(extra_cmake_code "")
            # Add some variables for compatibility with PCTK config files.
            if(PCTK_FEATURE_reduce_exports)
                string(APPEND pctkcore_extra_cmake_code "set(PCTK_VISIBILITY_AVAILABLE TRUE)")
            endif()
            if(PCTK_LIBINFIX)
                string(APPEND pctkcore_extra_cmake_code "set(PCTK_LIBINFIX \"${PCTK_LIBINFIX}\")")
            endif()

            # Store whether find_package(PCTKFoo) should succeed if PCTKFooTools is missing.
            if(PCTK_ALLOW_MISSING_TOOLS_PACKAGES)
                string(APPEND pctkcore_extra_cmake_code "set(PCTK_ALLOW_MISSING_TOOLS_PACKAGES TRUE)")
            endif()
        endif()

        configure_file("${CMAKE_CURRENT_LIST_DIR}/${INSTALL_CMAKE_NAMESPACE}${target}ConfigExtras.cmake.in"
            "${config_build_dir}/${INSTALL_CMAKE_NAMESPACE}${target}ConfigExtras.cmake"
            @ONLY)
        list(APPEND extra_cmake_files "${config_build_dir}/${INSTALL_CMAKE_NAMESPACE}${target}ConfigExtras.cmake")
        list(APPEND extra_cmake_includes "${INSTALL_CMAKE_NAMESPACE}${target}ConfigExtras.cmake")
    endif()

    foreach(cmake_file IN LISTS arg_EXTRA_CMAKE_FILES)
        get_filename_component(basename ${cmake_file} NAME)
        file(COPY ${cmake_file} DESTINATION ${config_build_dir})
        list(APPEND extra_cmake_files "${config_build_dir}/${basename}")
    endforeach()
    list(APPEND extra_cmake_includes ${arg_EXTRA_CMAKE_INCLUDES})

    set(extra_cmake_code "")
    pctk_internal_get_min_new_policy_cmake_version(min_new_policy_version)
    pctk_internal_get_max_new_policy_cmake_version(max_new_policy_version)
    include(CMakePackageConfigHelpers)
    configure_package_config_file(
        "${PCTK_CMAKE_DIR}/PCTKModuleConfig.cmake.in"
        "${config_build_dir}/${INSTALL_CMAKE_NAMESPACE}${target}Config.cmake"
        INSTALL_DESTINATION "${config_install_dir}")

    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/${INSTALL_CMAKE_NAMESPACE}${target}BuildInternals.cmake")
        configure_file("${CMAKE_CURRENT_LIST_DIR}/${INSTALL_CMAKE_NAMESPACE}${target}BuildInternals.cmake"
            "${config_build_dir}/${INSTALL_CMAKE_NAMESPACE}${target}BuildInternals.cmake"
            @ONLY)
        list(APPEND extra_cmake_files "${config_build_dir}/${INSTALL_CMAKE_NAMESPACE}${target}BuildInternals.cmake")
    endif()

    write_basic_package_version_file(
        "${config_build_dir}/${INSTALL_CMAKE_NAMESPACE}${target}ConfigVersionImpl.cmake"
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY AnyNewerVersion)
    pctk_internal_write_pctk_package_version_file(
        "${INSTALL_CMAKE_NAMESPACE}${target}"
        "${config_build_dir}/${INSTALL_CMAKE_NAMESPACE}${target}ConfigVersion.cmake")
    pctk_install(FILES
        "${config_build_dir}/${INSTALL_CMAKE_NAMESPACE}${target}Config.cmake"
        "${config_build_dir}/${INSTALL_CMAKE_NAMESPACE}${target}ConfigVersion.cmake"
        "${config_build_dir}/${INSTALL_CMAKE_NAMESPACE}${target}ConfigVersionImpl.cmake"
        ${extra_cmake_files}
        DESTINATION "${config_install_dir}"
        COMPONENT Devel)

    file(COPY ${extra_cmake_files} DESTINATION "${config_build_dir}")
    set(exported_targets ${target})
    if(NOT ${arg_NO_PRIVATE_LIBRARY})
        list(APPEND exported_targets ${target_private})
    endif()
    set(export_name "${INSTALL_CMAKE_NAMESPACE}${target}Targets")
    if(arg_EXTERNAL_HEADERS_DIR)
        pctk_install(DIRECTORY "${arg_EXTERNAL_HEADERS_DIR}/" DESTINATION "${library_install_interface_include_dir}")
        get_target_property(public_header_backup ${target} PUBLIC_HEADER)
        set_property(TARGET ${target} PROPERTY PUBLIC_HEADER "")
    endif()

    #    message(exported_targets=${exported_targets})
    #    message(library_install_interface_private_include_dir=${library_install_interface_private_include_dir})
    #    message(library_install_interface_include_dir=${library_install_interface_include_dir})
    pctk_install(TARGETS ${exported_targets}
        EXPORT ${export_name}
        RUNTIME DESTINATION ${INSTALL_BINDIR}
        LIBRARY DESTINATION ${INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${INSTALL_LIBDIR}
        FRAMEWORK DESTINATION ${INSTALL_LIBDIR}
        PRIVATE_HEADER DESTINATION "${library_install_interface_private_include_dir}"
        PUBLIC_HEADER DESTINATION "${library_install_interface_include_dir}")
    if(arg_EXTERNAL_HEADERS_DIR)
        set_property(TARGET ${target} PROPERTY PUBLIC_HEADER ${public_header_backup})
        unset(public_header_backup)
    endif()

    if(BUILD_SHARED_LIBS)
        pctk_apply_rpaths(TARGET "${target}" INSTALL_PATH "${INSTALL_LIBDIR}" RELATIVE_RPATH)
        pctk_internal_apply_staging_prefix_build_rpath_workaround()
    endif()

    if(ANDROID AND NOT arg_HEADER_LIBRARY)
        # Record install library location so it can be accessed by
        # pctk_internal_android_dependencies without having to specify it again.
        set_target_properties(${target} PROPERTIES PCTK_ANDROID_MODULE_INSTALL_DIR ${INSTALL_LIBDIR})
    endif()

    pctk_install(EXPORT ${export_name}
        NAMESPACE ${PCTK_CMAKE_EXPORT_NAMESPACE}::
        DESTINATION ${config_install_dir})

    if(NOT arg_NO_ADDITIONAL_TARGET_INFO)
        #        message(target=${target})
        #        message(exported_targets=${exported_targets})
        #        message(config_install_dir=${config_install_dir})
        #        message(INSTALL_CMAKE_NAMESPACE=${INSTALL_CMAKE_NAMESPACE})
        pctk_internal_export_additional_targets_file(
            TARGETS ${exported_targets}
            EXPORT_NAME_PREFIX "${INSTALL_CMAKE_NAMESPACE}${target}"
            CONFIG_INSTALL_DIR "${config_install_dir}")
    endif()

    pctk_internal_export_modern_cmake_config_targets_file(
        TARGETS ${exported_targets}
        EXPORT_NAME_PREFIX ${INSTALL_CMAKE_NAMESPACE} ${target}
        CONFIG_INSTALL_DIR "${config_install_dir}")

    ### fixme: cmake is missing a built-in variable for this. We want to apply it only to modules and plugins
    # that belong to PCTK.
    if(NOT arg_HEADER_LIBRARY)
        pctk_internal_add_link_flags_no_undefined("${target}")
    endif()

    set(interface_includes "")

    # Handle cases like QmlDevToolsPrivate which do not have their own headers, but rather borrow them
    # from another library.
    if(NOT arg_NO_SYNC_PCTK)
        list(APPEND interface_includes "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>")

        # syncpctk.pl does not create a private header directory like 'include/6.0/PCTKFoo' unless
        # the library has foo_p.h header files. For PCTKZlib, there are no such private headers, so we
        # need to make sure not to add such include paths unless the directory exists, otherwise
        # consumers of the library will fail at CMake generation time stating that
        # INTERFACE_INCLUDE_DIRECTORIES contains a non-existent path.
        if(NOT arg_NO_LIBRARY_HEADERS AND EXISTS "${library_build_interface_versioned_inner_include_dir}")
            list(APPEND interface_includes
                "$<BUILD_INTERFACE:${library_build_interface_versioned_include_dir}>"
                "$<BUILD_INTERFACE:${library_build_interface_versioned_inner_include_dir}>")

            if(is_framework)
                set(fw_install_private_header_dir "${INSTALL_LIBDIR}/${fw_private_header_dir}")
                set(fw_install_private_module_header_dir "${INSTALL_LIBDIR}/${fw_private_module_header_dir}")
                list(APPEND interface_includes
                    "$<INSTALL_INTERFACE:${fw_install_private_header_dir}>"
                    "$<INSTALL_INTERFACE:${fw_install_private_module_header_dir}>")
            else()
                list(APPEND interface_includes
                    "$<INSTALL_INTERFACE:${library_install_interface_versioned_include_dir}>"
                    "$<INSTALL_INTERFACE:${library_install_interface_versioned_inner_include_dir}>")
            endif()
        endif()
    endif()

    if(PCTK_FEATURE_HEADERS_CLEAN AND NOT arg_NO_LIBRARY_HEADERS)
        pctk_internal_add_headers_clean_target(
            ${target}
            "${library_include_name}"
            "${library_headers_clean}")
    endif()

    pctk_internal_create_library_depends_file(${target})

    if(arg_INTERNAL_LIBRARY)
        target_include_directories("${target}" INTERFACE ${interface_includes})
    elseif(NOT ${arg_NO_PRIVATE_LIBRARY})
        target_include_directories("${target_private}" INTERFACE ${interface_includes})
        target_link_libraries("${target_private}" INTERFACE "${target}")
    endif()

    set(debug_install_dir "${INSTALL_LIBDIR}")
    if(MINGW)
        set(debug_install_dir "${INSTALL_BINDIR}")
    endif()
    pctk_enable_separate_debug_info(${target} "${debug_install_dir}")
    set(pdb_install_dir "${INSTALL_BINDIR}")
    if(NOT is_shared_lib)
        set(pdb_install_dir "${INSTALL_LIBDIR}")
    endif()
    pctk_internal_install_pdb_files(${target} "${pdb_install_dir}")

    if(arg_NO_PRIVATE_LIBRARY)
        set(arg_NO_PRIVATE_LIBRARY "NO_PRIVATE_LIBRARY")
    else()
        unset(arg_NO_PRIVATE_LIBRARY)
    endif()

    pctk_describe_module(${target})
    pctk_add_list_file_finalizer(pctk_finalize_module ${target} ${arg_INTERNAL_LIBRARY} ${arg_NO_PRIVATE_LIBRARY} ${header_library})

endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Creates a library target by forwarding the arguments to add_library.
#
# Applies some PCTK specific behaviors:
# - If no type option is specified, rather than defaulting to STATIC it defaults to STATIC or SHARED
#   depending on the PCTK configuration.
# - Applies PCTK specific prefixes and suffixes to file names depending on platform.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_add_library target)
    set(opt_args STATIC SHARED MODULE INTERFACE OBJECT)
    set(single_args "")
    set(multi_args "")
    cmake_parse_arguments(PARSE_ARGV 1 arg "${opt_args}" "${single_args}" "${multi_args}")

    set(option_type_count 0)
    if(arg_STATIC)
        set(type_to_create STATIC)
        math(EXPR option_type_count "${option_type_count}+1")
    elseif(arg_SHARED)
        set(type_to_create SHARED)
        math(EXPR option_type_count "${option_type_count}+1")
    elseif(arg_MODULE)
        set(type_to_create MODULE)
        math(EXPR option_type_count "${option_type_count}+1")
    elseif(arg_INTERFACE)
        set(type_to_create INTERFACE)
        math(EXPR option_type_count "${option_type_count}+1")
    elseif(arg_OBJECT)
        set(type_to_create OBJECT)
        math(EXPR option_type_count "${option_type_count}+1")
    endif()

    if(option_type_count GREATER 1)
        message(FATAL_ERROR "Multiple type options were given. Only one should be used.")
    endif()

    # If no explicit type option is set, default to the flavor of the PCTK build.
    # This in contrast to CMake which defaults to STATIC.
    if(NOT arg_STATIC AND NOT arg_SHARED AND NOT arg_MODULE AND NOT arg_INTERFACE AND NOT arg_OBJECT)
        if(PCTK_BUILD_SHARED_LIBS)
            set(type_to_create SHARED)
        else()
            set(type_to_create STATIC)
        endif()
    endif()

    add_library(${target} ${type_to_create} ${arg_UNPARSED_ARGUMENTS})
    pctk_internal_set_up_static_runtime_library(${target})

    if(NOT type_to_create STREQUAL "INTERFACE" AND NOT type_to_create STREQUAL "OBJECT")
        pctk_internal_apply_win_prefix_and_suffix("${target}")
    endif()

    if(arg_MODULE AND APPLE)
        # CMake defaults to using .so extensions for loadable modules, aka plugins,
        # but PCTK plugins are actually suffixed with .dylib.
        set_property(TARGET "${target}" PROPERTY SUFFIX ".dylib")
    endif()

    if(ANDROID)
        pctk_android_apply_arch_suffix("${target}")
    endif()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Get a set of PCTK library related values based on the target.
#
# The function uses the _pctk_library_interface_name and _pctk_library_include_name target properties to
# preform values for the output variables. _pctk_library_interface_name it's the basic name of library
# without "PCTKfication" and the "Private" suffix if we speak about INTERNAL_LIBRARYs. Typical value of
# the _pctk_library_interface_name is the provided to pctk_internal_add_library ${target} name, e.g. Core.
# _pctk_library_interface_name is used to preform all the include paths unless the
# _pctk_library_include_name property is specified. _pctk_library_include_name is legacy property that
# replaces the library name in include paths and has a higher priority than the
# _pctk_library_interface_name property.
#
# When doing pctk_internal_library_info(foo Core) this method will set the following variables in
# the caller's scope:
#  * foo with the value "PCTKCore"
#  * foo_versioned with the value "PCTKCore" (based on major PCTK version)
#  * foo_upper with the value "CORE"
#  * foo_lower with the value "core"
#  * foo_include_name with the value"PCTKCore"
#    Usually the library name from ${foo} is used, but the name might be different if the
#    LIBRARY_INCLUDE_NAME argument is set when creating the library.
#  * foo_versioned_include_dir with the value "PCTKCore/6.2.0"
#  * foo_versioned_inner_include_dir with the value "PCTKCore/6.2.0/PCTKCore"
#  * foo_private_include_dir with the value "PCTKCore/6.2.0/PCTKCore/private"
#  * foo_qpa_include_dir with the value "PCTKCore/6.2.0/PCTKCore/qpa"
#  * foo_interface_name the interface name of the library stored in _pctk_library_interface_name
#    property, e.g. Core.
#
# The function also sets a bunch of library include paths for the build and install interface.
# Variables that contains these paths start with foo_build_interface_ and foo_install_interface_
# accordingly.
# The following variables are set in the caller's scope:
#  * foo_<build|install>_interface_include_dir with
#    pctkbase_build_dir/include/PCTKCore for build interface and
#    include/PCTKCore for install interface.
#  * foo_<build|install>_interface_versioned_include_dir with
#    pctkbase_build_dir/include/PCTKCore/6.2.0 for build interface and
#    include/PCTKCore/6.2.0 for install interface.
#  * foo_<build|install>_versioned_inner_include_dir with
#    pctkbase_build_dir/include/PCTKCore/6.2.0/PCTKCore for build interface and
#    include/PCTKCore/6.2.0/PCTKCore for install interface.
#  * foo_<build|install>_private_include_dir with
#    pctkbase_build_dir/include/PCTKCore/6.2.0/PCTKCore/private for build interface and
#    include/PCTKCore/6.2.0/PCTKCore/private for install interface.
#  * foo_<build|install>_qpa_include_dir with
#    pctkbase_build_dir/include/PCTKCore/6.2.0/PCTKCore/qpa for build interface and
#    include/PCTKCore/6.2.0/PCTKCore/qpa for install interface.
# The following values are set by the function and might be useful in caller's scope:
#  * repo_install_interface_include_dir contains path to the top-level repository include directory,
#    e.g. pctkbase_build_dir/include
#  * repo_install_interface_include_dir contains path to the non-prefixed top-level include
#    directory is used for the installation, e.g. include
# Note: that for non-prefixed PCTK configurations the build interface paths will start with
# <build_directory>/pctkbase/include, e.g foo_build_interface_include_dir of the Qml library looks
# like pctk_toplevel_build_dir/pctkbase/include/PCTKQml
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_library_info result target)
    if(result STREQUAL "repo")
        message(FATAL_ERROR "'repo' keyword is reserved for internal use, please specify \
            the different base name for the library info variables.")
    endif()

    get_target_property(library_interface_name ${target} _pctk_library_interface_name)
    if(NOT library_interface_name)
        message(FATAL_ERROR "${target} is not a library.")
    endif()

    pctk_internal_target_add_fied(library ${library_interface_name})

    get_target_property("${result}_include_name" ${target} _pctk_library_include_name)
    if(NOT ${result}_include_name)
        set("${result}_include_name" "${library}")
    endif()

    set("${result}_versioned_include_dir"
        "${${result}_include_name}/${PROJECT_VERSION}")
    set("${result}_versioned_inner_include_dir"
        "${${result}_versioned_include_dir}/${${result}_include_name}")
    set("${result}_private_include_dir"
        "${${result}_versioned_inner_include_dir}/private")

    # Library build interface directories
    set(repo_build_interface_include_dir "${PCTK_BUILD_DIR}/include")
    set("${result}_build_interface_include_dir"
        "${repo_build_interface_include_dir}/${${result}_include_name}")
    set("${result}_build_interface_versioned_include_dir"
        "${repo_build_interface_include_dir}/${${result}_versioned_include_dir}")
    set("${result}_build_interface_versioned_inner_include_dir"
        "${repo_build_interface_include_dir}/${${result}_versioned_inner_include_dir}")
    set("${result}_build_interface_private_include_dir"
        "${repo_build_interface_include_dir}/${${result}_private_include_dir}")

    # Library install interface directories
    set(repo_install_interface_include_dir "${INSTALL_INCLUDEDIR}")
    set("${result}_install_interface_include_dir"
        "${repo_install_interface_include_dir}/${${result}_include_name}")
    set("${result}_install_interface_versioned_include_dir"
        "${repo_install_interface_include_dir}/${${result}_versioned_include_dir}")
    set("${result}_install_interface_versioned_inner_include_dir"
        "${repo_install_interface_include_dir}/${${result}_versioned_inner_include_dir}")
    set("${result}_install_interface_private_include_dir"
        "${repo_install_interface_include_dir}/${${result}_private_include_dir}")

    set("${result}" "${library}" PARENT_SCOPE)
    set("${result}_versioned" "${library_versioned}" PARENT_SCOPE)
    string(TOUPPER "${library_interface_name}" upper)
    string(TOLOWER "${library_interface_name}" lower)
    set("${result}_upper" "${upper}" PARENT_SCOPE)
    set("${result}_lower" "${lower}" PARENT_SCOPE)
    set("${result}_include_name" "${${result}_include_name}" PARENT_SCOPE)
    set("${result}_versioned_include_dir" "${${result}_versioned_include_dir}" PARENT_SCOPE)
    set("${result}_versioned_inner_include_dir"
        "${${result}_versioned_inner_include_dir}" PARENT_SCOPE)
    set("${result}_private_include_dir" "${${result}_private_include_dir}" PARENT_SCOPE)
    set("${result}_interface_name" "${library_interface_name}" PARENT_SCOPE)

    # Setting library build interface directories in parent scope
    set(repo_build_interface_include_dir "${repo_build_interface_include_dir}" PARENT_SCOPE)
    set("${result}_build_interface_include_dir"
        "${${result}_build_interface_include_dir}" PARENT_SCOPE)
    set("${result}_build_interface_versioned_include_dir"
        "${${result}_build_interface_versioned_include_dir}" PARENT_SCOPE)
    set("${result}_build_interface_versioned_inner_include_dir"
        "${${result}_build_interface_versioned_inner_include_dir}" PARENT_SCOPE)
    set("${result}_build_interface_private_include_dir"
        "${${result}_build_interface_private_include_dir}" PARENT_SCOPE)

    # Setting library install interface directories in parent scope
    set(repo_install_interface_include_dir "${repo_install_interface_include_dir}" PARENT_SCOPE)
    set("${result}_install_interface_include_dir"
        "${${result}_install_interface_include_dir}" PARENT_SCOPE)
    set("${result}_install_interface_versioned_include_dir"
        "${${result}_install_interface_versioned_include_dir}" PARENT_SCOPE)
    set("${result}_install_interface_versioned_inner_include_dir"
        "${${result}_install_interface_versioned_inner_include_dir}" PARENT_SCOPE)
    set("${result}_install_interface_private_include_dir"
        "${${result}_install_interface_private_include_dir}" PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_finalize_module target)
    pctk_finalize_framework_headers_copy(${target})
    pctk_internal_generate_pkg_config_file(${target})
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_apply_strict_cpp target)
    # Disable C, Obj-C and C++ GNU extensions aka no "-std=gnu++11". Allow opt-out via variable.
    if(NOT PCTK_ENABLE_CXX_EXTENSIONS)
        get_target_property(target_type "${target}" TYPE)
        if(NOT target_type STREQUAL "INTERFACE_LIBRARY")
            set_target_properties("${target}" PROPERTIES
                CXX_EXTENSIONS OFF
                C_EXTENSIONS OFF
                OBJC_EXTENSIONS OFF
                OBJCXX_EXTENSIONS OFF)
        endif()
    endif()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_apply_win_prefix_and_suffix target)
    if(WIN32)
        # Table of prefix / suffixes for MSVC libraries as qmake expects them to be created.
        # static - pctk_edid_support.lib (platform support libraries / or static pctk_core, etc)
        # shared - pctk_core.dll
        # shared import library - pctk_core.lib
        # library aka PCTK plugin - pctk_windows.dll
        # library import library - pctk_windows.lib
        #
        # The CMake defaults are fine for us.

        # Table of prefix / suffixes for MinGW libraries as qmake expects them to be created.
        # static - pctk_edid_support.a (platform support libraries / or static pctk_core, etc)
        # shared - pctk_core.dll
        # shared import library - libpctk_core.a
        # library aka PCTK plugin - pctk_windows.dll
        # library import library - libpctk_windows.a
        #
        # CMake for Windows-GNU platforms defaults the prefix to "lib".
        # CMake for Windows-GNU platforms defaults the import suffix to ".dll.a".
        # These CMake defaults are not ok for us.

        # This should cover both MINGW with GCC and CLANG.
        if(NOT MSVC)
            set_property(TARGET "${target}" PROPERTY IMPORT_SUFFIX ".a")

            get_target_property(target_type ${target} TYPE)
            if(target_type STREQUAL "STATIC_LIBRARY")
                set_property(TARGET "${target}" PROPERTY PREFIX "lib")
            else()
                set_property(TARGET "${target}" PROPERTY PREFIX "")
                set_property(TARGET "${target}" PROPERTY IMPORT_PREFIX "lib")
            endif()
        endif()
    endif()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_disable_static_default_plugins target)
    set_target_properties(${target} PROPERTIES PCTK_DEFAULT_PLUGINS 0)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Generate Win32 RC files for a target. All entries in the RC file are generated from target properties:
#
# PCTK_TARGET_COMPANY_NAME: RC Company name
# PCTK_TARGET_DESCRIPTION: RC File Description
# PCTK_TARGET_VERSION: RC File and Product Version
# PCTK_TARGET_COPYRIGHT: RC LegalCopyright
# PCTK_TARGET_PRODUCT_NAME: RC ProductName
# PCTK_TARGET_COMMENTS: RC Comments
# PCTK_TARGET_ORIGINAL_FILENAME: RC Original FileName
# PCTK_TARGET_TRADEMARKS: RC LegalTrademarks
# PCTK_TARGET_INTERNALNAME: RC InternalName
# PCTK_TARGET_RC_ICONS: List of paths to icon files
#
# If you do not wish to auto-generate rc files, it's possible to provide your own RC file by setting the property
# PCTK_TARGET_WINDOWS_RC_FILE with a path to an existing rc file.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_generate_win32_rc_file target)
    set(prohibited_target_types INTERFACE_LIBRARY STATIC_LIBRARY OBJECT_LIBRARY)
    get_target_property(target_type ${target} TYPE)
    if(target_type IN_LIST prohibited_target_types)
        return()
    endif()

    get_target_property(target_binary_dir ${target} BINARY_DIR)

    get_target_property(target_rc_file ${target} PCTK_TARGET_WINDOWS_RC_FILE)
    get_target_property(target_version ${target} PCTK_TARGET_VERSION)

    if(NOT target_rc_file AND NOT target_version)
        return()
    endif()

    if(MSVC)
        set(extra_rc_flags "/nologo")
    else()
        set(extra_rc_flags)
    endif()

    if(target_rc_file)
        # Use the provided RC file
        target_sources(${target} PRIVATE "${target_rc_file}")
        set_property(SOURCE ${target_rc_file} PROPERTY COMPILE_FLAGS "${extra_rc_flags}")
    else()
        # Generate RC File
        set(rc_file_output "${target_binary_dir}/")
        if(PCTK_GENERATOR_IS_MULTI_CONFIG)
            string(APPEND rc_file_output "$<CONFIG>/")
        endif()
        string(APPEND rc_file_output "${target}_resource.rc")
        set(target_rc_file "${rc_file_output}")

        set(company_name "")
        get_target_property(target_company_name ${target} PCTK_TARGET_COMPANY_NAME)
        if(target_company_name)
            set(company_name "${target_company_name}")
        endif()

        set(file_description "")
        get_target_property(target_description ${target} PCTK_TARGET_DESCRIPTION)
        if(target_description)
            set(file_description "${target_description}")
        endif()

        set(legal_copyright "")
        get_target_property(target_copyright ${target} PCTK_TARGET_COPYRIGHT)
        if(target_copyright)
            set(legal_copyright "${target_copyright}")
        endif()

        set(product_name "")
        get_target_property(target_product_name ${target} PCTK_TARGET_PRODUCT_NAME)
        if(target_product_name)
            set(product_name "${target_product_name}")
        else()
            set(product_name "${target}")
        endif()

        set(comments "")
        get_target_property(target_comments ${target} PCTK_TARGET_COMMENTS)
        if(target_comments)
            set(comments "${target_comments}")
        endif()

        set(legal_trademarks "")
        get_target_property(target_trademarks ${target} PCTK_TARGET_TRADEMARKS)
        if(target_trademarks)
            set(legal_trademarks "${target_trademarks}")
        endif()

        set(product_version "")
        if(target_version)
            if(target_version MATCHES "[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+")
                # nothing to do
            elseif(target_version MATCHES "[0-9]+\\.[0-9]+\\.[0-9]+")
                set(target_version "${target_version}.0")
            elseif(target_version MATCHES "[0-9]+\\.[0-9]+")
                set(target_version "${target_version}.0.0")
            elseif(target_version MATCHES "[0-9]+")
                set(target_version "${target_version}.0.0.0")
            else()
                message(FATAL_ERROR "Invalid version format: '${target_version}'")
            endif()
            set(product_version "${target_version}")
        else()
            set(product_version "0.0.0.0")
        endif()

        set(file_version "${product_version}")
        string(REPLACE "." "," version_comma ${product_version})

        set(original_file_name "$<TARGET_FILE_NAME:${target}>")
        get_target_property(target_original_file_name ${target} PCTK_TARGET_ORIGINAL_FILENAME)
        if(target_original_file_name)
            set(original_file_name "${target_original_file_name}")
        endif()

        set(internal_name "")
        get_target_property(target_internal_name ${target} PCTK_TARGET_INTERNALNAME)
        if(target_internal_name)
            set(internal_name "${target_internal_name}")
        endif()

        set(icons "")
        get_target_property(target_icons ${target} PCTK_TARGET_RC_ICONS)
        if(target_icons)
            set(index 1)
            foreach(icon IN LISTS target_icons)
                string(APPEND icons "IDI_ICON${index}    ICON    \"${icon}\"\n")
                math(EXPR index "${index} +1")
            endforeach()
        endif()

        set(target_file_type "VFT_DLL")
        if(target_type STREQUAL "EXECUTABLE")
            set(target_file_type "VFT_APP")
        endif()

        set(contents "#include <windows.h>
            ${icons}
            VS_VERSION_INFO VERSIONINFO
            FILEVERSION ${version_comma}
            PRODUCTVERSION ${version_comma}
            FILEFLAGSMASK 0x3fL
            #ifdef _DEBUG
                FILEFLAGS VS_FF_DEBUG
            #else
                FILEFLAGS 0x0L
            #endif
            FILEOS VOS_NT_WINDOWS32
            FILETYPE ${target_file_type}
            FILESUBTYPE VFT2_UNKNOWN
            BEGIN
                BLOCK \"StringFileInfo\"
                BEGIN
                    BLOCK \"040904b0\"
                    BEGIN
                        VALUE \"CompanyName\", \"${company_name}\"
                        VALUE \"FileDescription\", \"${file_description}\"
                        VALUE \"FileVersion\", \"${file_version}\"
                        VALUE \"LegalCopyright\", \"${legal_copyright}\"
                        VALUE \"OriginalFilename\", \"${original_file_name}\"
                        VALUE \"ProductName\", \"${product_name}\"
                        VALUE \"ProductVersion\", \"${product_version}\"
                        VALUE \"Comments\", \"${comments}\"
                        VALUE \"LegalTrademarks\", \"${legal_trademarks}\"
                        VALUE \"InternalName\", \"${internal_name}\"
                    END
                END
                BLOCK \"VarFileInfo\"
                BEGIN
                    VALUE \"Translation\", 0x0409, 1200
                END
            END
            /* End of Version info */\n")

        # We can't use the output of file generate as source so we work around
        # this by generating the file under a different name and then copying
        # the file in place using add custom command.
        file(GENERATE OUTPUT "${rc_file_output}.tmp" CONTENT "${contents}")

        if(PCTK_GENERATOR_IS_MULTI_CONFIG)
            set(cfgs ${CMAKE_CONFIGURATION_TYPES})
            set(outputs "")
            foreach(cfg ${cfgs})
                string(REPLACE "$<CONFIG>" "${cfg}" expanded_rc_file_output "${rc_file_output}")
                list(APPEND outputs "${expanded_rc_file_output}")
            endforeach()
        else()
            set(cfgs "${CMAKE_BUILD_TYPE}")
            set(outputs "${rc_file_output}")
        endif()

        # We would like to do the following:
        #     target_sources(${target} PRIVATE "$<$<CONFIG:${cfg}>:${output}>")
        #
        # However, https://gitlab.kitware.com/cmake/cmake/-/issues/20682 doesn't let us do that in CMake 3.19 and earlier.
        # We can do it in CMake 3.20 and later.
        # And we have to do it with CMake 3.21.0 to avoid a different issue https://gitlab.kitware.com/cmake/cmake/-/issues/22436
        #
        # So use the object lib work around for <= 3.19 and target_sources directly for later versions.
        set(use_obj_lib FALSE)
        set(end_target "${target}")
        if(CMAKE_VERSION VERSION_LESS 3.20)
            set(use_obj_lib TRUE)
            set(end_target "${target}_rc")
            add_library(${target}_rc OBJECT "${output}")
            target_link_libraries(${target} PRIVATE $<TARGET_OBJECTS:${target}_rc>)
        endif()

        set(scope_args)
        if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.18")
            set(scope_args TARGET_DIRECTORY ${end_target})
        endif()

        while(outputs)
            list(POP_FRONT cfgs cfg)
            list(POP_FRONT outputs output)
            set(input "${output}.tmp")
            add_custom_command(OUTPUT "${output}"
                DEPENDS "${input}"
                COMMAND ${CMAKE_COMMAND} -E copy_if_different "${input}" "${output}"
                VERBATIM)
            # We can't rely on policy CMP0118 since user project controls it
            set_source_files_properties(${output} ${scope_args} PROPERTIES
                GENERATED TRUE
                COMPILE_FLAGS "${extra_rc_flags}")
            target_sources(${end_target} PRIVATE "$<$<CONFIG:${cfg}>:${output}>")
        endwhile()
    endif()
endfunction()


function(pctk_internal_create_library_depends_file target)
    get_target_property(target_type "${target}" TYPE)
    if(target_type STREQUAL "INTERFACE_LIBRARY")
        set(arg_HEADER_LIBRARY ON)
    else()
        set(arg_HEADER_LIBRARY OFF)
    endif()

    set(depends "")
    if(target_type STREQUAL "STATIC_LIBRARY" AND NOT arg_HEADER_LIBRARY)
        get_target_property(depends "${target}" LINK_LIBRARIES)
    endif()

    get_target_property(public_depends "${target}" INTERFACE_LINK_LIBRARIES)

    unset(optional_public_depends)
    if(TARGET "${target}Private")
        get_target_property(optional_public_depends "${target}Private" INTERFACE_LINK_LIBRARIES)
    endif()

    # Used for collecting PCTK module dependencies that should be find_package()'d in
    # ModuleDependencies.cmake.
    get_target_property(target_deps "${target}" _pctk_target_deps)
    set(target_deps_seen "")
    set(pctk_library_dependencies "")

    if(NOT arg_HEADER_LIBRARY)
        get_target_property(extra_depends "${target}" PCTK_EXTRA_PACKAGE_DEPENDENCIES)
    endif()
    if(NOT extra_depends MATCHES "-NOTFOUND$")
        list(APPEND target_deps "${extra_depends}")
    endif()

    # Extra 3rd party targets who's packages should be considered dependencies.
    get_target_property(extra_third_party_deps "${target}" _pctk_extra_third_party_dep_targets)
    if(NOT extra_third_party_deps)
        set(extra_third_party_deps "")
    endif()

    # Used for assembling the content of an include/Module/ModuleDepends.h header.
    set(pctkdeps "")

    # Used for collecting third party dependencies that should be find_package()'d in
    # ModuleDependencies.cmake.
    set(third_party_deps "")
    set(third_party_deps_seen "")

    # Used for collecting PCTK tool dependencies that should be find_package()'d in
    # ModuleToolsDependencies.cmake.
    set(tool_deps "")
    set(tool_deps_seen "")

    # Used for collecting PCTK tool dependencies that should be find_package()'d in
    # ModuleDependencies.cmake.
    set(main_library_tool_deps "")

    # Extra PCTKFooModuleTools packages to be added as dependencies to
    # PCTKModuleDependencies.cmake. Needed for PCTKWaylandCompositor / PCTKWaylandClient.
    if(NOT arg_HEADER_LIBRARY)
        get_target_property(extra_tools_package_dependencies "${target}" PCTK_EXTRA_TOOLS_PACKAGE_DEPENDENCIES)
        if(extra_tools_package_dependencies)
            list(APPEND main_library_tool_deps "${extra_tools_package_dependencies}")
        endif()
    endif()

    pctk_internal_get_all_known_librarys(known_librarys)

    set(all_depends ${depends} ${public_depends})
    foreach(dep ${all_depends})
        # Normalize module by stripping leading "PCTK::" and trailing "Private"
        if(dep MATCHES "(PCTK|${PCTK_CMAKE_EXPORT_NAMESPACE})::([-_A-Za-z0-9]+)")
            set(dep "${CMAKE_MATCH_2}")
            set(real_dep_target "PCTK::${dep}")

            if(TARGET "${real_dep_target}")
                get_target_property(is_versionless_target "${real_dep_target}" _pctk_is_versionless_target)
                if(is_versionless_target)
                    set(real_dep_target "${PCTK_CMAKE_EXPORT_NAMESPACE}::${dep}")
                endif()

                get_target_property(skip_library_depends_include "${real_dep_target}" _pctk_library_skip_depends_include)
                if(skip_library_depends_include)
                    continue()
                endif()

                get_target_property(library_has_headers "${real_dep_target}" _pctk_library_has_headers)
                if(NOT library_has_headers)
                    continue()
                endif()
            endif()
        endif()

        list(FIND known_librarys "${dep}" _pos)
        if(_pos GREATER -1)
            pctk_internal_library_info(library ${PCTK_CMAKE_EXPORT_NAMESPACE}::${dep})
            list(APPEND pctkdeps ${library})

            # Make the ModuleTool package depend on dep's ModuleTool package.
            list(FIND tool_deps_seen ${dep} dep_seen)
            if(dep_seen EQUAL -1 AND ${dep} IN_LIST PCTK_KNOWN_LIBRARIES_WITH_TOOLS)
                pctk_internal_get_package_version_of_target("${dep}" dep_package_version)
                list(APPEND tool_deps_seen ${dep})
                list(APPEND tool_deps "${INSTALL_CMAKE_NAMESPACE}${dep}Tools\;${dep_package_version}")
            endif()
        endif()
    endforeach()

    pctk_collect_third_party_deps(${target})

    # Add dependency to the main ModuleTool package to ModuleDependencies file.
    if(${target} IN_LIST PCTK_KNOWN_LIBRARIES_WITH_TOOLS)
        pctk_internal_get_package_version_of_target("${target}" main_library_tool_package_version)
        list(APPEND main_library_tool_deps
            "${INSTALL_CMAKE_NAMESPACE}${target}Tools\;${main_library_tool_package_version}")
    endif()

    foreach(dep ${target_deps})
        if(NOT dep MATCHES ".+Private$" AND dep MATCHES "${INSTALL_CMAKE_NAMESPACE}(.+)")
            # target_deps contains elements that are a pair of target name and version, e.g. 'Core\;1.1'
            # After the extracting from the target_deps list, the element becomes a list itself,
            # because it loses escape symbol before the semicolon, so ${CMAKE_MATCH_1} is the list: Core;1.1.
            # We need to store only the target name in the pctk_library_dependencies variable.
            list(GET CMAKE_MATCH_1 0 dep_name)
            if(dep_name)
                list(APPEND pctk_library_dependencies "${dep_name}")
            endif()
        endif()
    endforeach()
    list(REMOVE_DUPLICATES pctk_library_dependencies)

    pctk_internal_remove_dependency_duplicates(target_deps "${target_deps}")

    if(DEFINED pctkdeps)
        list(REMOVE_DUPLICATES pctkdeps)
    endif()

    get_target_property(has_library_headers "${target}" _pctk_library_has_headers)
    if(${has_library_headers})
        get_target_property(library_include_name "${target}" _pctk_library_include_name)
        pctk_internal_write_depends_file(${target} ${library_include_name} ${pctkdeps})
    endif()

    if(third_party_deps OR main_library_tool_deps OR target_deps)
        set(path_suffix "${INSTALL_CMAKE_NAMESPACE}${target}")
        pctk_path_join(config_build_dir ${PCTK_CONFIG_BUILD_DIR} ${path_suffix})
        pctk_path_join(config_install_dir ${PCTK_CONFIG_INSTALL_DIR} ${path_suffix})

        # All module packages should look for the PCTK6 package version that PCTK was originally built as.
        pctk_internal_get_package_version_of_target(Platform main_pctk_package_version)

        # Configure and install ModuleDependencies file.
        configure_file(
            "${PCTK_CMAKE_DIR}/PCTKModuleDependencies.cmake.in"
            "${config_build_dir}/${INSTALL_CMAKE_NAMESPACE}${target}Dependencies.cmake"
            @ONLY)

        pctk_install(FILES
            "${config_build_dir}/${INSTALL_CMAKE_NAMESPACE}${target}Dependencies.cmake"
            DESTINATION "${config_install_dir}"
            COMPONENT Devel)

        message(TRACE "Recorded dependencies for library: ${target}\n"
            "    PCTK dependencies: ${target_deps}\n"
            "    3rd-party dependencies: ${third_party_deps}")
    endif()
    if(tool_deps)
        # The value of the property will be used by pctk_export_tools.
        set_property(TARGET "${target}" PROPERTY _pctk_tools_package_deps "${tool_deps}")
    endif()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_write_depends_file target include_name)
    set(outfile "${PCTK_BUILD_DIR}/include/${include_name}/pctk${target}Depends.h")
    set(contents "/* This file was generated by cmake with the info from ${target} target. */\n")
    string(APPEND contents "#ifdef __cplusplus /* create empty PCH in C mode */\n")
    foreach(m ${ARGN})
        string(APPEND contents "#  include <${m}/${m}>\n")
    endforeach()
    string(APPEND contents "#endif\n")

    file(GENERATE OUTPUT "${outfile}" CONTENT "${contents}")
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Filter the dependency targets to collect unique set of the dependencies.
# non-Private and Private targets are treated as the single object in this context since they are defined by the same
# CMake package. For internal library the CMake package will be always Private.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_remove_dependency_duplicates out_deps deps)
    set(${out_deps} "")
    foreach(dep ${deps})
        if(dep)
            list(FIND ${out_deps} "${dep}" dep_seen)

            if(dep_seen EQUAL -1)
                list(LENGTH dep len)
                if(NOT (len EQUAL 2))
                    message(FATAL_ERROR "List '${dep}' should look like PCTKFoo;version")
                endif()
                list(GET dep 0 dep_name)
                list(GET dep 1 dep_ver)

                # Skip over PCTK6 dependency, because we will manually handle it in the Dependencies
                # file before everything else, to ensure that find_package(PCTK6Core)-style works.
                if(dep_name STREQUAL "${INSTALL_CMAKE_NAMESPACE}")
                    continue()
                endif()
                list(APPEND ${out_deps} "${dep_name}\;${dep_ver}")
            endif()
        endif()
    endforeach()
    set(${out_deps} "${${out_deps}}" PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
macro(pctk_collect_third_party_deps target)
    set(_target_is_static OFF)
    get_target_property(_target_type ${target} TYPE)
    if(${_target_type} STREQUAL "STATIC_LIBRARY")
        set(_target_is_static ON)
    endif()
    unset(_target_type)
    # If we are doing a non-static PCTK build, we only want to propagate public dependencies.
    # If we are doing a static PCTK build, we need to propagate all dependencies.
    set(depends_var "public_depends")
    if(_target_is_static)
        set(depends_var "depends")
    endif()
    unset(_target_is_static)

    foreach(dep ${${depends_var}} ${optional_public_depends} ${extra_third_party_deps})
        # Gather third party packages that should be found when using the PCTK module.
        # Also handle nolink target dependencies.
        string(REGEX REPLACE "_nolink$" "" base_dep "${dep}")
        if(NOT base_dep STREQUAL dep)
            # Resets target name like Vulkan_nolink to Vulkan, because we need to call
            # find_package(Vulkan).
            set(dep ${base_dep})
        endif()

        # Strip any directory scope tokens.
        pctk_internal_strip_target_directory_scope_token("${dep}" dep)
        if(TARGET ${dep})
            list(FIND third_party_deps_seen ${dep} dep_seen)

            get_target_property(package_name ${dep} INTERFACE_PCTK_PACKAGE_NAME)
            if(dep_seen EQUAL -1 AND package_name)
                list(APPEND third_party_deps_seen ${dep})
                get_target_property(package_is_optional ${dep} INTERFACE_PCTK_PACKAGE_IS_OPTIONAL)
                if(NOT package_is_optional AND dep IN_LIST optional_public_depends)
                    set(package_is_optional TRUE)
                endif()
                get_target_property(package_version ${dep} INTERFACE_PCTK_PACKAGE_VERSION)
                if(NOT package_version)
                    set(package_version "")
                endif()

                get_target_property(package_components ${dep} INTERFACE_PCTK_PACKAGE_COMPONENTS)
                if(NOT package_components)
                    set(package_components "")
                endif()

                get_target_property(package_optional_components ${dep} INTERFACE_PCTK_PACKAGE_OPTIONAL_COMPONENTS)
                if(NOT package_optional_components)
                    set(package_optional_components "")
                endif()

                list(APPEND third_party_deps
                    "${package_name}\;${package_is_optional}\;${package_version}\;${package_components}\;${package_optional_components}")
            endif()
        endif()
    endforeach()
endmacro()


#-----------------------------------------------------------------------------------------------------------------------
# Gets the list of all known PCTK libraries both found and that were built as part of the current project.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_get_all_known_librarys out_var)
    pctk_internal_get_repo_known_librarys(repo_known_librarys)
    set(known_librarys ${PCTK_ALL_LIBRARIES_FOUND_VIA_FIND_PACKAGE} ${repo_known_librarys})
    list(REMOVE_DUPLICATES known_librarys)
    set("${out_var}" "${known_librarys}" PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_get_repo_known_librarys out_var)
    set("${out_var}" "${PCTK_REPO_KNOWN_LIBRARIES}" PARENT_SCOPE)
endfunction()