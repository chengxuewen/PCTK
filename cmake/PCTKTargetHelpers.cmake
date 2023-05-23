#-----------------------------------------------------------------------------------------------------------------------
# This function can be used to add sources/libraries/etc. to the specified CMake target
# if the provided CONDITION evaluates to true.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_extend_target target)
    # Don't try to extend_target when cross compiling an imported host target (like a tool).
    pctk_is_imported_target("${target}" is_imported)
    if(is_imported)
        return()
    endif()

    if(NOT TARGET "${target}")
        message(FATAL_ERROR "Trying to extend non-existing target \"${target}\".")
    endif()

    pctk_parse_all_arguments(arg "pctk_internal_extend_target" "HEADER_LIBRARY" "PRECOMPILED_HEADER"
        "CONDITION;${PCTK_DEFAULT_PUBLIC_ARGS};${PCTK_DEFAULT_PRIVATE_ARGS};${PCTK_DEFAULT_PRIVATE_LIBRARY_ARGS};COMPILE_FLAGS;NO_PCH_SOURCES" ${ARGN})
    if("x${arg_CONDITION}" STREQUAL x)
        set(arg_CONDITION ON)
    endif()

    pctk_evaluate_expression(result ${arg_CONDITION})
    if(${result})
        if(PCTK_CMAKE_DEBUG_EXTEND_TARGET)
            message("pctk_extend_target(${target} CONDITION ${arg_CONDITION} ...): Evaluated")
        endif()

        get_target_property(target_type ${target} TYPE)
        set(is_library FALSE)
        if(${target_type} STREQUAL "STATIC_LIBRARY" OR ${target_type} STREQUAL "SHARED_LIBRARY")
            set(is_library TRUE)
        endif()
        foreach(lib ${arg_PUBLIC_LIBRARIES} ${arg_LIBRARIES})
            # Automatically generate PCH for 'target' using public dependencies.
            # But only if 'target' is a library/module that does not specify its own PCH file.
            if(NOT arg_PRECOMPILED_HEADER AND ${is_library})
                pctk_update_precompiled_header_with_library("${target}" "${lib}")
            endif()

            string(REGEX REPLACE "_nolink$" "" base_lib "${lib}")
            if(NOT base_lib STREQUAL lib)
                pctk_create_nolink_target("${base_lib}" ${target})
            endif()
        endforeach()

        # Set-up the target

        # CMake versions less than 3.19 don't support adding the source files to the PRIVATE scope
        # of the INTERFACE libraries. These PRIVATE sources are only needed by IDEs to display
        # them in a project tree, so to avoid build issues and appearing the sources in
        # INTERFACE_SOURCES property of HEADER_LIBRARY let's simply exclude them for compatibility
        # with CMake versions less than 3.19.
        if(NOT arg_HEADER_LIBRARY OR CMAKE_VERSION VERSION_GREATER_EQUAL "3.19")
            target_sources("${target}" PRIVATE ${arg_SOURCES} ${dbus_sources})
            if(arg_COMPILE_FLAGS)
                set_source_files_properties(${arg_SOURCES} PROPERTIES
                    COMPILE_FLAGS "${arg_COMPILE_FLAGS}")
            endif()
        endif()

        set(public_visibility_option "PUBLIC")
        set(private_visibility_option "PRIVATE")
        if(arg_HEADER_LIBRARY)
            set(public_visibility_option "INTERFACE")
            set(private_visibility_option "INTERFACE")
        endif()
        target_include_directories("${target}"
            ${public_visibility_option} ${arg_PUBLIC_INCLUDE_DIRECTORIES}
            ${private_visibility_option} ${arg_INCLUDE_DIRECTORIES})
        target_compile_definitions("${target}"
            ${public_visibility_option} ${arg_PUBLIC_DEFINES}
            ${private_visibility_option} ${arg_DEFINES})
        target_link_libraries("${target}"
            ${public_visibility_option} ${arg_PUBLIC_LIBRARIES}
            ${private_visibility_option} ${arg_LIBRARIES})
        target_compile_options("${target}"
            ${public_visibility_option} ${arg_PUBLIC_COMPILE_OPTIONS}
            ${private_visibility_option} ${arg_COMPILE_OPTIONS})
        target_link_options("${target}"
            ${public_visibility_option} ${arg_PUBLIC_LINK_OPTIONS}
            ${private_visibility_option} ${arg_LINK_OPTIONS})

        # When computing the private library dependencies, we need to check not only the known
        # modules added by this repo's pctk_build_repo(), but also all module dependencies that
        # were found via find_package().
        pctk_internal_get_pctk_all_known_modules(known_modules)

        # When a public module depends on a private module (Gui on CorePrivate)
        # make its private module depend on the other private module (GuiPrivate will depend on
        # CorePrivate).
        set(pctk_libs_private "")
        foreach(it ${known_modules})
            list(FIND arg_LIBRARIES "PCTK::${it}Private" pos)
            if(pos GREATER -1)
                list(APPEND pctk_libs_private "PCTK::${it}Private")
            endif()
        endforeach()

        set(target_private "${target}Private")
        get_target_property(is_internal_library ${target} _pctk_is_internal_library)
        # Internal modules don't have Private targets but we still need to propagate their private dependencies.
        if(is_internal_library)
            set(target_private "${target}")
        endif()
        if(TARGET "${target_private}")
            target_link_libraries("${target_private}" INTERFACE ${arg_PRIVATE_LIBRARY_INTERFACE})
        elseif(arg_PRIVATE_LIBRARY_INTERFACE)
            set(warning_message "")
            string(APPEND warning_message
                "The PRIVATE_LIBRARY_INTERFACE option was provided the values:"
                "'${arg_PRIVATE_LIBRARY_INTERFACE}' "
                "but there is no ${target}Private target to assign them to."
                "Ensure the target exists or remove the option.")
            message(AUTHOR_WARNING "${warning_message}")
        endif()
        pctk_register_target_dependencies("${target}"
            "${arg_PUBLIC_LIBRARIES};${arg_PRIVATE_LIBRARY_INTERFACE}"
            "${pctk_libs_private};${arg_LIBRARIES}")

        pctk_update_precompiled_header("${target}" "${arg_PRECOMPILED_HEADER}")
        pctk_update_ignore_pch_source("${target}" "${arg_NO_PCH_SOURCES}")
        ## Ignore objective-c files for PCH (not supported atm)
        pctk_ignore_pch_obj_c_sources("${target}" "${arg_SOURCES}")

    else()
        if(PCTK_CMAKE_DEBUG_EXTEND_TARGET)
            message("pctk_extend_target(${target} CONDITION ${arg_CONDITION} ...): Skipped")
        endif()
    endif()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Marks a target with a property that it is a library (shared or static) which was built using the
