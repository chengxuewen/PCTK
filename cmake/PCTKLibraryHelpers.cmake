
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
# This is the main entry function for creating a PCTK module, that typically consists of a library, public header files,
# private header files and configurable features.
#
# A CMake target with the specified target parameter is created. If the current source directory has a configure.cmake
# file, then that is also processed for feature definition and testing. Any features defined as well as any features
# coming from dependencies to this module are imported into the scope of the calling feature.
#
# Target is without leading "PCTK". So e.g. the "PCTKCore" library has the target "Core".
#
# Options:
#   NO_ADDITIONAL_TARGET_INFO
#     Don't generate a PCTK*AdditionalTargetInfo.cmake file.
#     The caller is responsible for creating one.
#
#   LIBRARY_INTERFACE_NAME
#     The custom name of the module interface. This name is used as a part of the include paths
#     associated with the module and other interface names. The default value is the target name.
#     If the INTERNAL_MODULE option is specified, LIBRARY_INTERFACE_NAME is not specified and the
#     target name ends with the suffix 'Private', the LIBRARY_INTERFACE_NAME value defaults to the
#     non-suffixed target name, e.g.:
#        For the SomeInternalModulePrivate target, the LIBRARY_INTERFACE_NAME will be SomeInternalModule
#
#   HEADER_LIBRARY
#     Creates an interface library instead of following the Qt configuration default. Mutually
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
#     A module directory with non qt headers (like 3rdparty) to be installed.
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
        # Assume the interface name of the internal module should be the module name without the 'Private' suffix.
        if(NOT arg_LIBRARY_INTERFACE_NAME)
            if(target MATCHES "(.*)Private$")
                set(arg_LIBRARY_INTERFACE_NAME "${CMAKE_MATCH_1}")
            else()
                message(WARNING "The internal module target should end with the 'Private' suffix.")
            endif()
        endif()
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

    pctk_internal_add_library("${target}" ${type_to_create} ${arg_SOURCES})
    pctk_internal_mark_as_internal_library("${target}")
    get_target_property(target_type ${target} TYPE)

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
        # pctk_internal_library_info uses this property if it's set, so it must be
        # specified before the pctk_internal_library_info call.
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

    if(arg_INTERNAL_LIBRARY)
        set_target_properties(${target} PROPERTIES _pctk_is_internal_library TRUE)
        set_property(TARGET ${target} APPEND PROPERTY EXPORT_PROPERTIES _pctk_is_internal_library)
    endif()

    if(NOT arg_CONFIG_LIBRARY_NAME)
        set(arg_CONFIG_LIBRARY_NAME "${target}")
    endif()
    set(library_config_header "pctk${arg_CONFIG_LIBRARY_NAME}Config.h")
    set(library_config_private_header "pctk${arg_CONFIG_LIBRARY_NAME}Config_p.h")

    # Module define needs to take into account the config module name.
    string(TOUPPER "${arg_CONFIG_LIBRARY_NAME}" library_define_infix)
    string(REPLACE "-" "_" library_define_infix "${library_define_infix}")
    string(REPLACE "." "_" library_define_infix "${library_define_infix}")

    set(property_prefix "INTERFACE_")
    if(NOT arg_HEADER_LIBRARY)
        set(property_prefix "")
    endif()

    if(arg_INTERNAL_LIBRARY)
        string(APPEND arg_CONFIG_LIBRARY_NAME "_private")
    endif()
    set_target_properties(${target} PROPERTIES _pctk_config_library_name "${arg_CONFIG_LIBRARY_NAME}")
    set_property(TARGET "${target}" APPEND PROPERTY EXPORT_PROPERTIES _pctk_config_library_name)

    set(is_framework 0)
    if(PCTK_FEATURE_FRAMEWORK AND NOT ${arg_HEADER_LIBRARY} AND NOT ${arg_STATIC})
        set(is_framework 1)
        set_target_properties(${target} PROPERTIES
            FRAMEWORK TRUE
            FRAMEWORK_VERSION "A" # Not based on PCTK major version
            MACOSX_FRAMEWORK_IDENTIFIER org.pctk-project.${module}
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

    # Add _private target to link against the private headers:
    set(target_private "${target}Private")
    if(NOT ${arg_NO_PRIVATE_LIBRARY})
#        message(target_private=${target_private})
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
        set_property(TARGET "${target_private}" APPEND PROPERTY
            EXPORT_PROPERTIES "${export_properties}")
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
            # Horrible workaround for static build failures due to incorrect static library link
            # order. By increasing the multiplicity to 3, each library cycle will be repeated
            # 3 times on the link line, reducing the probability of undefined symbols at link time.
            # These failures are only observed on Linux with the ld linker (not sure about ld.gold).
            # Allow opting out and modifying the value via cache value,  in case if we urgently
            # need to increase it without waiting for the PCTK change to propagate to other dependent repos.
            # The proper fix will be to get rid of the cycles in the future.
            set(default_link_cycle_multiplicity "3")
            if(DEFINED PCTK_LINK_CYCLE_MULTIPLICITY)
                set(default_link_cycle_multiplicity "${PCTK_LINK_CYCLE_MULTIPLICITY}")
            endif()
            if(default_link_cycle_multiplicity)
                set_property(TARGET "${target}" PROPERTY
                    LINK_INTERFACE_MULTIPLICITY "${default_link_cycle_multiplicity}")
            endif()
        endif()

        if(arg_SKIP_DEPENDS_INCLUDE)
            set_target_properties(${target} PROPERTIES _pctk_module_skip_depends_include TRUE)
            set_property(TARGET "${target}" APPEND PROPERTY
                EXPORT_PROPERTIES _pctk_module_skip_depends_include)
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

    # Module headers:
    set_property(TARGET "${target}" APPEND PROPERTY EXPORT_PROPERTIES _pctk_library_has_headers)
    if(${arg_NO_LIBRARY_HEADERS} OR ${arg_NO_SYNC_PCTK})
        set_target_properties("${target}" PROPERTIES _pctk_library_has_headers OFF)
    else()
        set_property(TARGET ${target} APPEND PROPERTY EXPORT_PROPERTIES _pctk_library_include_name)
        set_target_properties("${target}" PROPERTIES _pctk_library_include_name "${library_include_name}")

        # Use PCTK_BUILD_DIR for the syncpctk call.
        # So we either write the generated files into the PCTK non-prefix build root, or the library specific build root.
        #        pctk_ensure_sync_pctk()
        #        set(syncpctk_full_command "${HOST_PERL}" -w "${PCTK_SYNCPCTK}"
        #            -quiet
        #            -check-includes
        #            -module "${library_include_name}"
        #            -version "${PROJECT_VERSION}"
        #            -outdir "${PCTK_BUILD_DIR}"
        #            -builddir "${PROJECT_BINARY_DIR}"
        #            "${PROJECT_SOURCE_DIR}")
        #        message(STATUS "Running syncpctk for module: '${library_include_name}' ")
        #        execute_process(COMMAND ${syncpctk_full_command} RESULT_VARIABLE syncpctk_ret)
        #        if(NOT syncpctk_ret EQUAL 0)
        #            message(FATAL_ERROR "Failed to run syncpctk, return code: ${syncpctk_ret}")
        #        endif()

        set_target_properties("${target}" PROPERTIES _pctk_library_has_headers ON)

        #        ### FIXME: Can we replace headers.pri?
        #        qt_read_headers_pri("${module_build_interface_include_dir}" "module_headers")

        if(arg_EXTERNAL_HEADERS)
            set(library_headers_public ${arg_EXTERNAL_HEADERS})
        else()
            set(library_headers_private ${arg_HEADERS})
            set(library_headers_public ${arg_PUBLIC_HEADERS})
        endif()

        set_property(TARGET ${target} APPEND PROPERTY _pctk_library_timestamp_dependencies "${library_headers_public}")

        # We should not generate export headers if module is defined as pure STATIC.
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
        #        set(library_depends_header "${library_build_interface_include_dir}/${library_include_name}Depends")
        #        set(library_depends_header "${CMAKE_CURRENT_BINARY_DIR}/source")
        #        message(library_build_interface_include_dir=${library_build_interface_include_dir})
        #        message(library_depends_header=${library_depends_header})
        if("${library_depends_header}" STREQUAL "/Depends")
            set(library_depends_header "")
        endif()
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
        #        message(library_headers_public=${library_headers_public})
        #        if(module_headers_qpa)
        #            if(is_framework)
        #                pctk_copy_framework_headers(${target} QPA "${module_headers_qpa}")
        #            else()
        #                pctk_install(
        #                    FILES ${module_headers_qpa}
        #                    DESTINATION "${library_install_interface_qpa_include_dir}")
        #            endif()
        #        endif()
    endif()

    if(NOT arg_HEADER_LIBRARY)
        # Plugin types associated to a module
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

    ###TODO::del
    #    if(NOT arg_HEADER_LIBRARY)
    #        pctk_autogen_tools_initial_setup(${target})
    #    endif()

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

    ###TODO:sync include source-build?
    set(public_includes
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>")
    ###TODO
    # Make sure the BUILD_INTERFACE include paths come before the framework headers, so that the
    # the compiler prefers the build dir includes.
    #
    # Make sure to add non-framework "build_dir/include" as an include path for moc to find the
    # currently built module headers. qmake does this too.
    # Framework-style include paths are found by moc when cmPCTKAutoMocUic.cxx detects frameworks by
    # looking at an include path and detecting a "PCTKFoo.framework/Headers" path.
    # Make sure to create such paths for both the the BUILD_INTERFACE and the INSTALL_INTERFACE.
    #
    # Only add syncpctk headers if they exist.
    # This handles cases like QmlDevToolsPrivate which do not have their own headers, but borrow them
    # from another module.
    #    if(NOT arg_NO_SYNC_PCTK AND NOT arg_NO_LIBRARY_HEADERS)
    #        # Don't include private headers unless they exist, aka syncpctk created them.
    #        if(library_headers_private)
    #            list(APPEND private_includes
    #                "$<BUILD_INTERFACE:${library_build_interface_versioned_include_dir}>"
    #                "$<BUILD_INTERFACE:${library_build_interface_versioned_inner_include_dir}>")
    #        endif()
    #
    #        list(APPEND public_includes
    #            # For the syncpctk headers
    #            "$<BUILD_INTERFACE:${repo_build_interface_include_dir}>"
    #            "$<BUILD_INTERFACE:${library_build_interface_include_dir}>")
    #        message(library_build_interface_include_dir=${library_build_interface_include_dir})
    #    endif()

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

    #    if(NOT arg_NO_LIBRARY_HEADERS AND NOT arg_NO_SYNC_PCTK)
    #        # For the syncpctk headers
    #        list(APPEND ${public_headers_list} "$<INSTALL_INTERFACE:${library_install_interface_include_dir}>")
    #
    #        # To support finding PCTK module includes that are not installed into the main PCTK prefix.
    #        # Use case: A PCTK module built by Conan installed into a prefix other than the main prefix.
    #        # This does duplicate the include path set on PCTK::platform target, but CMake is smart
    #        # enough to deduplicate the include paths on the command line.
    #        # Frameworks are automatically handled by CMake in cmLocalGenerator::GetIncludeFlags()
    #        # by additionally passing the 'PCTKFoo.framework/..' dir with an -iframework argument.
    #        list(APPEND ${public_headers_list} "$<INSTALL_INTERFACE:${INSTALL_INCLUDEDIR}>")
    #    endif()
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

    #    pctk_internal_add_repo_local_defines("${target}")
    pctk_internal_extend_target("${target}"
        ${header_library}
        HEADERS
        ${arg_HEADERS}
        SOURCES
        ${arg_SOURCES}
        PUBLIC_HEADERS
        ${arg_PUBLIC_HEADERS}
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

    # The public module define is not meant to be used when building the module itself, it's only meant to be used for
    # consumers of the module, thus we can't use pctk_internal_extend_target()'s PUBLIC_DEFINES option.
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
        pctk_configure_module_begin(
            LIBRARY "${target}"
            PUBLIC_FILE "include/${library_config_header}"
            PRIVATE_FILE "include/private/${library_config_private_header}"
            PUBLIC_DEPENDENCIES ${arg_FEATURE_DEPENDENCIES}
            PRIVATE_DEPENDENCIES ${arg_FEATURE_DEPENDENCIES})
        pctk_configure_reset(${arg_CONFIGURE_RESET})
        include(${configure_file})
        pctk_configure_module_end("${target}")

        #        message(library_config_header=${library_config_header})
        #        message(library_config_private_header=${library_config_private_header})
        set_property(TARGET "${target}" APPEND PROPERTY
            PUBLIC_HEADER "${CMAKE_CURRENT_BINARY_DIR}/include/${library_config_header}")
        set_property(TARGET "${target}" APPEND PROPERTY
            PRIVATE_HEADER "${CMAKE_CURRENT_BINARY_DIR}/include/private/${library_config_private_header}")
    endif()

    if(NOT arg_HEADER_LIBRARY)
        if(DEFINED library_headers_private)
            pctk_internal_add_linker_version_script("${target}" PRIVATE_HEADERS ${library_headers_private})
        else()
            pctk_internal_add_linker_version_script("${target}")
        endif()
    endif()

    # Handle injections. Aka create forwarding headers for certain headers that have been
    # automatically generated in the build dir (for example pctkCoreConfig.h, pctkCoreConfigPrivate.h, etc)
    set(final_injections "")
    if(module_headers_injections)
        string(APPEND final_injections "${module_headers_injections} ")
    endif()
    if(extra_library_injections)
        string(APPEND final_injections "${extra_library_injections} ")
    endif()

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
    # from another module.
    if(NOT arg_NO_SYNC_PCTK)
        list(APPEND interface_includes "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>")

        # syncpctk.pl does not create a private header directory like 'include/6.0/PCTKFoo' unless
        # the module has foo_p.h header files. For PCTKZlib, there are no such private headers, so we
        # need to make sure not to add such include paths unless the directory exists, otherwise
        # consumers of the module will fail at CMake generation time stating that
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

    if(PCTK_FEATURE_headersclean AND NOT arg_NO_LIBRARY_HEADERS)
        pctk_internal_add_headers_clean_target(
            ${target}
            "${library_include_name}"
            "${module_headers_clean}")
    endif()

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