# internal PCTK API (pctk_internal_add_library, pctk_internal_add_plugin, etc) as opposed to it being
# a user project library (pctk_internal_add_library, pctk_add_plugin, etc).
#
# Needed to allow selectively applying certain flags via platformXinternal targets.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_mark_as_internal_library target)
    set_target_properties(${target} PROPERTIES _pctk_is_internal_library TRUE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Common function to add PCTK prefixes to the target name, use the PCTK'fied library name as a framework identifier.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_target_add_fied out_var target)
    set(${out_var} "PCTK${target}" PARENT_SCOPE)
    set(${out_var}_versioned "PCTK${PCTK_NAMESPACE_VERSION}${target}" PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Add PCTK::target and PCTK0::target as aliases for the target
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_add_target_aliases target)
    set(versionless_alias "PCTK::${target}")
    set(versionfull_alias "PCTK${PCTK_NAMESPACE_VERSION}::${target}")
    set_target_properties("${target}" PROPERTIES _pctk_versionless_alias "${versionless_alias}")
    set_target_properties("${target}" PROPERTIES _pctk_versionfull_alias "${versionfull_alias}")

    get_target_property(type "${target}" TYPE)
    if(type STREQUAL EXECUTABLE)
        add_executable("${versionless_alias}" ALIAS "${target}")
        add_executable("${versionfull_alias}" ALIAS "${target}")
    else()
        add_library("${versionless_alias}" ALIAS "${target}")
        add_library("${versionfull_alias}" ALIAS "${target}")
    endif()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Set common, informational target properties.
#
# On Windows, these properties are used to generate the version information resource.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_set_target_info_properties target)
    cmake_parse_arguments(arg "" "${PCTK_DEFAULT_TARGET_INFO_ARGS}" "" ${ARGN})
    if("${arg_TARGET_VERSION}" STREQUAL "")
        set(arg_TARGET_VERSION "${PROJECT_VERSION}.0")
    endif()
    if("${arg_TARGET_PRODUCT}" STREQUAL "")
        set(arg_TARGET_PRODUCT "PCTK")
    endif()
    if("${arg_TARGET_DESCRIPTION}" STREQUAL "")
        set(arg_TARGET_DESCRIPTION "C++ Application Development Framework")
    endif()
    if("${arg_TARGET_COMPANY}" STREQUAL "")
        set(arg_TARGET_COMPANY "The PCTK Open Source Organization.")
    endif()
    if("${arg_TARGET_COPYRIGHT}" STREQUAL "")
        set(arg_TARGET_COPYRIGHT "Copyright (C) 2022 The PCTK Open Source Organization.")
    endif()
    set_target_properties(${target} PROPERTIES
        PCTK_TARGET_VERSION "${arg_TARGET_VERSION}"
        PCTK_TARGET_COMPANY_NAME "${arg_TARGET_COMPANY}"
        PCTK_TARGET_DESCRIPTION "${arg_TARGET_DESCRIPTION}"
        PCTK_TARGET_COPYRIGHT "${arg_TARGET_COPYRIGHT}"
        PCTK_TARGET_PRODUCT_NAME "${arg_TARGET_PRODUCT}")
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_get_cmake_configurations out_var)
    set(possible_configs "${CMAKE_BUILD_TYPE}")
    if(CMAKE_CONFIGURATION_TYPES)
        set(possible_configs "${CMAKE_CONFIGURATION_TYPES}")
    endif()
    set(${out_var} "${possible_configs}" PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_clone_property_for_configs target property configs)
    get_target_property(value "${target}" "${property}")
    foreach(config ${configs})
        string(TOUPPER "${config}" upper_config)
        set_property(TARGET "${target}" PROPERTY "${property}_${upper_config}" "${value}")
    endforeach()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_handle_multi_config_output_dirs target)
    pctk_get_cmake_configurations(possible_configs)
    pctk_clone_property_for_configs(${target} LIBRARY_OUTPUT_DIRECTORY "${possible_configs}")
    pctk_clone_property_for_configs(${target} RUNTIME_OUTPUT_DIRECTORY "${possible_configs}")
    pctk_clone_property_for_configs(${target} ARCHIVE_OUTPUT_DIRECTORY "${possible_configs}")
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_set_compile_pdb_names target)
    if(MSVC)
        get_target_property(target_type ${target} TYPE)
        if(target_type STREQUAL "STATIC_LIBRARY" OR target_type STREQUAL "OBJECT_LIBRARY")
            get_target_property(output_name ${target} OUTPUT_NAME)
            if(NOT output_name)
                set(output_name "${INSTALL_CMAKE_NAMESPACE}${target}")
            endif()
            set_target_properties(${target} PROPERTIES COMPILE_PDB_NAME "${output_name}")
            set_target_properties(${target} PROPERTIES COMPILE_PDB_NAME_DEBUG "${output_name}d")
        endif()
    endif()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Set target properties that are the same for all modules, plugins, executables
# and 3rdparty libraries.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_set_common_target_properties target)
    if(PCTK_FEATURE_reduce_exports)
        set_target_properties(${target} PROPERTIES
            C_VISIBILITY_PRESET hidden
            CXX_VISIBILITY_PRESET hidden
            OBJC_VISIBILITY_PRESET hidden
            OBJCXX_VISIBILITY_PRESET hidden
            VISIBILITY_INLINES_HIDDEN 1)
    endif()
    pctk_internal_set_compile_pdb_names("${target}")
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# This function adds any defines which are local to the current repository (e.g. pctk_core,
# pctk_multimedia). Those can be defined in the corresponding .cmake.conf file via
# PCTK_EXTRA_INTERNAL_TARGET_DEFINES. PCTK_EXTRA_INTERNAL_TARGET_DEFINES accepts a list of definitions.
# The definitions are passed to target_compile_definitions, which means that values can be provided
# via the FOO=Bar syntax
# This does nothing for interface targets
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_add_repo_local_defines target)
    get_target_property(type "${target}" TYPE)
    if(${type} STREQUAL "INTERFACE_LIBRARY")
        return()
    endif()
    if(DEFINED PCTK_EXTRA_INTERNAL_TARGET_DEFINES)
        target_compile_definitions("${target}" PRIVATE ${PCTK_EXTRA_INTERNAL_TARGET_DEFINES})
    endif()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_is_imported_target target out_var)
    if(NOT TARGET "${target}")
        set(target "${PCTK_CMAKE_EXPORT_NAMESPACE}::${target}")
    endif()
    if(NOT TARGET "${target}")
        message(FATAL_ERROR "Invalid target given to pctk_is_imported_target: ${target}")
    endif()
    get_target_property(is_imported "${target}" IMPORTED)
    set(${out_var} "${is_imported}" PARENT_SCOPE)
endfunction()


macro(pctk_internal_get_export_additional_targets_keywords option_args single_args multi_args)
    set(${option_args})
    set(${single_args} EXPORT_NAME_PREFIX)
    set(${multi_args} TARGETS TARGET_EXPORT_NAMES)
endmacro()


#-----------------------------------------------------------------------------------------------------------------------
# Create a PCTK*AdditionalTargetInfo.cmake file that is included by PCTK*Config.cmake
# and sets IMPORTED_*_<CONFIG> properties on the exported targets.
#
# The file also makes the targets global if the PCTK_PROMOTE_TO_GLOBAL_TARGETS property is set in the consuming project.
# When using a CMake version lower than 3.21, only the specified TARGETS are made global.
# E.g. transitive non-PCTK 3rd party targets of the specified targets are not made global.
#
# EXPORT_NAME_PREFIX:
#    The portion of the file name before AdditionalTargetInfo.cmake
# CONFIG_INSTALL_DIR:
#    Installation location for the target info file
# TARGETS:
#    The internal target names. Those must be actual targets.
# TARGET_EXPORT_NAMES:
#    The target names how they appear in the PCTKXXXTargets.cmake files.
#    The names get prefixed by ${PCTK_CMAKE_EXPORT_NAMESPACE}:: unless they already are.
#    This argument may be empty, then the target export names are the same as the internal ones.
#
# TARGETS and TARGET_EXPORT_NAMES must contain exactly the same number of elements.
# Example: TARGETS = scriptjs_native
#          TARGET_EXPORT_NAMES = PCTK::ScriptJs
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_export_additional_targets_file)
    pctk_internal_get_export_additional_targets_keywords(option_args single_args multi_args)
    cmake_parse_arguments(arg
        "${option_args}"
        "${single_args};CONFIG_INSTALL_DIR"
        "${multi_args}"
        ${ARGN})

    pctk_internal_append_export_additional_targets()

    set_property(GLOBAL APPEND PROPERTY _pctk_export_additional_targets_ids "${id}")
    set_property(GLOBAL APPEND
        PROPERTY _pctk_export_additional_targets_export_name_prefix_${id} "${arg_EXPORT_NAME_PREFIX}")
    set_property(GLOBAL APPEND
        PROPERTY _pctk_export_additional_targets_config_install_dir_${id} "${arg_CONFIG_INSTALL_DIR}")

#    message(id=${id})
#    message(arg_EXPORT_NAME_PREFIX=${arg_EXPORT_NAME_PREFIX})
#    message(arg_CONFIG_INSTALL_DIR=${arg_CONFIG_INSTALL_DIR})
    pctk_add_list_file_finalizer(pctk_internal_export_additional_targets_file_finalizer)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Uses outer-scope variables to keep the implementation less verbose.
#-----------------------------------------------------------------------------------------------------------------------
macro(pctk_internal_append_export_additional_targets)
    pctk_internal_validate_export_additional_targets(
        EXPORT_NAME_PREFIX "${arg_EXPORT_NAME_PREFIX}"
        TARGETS ${arg_TARGETS}
        TARGET_EXPORT_NAMES ${arg_TARGET_EXPORT_NAMES})
#    message(arg_EXPORT_NAME_PREFIX=${arg_EXPORT_NAME_PREFIX})
    pctk_internal_get_export_additional_targets_id("${arg_EXPORT_NAME_PREFIX}" id)

    set_property(GLOBAL APPEND PROPERTY _pctk_export_additional_targets_${id} "${arg_TARGETS}")
    set_property(GLOBAL APPEND PROPERTY _pctk_export_additional_target_export_names_${id} "${arg_TARGET_EXPORT_NAMES}")
endmacro()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_get_export_additional_targets_id export_name out_var)
    string(MAKE_C_IDENTIFIER "${export_name}" id)
    set(${out_var} "${id}" PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_validate_export_additional_targets)
    pctk_internal_get_export_additional_targets_keywords(option_args single_args multi_args)
    cmake_parse_arguments(arg
        "${option_args}"
        "${single_args}"
        "${multi_args}"
        ${ARGN})

    if(NOT arg_EXPORT_NAME_PREFIX)
        message(FATAL_ERROR "pctk_internal_validate_export_additional_targets: "
            "Missing EXPORT_NAME_PREFIX argument.")
    endif()

    list(LENGTH arg_TARGETS num_TARGETS)
    list(LENGTH arg_TARGET_EXPORT_NAMES num_TARGET_EXPORT_NAMES)
    if(num_TARGET_EXPORT_NAMES GREATER 0)
        if(NOT num_TARGETS EQUAL num_TARGET_EXPORT_NAMES)
            message(FATAL_ERROR "pctk_internal_validate_export_additional_targets: "
                "TARGET_EXPORT_NAMES is set but has ${num_TARGET_EXPORT_NAMES} elements while "
                "TARGETS has ${num_TARGETS} elements. "
                "They must contain the same number of elements.")
        endif()
    else()
        set(arg_TARGET_EXPORT_NAMES ${arg_TARGETS})
    endif()

    set(arg_TARGETS "${arg_TARGETS}" PARENT_SCOPE)
    set(arg_TARGET_EXPORT_NAMES "${arg_TARGET_EXPORT_NAMES}" PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_export_modern_cmake_config_targets_file)
    cmake_parse_arguments(__arg "" "EXPORT_NAME_PREFIX;CONFIG_INSTALL_DIR" "TARGETS" ${ARGN})

    set(export_name "${__arg_EXPORT_NAME_PREFIX}VersionlessTargets")
    foreach(target ${__arg_TARGETS})
        if(TARGET "${target}Versionless")
            continue()
        endif()

        add_library("${target}Versionless" INTERFACE)
        target_link_libraries("${target}Versionless" INTERFACE "${target}")
        set_target_properties("${target}Versionless" PROPERTIES
            EXPORT_NAME "${target}"
            _pctk_is_versionless_target "TRUE")
        set_property(TARGET "${target}Versionless"
            APPEND PROPERTY EXPORT_PROPERTIES _pctk_is_versionless_target)

        pctk_install(TARGETS "${target}Versionless" EXPORT ${export_name})
    endforeach()
    pctk_install(EXPORT ${export_name} NAMESPACE PCTK:: DESTINATION "${__arg_CONFIG_INSTALL_DIR}")
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Installs pdb files for given target into the specified install dir.
#
# MSVC generates 2 types of pdb files:
#  - compile-time generated pdb files (compile flag /Zi + /Fd<pdb_name>)
#  - link-time generated pdb files (link flag /debug + /PDB:<pdb_name>)
#
# CMake allows changing the names of each of those pdb file types by setting
# the COMPILE_PDB_NAME_<CONFIG> and PDB_NAME_<CONFIG> properties. If they are
# left empty, CMake will compute the default names itself (or rather in certain cases
# leave it up to the compiler), without actually setting the property values.
#
# For installation purposes, CMake only provides a generator expression to the
# link time pdb file path, not the compile path one, which means we have to compute the
# path to the compile path pdb files ourselves.
# See https://gitlab.kitware.com/cmake/cmake/-/issues/18393 for details.
#
# For shared libraries and executables, we install the linker provided pdb file via the
# TARGET_PDB_FILE generator expression.
#
# For static libraries there is no linker invocation, so we need to install the compile
# time pdb file. We query the ARCHIVE_OUTPUT_DIRECTORY property of the target to get the
# path to the pdb file, and reconstruct the file name. We use a generator expression
# to append a possible debug suffix, in order to allow installation of all Release and
# Debug pdb files when using Ninja Multi-Config.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_install_pdb_files target install_dir_path)
    if(MSVC)
        get_target_property(target_type ${target} TYPE)

        if(target_type STREQUAL "EXECUTABLE")
            pctk_get_cmake_configurations(cmake_configs)
            list(LENGTH cmake_configs all_configs_count)
            list(GET cmake_configs 0 first_config)
            foreach(cmake_config ${cmake_configs})
                set(suffix "")
                if(all_configs_count GREATER 1 AND NOT cmake_config STREQUAL first_config)
                    set(suffix "/${cmake_config}")
                endif()
                pctk_install(FILES "$<TARGET_PDB_FILE:${target}>"
                    CONFIGURATIONS ${cmake_config}
                    DESTINATION "${install_dir_path}${suffix}"
                    OPTIONAL)
            endforeach()

        elseif(target_type STREQUAL "SHARED_LIBRARY" OR target_type STREQUAL "MODULE_LIBRARY")
            pctk_install(FILES "$<TARGET_PDB_FILE:${target}>" DESTINATION "${install_dir_path}" OPTIONAL)
        elseif(target_type STREQUAL "STATIC_LIBRARY")
            get_target_property(lib_dir "${target}" ARCHIVE_OUTPUT_DIRECTORY)
            if(NOT lib_dir)
                message(FATAL_ERROR
                    "Can't install pdb file for static library ${target}. "
                    "The ARCHIVE_OUTPUT_DIRECTORY path is not known.")
            endif()
            get_target_property(pdb_name "${target}" COMPILE_PDB_NAME)
            pctk_path_join(compile_time_pdb_file_path "${lib_dir}" "${pdb_name}$<$<CONFIG:Debug>:d>.pdb")

            pctk_install(FILES "${compile_time_pdb_file_path}" DESTINATION "${install_dir_path}" OPTIONAL)
        elseif(target_type STREQUAL "OBJECT_LIBRARY")
            get_target_property(pdb_dir "${target}" COMPILE_PDB_OUTPUT_DIRECTORY)
            if(NOT pdb_dir)
                get_target_property(pdb_dir "${target}" BINARY_DIR)
                if(PCTK_GENERATOR_IS_MULTI_CONFIG)
                    pctk_path_join(pdb_dir "${pdb_dir}" "$<CONFIG>")
                endif()
            endif()
            get_target_property(pdb_name "${target}" COMPILE_PDB_NAME)
            pctk_path_join(compile_time_pdb_file_path "${pdb_dir}" "${pdb_name}$<$<CONFIG:Debug>:d>.pdb")

            pctk_install(FILES "${compile_time_pdb_file_path}" DESTINATION "${install_dir_path}" OPTIONAL)
        endif()
    endif()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# The finalizer might be called multiple times in the same scope, but only the first one will process all the ids.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_export_additional_targets_file_finalizer)
    get_property(ids GLOBAL PROPERTY _pctk_export_additional_targets_ids)
#    message(ids=${ids})
    foreach(id ${ids})
        pctk_internal_export_additional_targets_file_handler("${id}")
    endforeach()

    set_property(GLOBAL PROPERTY _pctk_export_additional_targets_ids "")
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_export_additional_targets_file_handler id)
    get_property(arg_EXPORT_NAME_PREFIX GLOBAL PROPERTY
        _pctk_export_additional_targets_export_name_prefix_${id})
    get_property(arg_CONFIG_INSTALL_DIR GLOBAL PROPERTY
        _pctk_export_additional_targets_config_install_dir_${id})
    get_property(arg_TARGETS GLOBAL PROPERTY
        _pctk_export_additional_targets_${id})
    get_property(arg_TARGET_EXPORT_NAMES GLOBAL PROPERTY
        _pctk_export_additional_target_export_names_${id})

    list(LENGTH arg_TARGETS num_TARGETS)

    # Determine the release configurations we're currently building
    if(PCTK_GENERATOR_IS_MULTI_CONFIG)
        set(active_configurations ${CMAKE_CONFIGURATION_TYPES})
    else()
        set(active_configurations ${CMAKE_BUILD_TYPE})
    endif()
    unset(active_release_configurations)
    foreach(config ${active_configurations})
        string(TOUPPER ${config} ucconfig)
        if(NOT ucconfig STREQUAL "DEBUG")
            list(APPEND active_release_configurations ${config})
        endif()
    endforeach()

    if(active_release_configurations)
        # Use the first active release configuration as *the* release config for imported targets
        # and for PCTK_DEFAULT_IMPORT_CONFIGURATION.
        list(GET active_release_configurations 0 release_cfg)
        string(TOUPPER ${release_cfg} uc_release_cfg)
        set(uc_default_cfg ${uc_release_cfg})

        # Determine the release configurations we do *not* build currently
        set(configurations_to_export Release;RelWithDebInfo;MinSizeRel)
        list(REMOVE_ITEM configurations_to_export ${active_configurations})
    else()
        # There are no active release configurations.
        # Use the first active configuration for PCTK_DEFAULT_IMPORT_CONFIGURATION.
        unset(uc_release_cfg)
        list(GET active_configurations 0 default_cfg)
        string(TOUPPER ${default_cfg} uc_default_cfg)
        unset(configurations_to_export)
    endif()

    set(content "# Additional target information for ${arg_EXPORT_NAME_PREFIX}
        if(NOT DEFINED PCTK_DEFAULT_IMPORT_CONFIGURATION)
        set(PCTK_DEFAULT_IMPORT_CONFIGURATION ${uc_default_cfg})
        endif()
        ")

    math(EXPR n "${num_TARGETS} - 1")
    foreach(i RANGE ${n})
        list(GET arg_TARGETS ${i} target)
        list(GET arg_TARGET_EXPORT_NAMES ${i} target_export_name)

        set(full_target ${target_export_name})
        if(NOT full_target MATCHES "^${PCTK_CMAKE_EXPORT_NAMESPACE}::")
            string(PREPEND full_target "${PCTK_CMAKE_EXPORT_NAMESPACE}::")
        endif()

        # Tools are already made global unconditionally in PCTKFooToolsConfig.cmake. And the
        get_target_property(target_type ${target} TYPE)
        if(NOT target_type STREQUAL "EXECUTABLE")
            string(APPEND content
                "__pctk_internal_promote_target_to_global_checked(${full_target})\n")
        endif()

        # INTERFACE libraries don't have IMPORTED_LOCATION-like properties.
        # OBJECT libraries have properties like IMPORTED_OBJECTS instead.
        # Skip the rest of the processing for those.
        if(target_type STREQUAL "INTERFACE_LIBRARY" OR target_type STREQUAL "OBJECT_LIBRARY")
            continue()
        endif()

        set(properties_retrieved TRUE)

        # Non-prefix debug-and-release builds: add check for the existence of the debug binary of
        # the target.  It is not built by default.
        if(NOT PCTK_WILL_INSTALL AND PCTK_FEATURE_debug_and_release)
            get_target_property(excluded_genex ${target} EXCLUDE_FROM_ALL)
            if(NOT excluded_genex STREQUAL "")
                string(APPEND content "
                    # ${full_target} is not built by default in the Debug configuration. Check existence.
                    get_target_property(_pctk_imported_location ${full_target} IMPORTED_LOCATION_DEBUG)
                    if(NOT EXISTS \"$\\{_pctk_imported_location}\")
                    get_target_property(_pctk_imported_configs ${full_target} IMPORTED_CONFIGURATIONS)
                    list(REMOVE_ITEM _pctk_imported_configs DEBUG)
                    set_property(TARGET ${full_target} PROPERTY IMPORTED_CONFIGURATIONS $\\{_pctk_imported_configs})
                    set_property(TARGET ${full_target} PROPERTY IMPORTED_LOCATION_DEBUG)
                    endif()\n\n")
            endif()
        endif()

        set(write_implib FALSE)
        set(write_soname FALSE)
        if(target_type STREQUAL "SHARED_LIBRARY")
            if(WIN32)
                set(write_implib TRUE)
            else()
                set(write_soname TRUE)
            endif()
        endif()

        if(NOT "${uc_release_cfg}" STREQUAL "")
            string(APPEND content
                "get_target_property(_pctk_imported_location ${full_target} IMPORTED_LOCATION_${uc_release_cfg})\n")
            if(write_implib)
                string(APPEND content
                    "get_target_property(_pctk_imported_implib ${full_target} IMPORTED_IMPLIB_${uc_release_cfg})\n")
            endif()
            if(write_soname)
                string(APPEND content
                    "get_target_property(_pctk_imported_soname ${full_target} IMPORTED_SONAME_${uc_release_cfg})\n")
            endif()
        endif()
        string(APPEND content
            "get_target_property(_pctk_imported_location_default ${full_target} IMPORTED_LOCATION_$\\{PCTK_DEFAULT_IMPORT_CONFIGURATION})\n")
        if(write_implib)
            string(APPEND content
                "get_target_property(_pctk_imported_implib_default ${full_target} IMPORTED_IMPLIB_$\\{PCTK_DEFAULT_IMPORT_CONFIGURATION})\n")
        endif()
        if(write_soname)
            string(APPEND content
                "get_target_property(_pctk_imported_soname_default ${full_target} IMPORTED_SONAME_$\\{PCTK_DEFAULT_IMPORT_CONFIGURATION})\n")
        endif()
        foreach(config ${configurations_to_export} "")
            string(TOUPPER "${config}" ucconfig)
            if("${config}" STREQUAL "")
                set(property_suffix "")
                set(var_suffix "_default")
                string(APPEND content "\n# Default configuration")
            else()
                set(property_suffix "_${ucconfig}")
                set(var_suffix "")
                string(APPEND content "
                    # Import target \"${full_target}\" for configuration \"${config}\"
                    set_property(TARGET ${full_target} APPEND PROPERTY IMPORTED_CONFIGURATIONS ${ucconfig})
                    ")
            endif()
            string(APPEND content "
                    if(_pctk_imported_location${var_suffix})
                        set_property(TARGET ${full_target} PROPERTY IMPORTED_LOCATION${property_suffix} \"$\\{_pctk_imported_location${var_suffix}}\")
                    endif()")
            if(write_implib)
                string(APPEND content "
                    if(_pctk_imported_implib${var_suffix})
                        set_property(TARGET ${full_target} PROPERTY IMPORTED_IMPLIB${property_suffix} \"$\\{_pctk_imported_implib${var_suffix}}\")
                    endif()")
            endif()
            if(write_soname)
                string(APPEND content "
                    if(_pctk_imported_soname${var_suffix})
                        set_property(TARGET ${full_target} PROPERTY IMPORTED_SONAME${property_suffix} \"$\\{_pctk_imported_soname${var_suffix}}\")
                    endif()")
            endif()
            string(APPEND content "\n")
        endforeach()
    endforeach()

    if(properties_retrieved)
        string(APPEND content "
            unset(_pctk_imported_location)
            unset(_pctk_imported_location_default)
            unset(_pctk_imported_soname)
            unset(_pctk_imported_soname_default)
            unset(_pctk_imported_configs)")
    endif()

    pctk_path_join(output_file "${arg_CONFIG_INSTALL_DIR}" "${arg_EXPORT_NAME_PREFIX}AdditionalTargetInfo.cmake")
    if(NOT IS_ABSOLUTE "${output_file}")
        pctk_path_join(output_file "${PCTK_BUILD_DIR}" "${output_file}")
    endif()
    pctk_configure_file(OUTPUT "${output_file}" CONTENT "${content}")
    pctk_install(FILES "${output_file}" DESTINATION "${arg_CONFIG_INSTALL_DIR}")
endfunction()