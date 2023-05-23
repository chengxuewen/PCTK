########################################################################################################################
#
# Library: PCTK
#
# Copyright (C) 2021~2022 ChengXueWen. Contact: 1398831004@qq.com
#
# License: MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
########################################################################################################################


#-----------------------------------------------------------------------------------------------------------------------
# This function is used to define a "PCTK tool", such as moc, uic or rcc.
#
# USER_FACING can be passed to mark the tool as a program that is supposed to be
# started directly by users.
#
# We must pass this function a target name obtained from
# pctk_get_tool_target_name like this:
#     pctk_get_tool_target_name(target_name my_tool)
#     pctk_internal_add_tool(${target_name})
#
# Option Arguments:
#     INSTALL_VERSIONED_LINK
#         Prefix build only. On installation, create a versioned hard-link of the installed file.
#         E.g. create a link of "bin/qmake6" to "bin/qmake".
#
# One-value Arguments:
#     EXTRA_CMAKE_FILES
#         List of additional CMake files that will be installed alongside the tool's exported CMake
#         files.
#     EXTRA_CMAKE_INCLUDES
#         List of files that will be included in the PCTK${module}Tools.cmake file.
#         Also see TOOLS_TARGET.
#     INSTALL_DIR
#         Takes a path, relative to the install prefix, like INSTALL_LIBEXECDIR.
#         If this argument is omitted, the default is INSTALL_BINDIR.
#     TOOLS_TARGET
#         Specifies the module this tool belongs to. The module's PCTK${module}Tools.cmake file
#         will then contain targets for this tool.
#     CORE_LIBRARY
#         The argument accepts 'Bootstrap' or 'None' values. If the argument value is set to
#         'Bootstrap' the PCTK::Bootstrap library is linked to the executable instead of PCTK::Core.
#         The 'None' value points that core library is not necessary and avoids linking neither
#         PCTK::Core or PCTK::Bootstrap libraries. Otherwise the PCTK::Core library will be publicly
#         linked to the executable target by default.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_add_tool target_name)
    pctk_tool_target_to_name(name ${target_name})
    set(option_keywords NO_INSTALL USER_FACING INSTALL_VERSIONED_LINK EXCEPTIONS)
    set(one_value_keywords
        TOOLS_TARGET
        INSTALL_DIR
        CORE_LIBRARY
        ${PCTK_DEFAULT_TARGET_INFO_ARGS})
    set(multi_value_keywords
        EXTRA_CMAKE_FILES
        EXTRA_CMAKE_INCLUDES
        ${PCTK_DEFAULT_PRIVATE_ARGS})
    pctk_parse_all_arguments(arg "pctk_internal_add_tool" "${option_keywords}"
        "${one_value_keywords}"
        "${multi_value_keywords}" ${ARGN})

    # Handle case when a tool does not belong to a module and it can't be built either (like during a cross-compile).
    if(NOT arg_TOOLS_TARGET AND NOT PCTK_WILL_BUILD_TOOLS)
        message(FATAL_ERROR "The tool \"${name}\" has not been assigned to a module via"
            " TOOLS_TARGET (so it can't be found) and it can't be built"
            " (PCTK_WILL_BUILD_TOOLS is ${PCTK_WILL_BUILD_TOOLS}).")
    endif()

    if(PCTK_WILL_RENAME_TOOL_TARGETS AND (name STREQUAL target_name))
        message(FATAL_ERROR "pctk_internal_add_tool must be passed a target obtained from pctk_get_tool_target_name.")
    endif()

    set(full_name "${PCTK_CMAKE_EXPORT_NAMESPACE}::${name}")
    set(imported_tool_target_already_found FALSE)
    message(full_name=${full_name})
    # This condition can only be TRUE if a previous find_package(PCTK${arg_TOOLS_TARGET}Tools) was already done.
    # That can happen if PCTK_FORCE_FIND_TOOLS was ON or we're cross-compiling.
    # In such a case, we need to exit early if we're not going to also build the tools.
    if(TARGET ${full_name})
        get_property(path TARGET ${full_name} PROPERTY LOCATION)
        message(STATUS "Tool '${full_name}' was found at ${path}.")
        set(imported_tool_target_already_found TRUE)
        if(NOT PCTK_WILL_BUILD_TOOLS)
            return()
        endif()
    endif()

    # We need to search for the host Tools package when doing a cross-build or when PCTK_FORCE_FIND_TOOLS is ON.
    # As an optimiziation, we don't search for the package one more time if the target
    # was already brought into scope from a previous find_package.
    set(search_for_host_package FALSE)
    if(NOT PCTK_WILL_BUILD_TOOLS OR PCTK_WILL_RENAME_TOOL_TARGETS)
        set(search_for_host_package TRUE)
    endif()
    message(arg_TOOLS_TARGET=${arg_TOOLS_TARGET})
    message(search_for_host_package=${search_for_host_package})
    message(imported_tool_target_already_found=${imported_tool_target_already_found})
    if(search_for_host_package AND NOT imported_tool_target_already_found)
        set(tools_package_name "PCTK${arg_TOOLS_TARGET}")
        message(STATUS "Searching for tool '${full_name}' in package ${tools_package_name}.")

        # Create the tool targets, even if PCTK_NO_CREATE_TARGETS is set.
        # Otherwise targets like PCTK::rcc are not available in a top-level cross-build.
        set(BACKUP_PCTK_NO_CREATE_TARGETS ${PCTK_NO_CREATE_TARGETS})
        set(PCTK_NO_CREATE_TARGETS OFF)

        # When cross-compiling, we want to search for Tools packages in PCTK_HOST_PATH.
        # To do that, we override CMAKE_PREFIX_PATH and CMAKE_FIND_ROOT_PATH.
        #
        # We don't use find_package + PATHS option because any recursive find_dependency call
        # inside a Tools package would not inherit the initial PATHS value given.
        # TODO: Potentially we could set a global __pctk_cmake_host_dir var like we currently
        # do with _pctk_cmake_dir in PCTKConfig and change all our host tool find_package calls
        # everywhere to specify that var in PATHS.
        #
        # Note though that due to path rerooting issue in
        # https://gitlab.kitware.com/cmake/cmake/-/issues/21937
        # we have to append a lib/cmake suffix to CMAKE_PREFIX_PATH so the value does not get rerooted on top of
        # CMAKE_FIND_ROOT_PATH.
        # Use PCTK_HOST_PATH_CMAKE_DIR for the suffix when available (it would be set by the pctk.toolchain.cmake file
        # when building other repos or given by the user when configuring PCTK) or derive it from from the PCTKHostInfo
        # package which is found in PCTKSetup.
        set(${tools_package_name}_BACKUP_CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH})
        set(${tools_package_name}_BACKUP_CMAKE_FIND_ROOT_PATH "${CMAKE_FIND_ROOT_PATH}")
        if(PCTK_HOST_PATH_CMAKE_DIR)
            set(pctk_host_path_cmake_dir_absolute "${PCTK_HOST_PATH_CMAKE_DIR}")
        elseif(PCTK${PCTK_NAMESPACE_VERSION}HostInfo_DIR)
            get_filename_component(pctk_host_path_cmake_dir_absolute
                "${PCTK${PCTK_NAMESPACE_VERSION}HostInfo_DIR}/.." ABSOLUTE)
        else()
            # This should never happen, serves as an assert.
            message(FATAL_ERROR
                "Neither PCTK_HOST_PATH_CMAKE_DIR nor PCTK${PCTK_NAMESPACE_VERSION}HostInfo_DIR available.")
        endif()
        set(CMAKE_PREFIX_PATH "${pctk_host_path_cmake_dir_absolute}")

        # Look for tools in additional host PCTK installations. This is done for conan support where
        # we have separate installation prefixes per package. For simplicity, we assume here that
        # all host PCTK installations use the same value of INSTALL_LIBDIR.
        if(DEFINED PCTK_ADDITIONAL_HOST_PACKAGES_PREFIX_PATH)
            file(RELATIVE_PATH rel_host_cmake_dir "${PCTK_HOST_PATH}"
                "${pctk_host_path_cmake_dir_absolute}")
            foreach(host_path IN LISTS PCTK_ADDITIONAL_HOST_PACKAGES_PREFIX_PATH)
                set(host_cmake_dir "${host_path}/${rel_host_cmake_dir}")
                list(PREPEND CMAKE_PREFIX_PATH "${host_cmake_dir}")
            endforeach()

            list(PREPEND CMAKE_FIND_ROOT_PATH "${PCTK_ADDITIONAL_HOST_PACKAGES_PREFIX_PATH}")
        endif()
        list(PREPEND CMAKE_FIND_ROOT_PATH "${PCTK_HOST_PATH}")

        find_package(
            ${tools_package_name}
            ${PROJECT_VERSION}
            NO_PACKAGE_ROOT_PATH
            NO_CMAKE_ENVIRONMENT_PATH
            NO_SYSTEM_ENVIRONMENT_PATH
            NO_CMAKE_PACKAGE_REGISTRY
            NO_CMAKE_SYSTEM_PATH
            NO_CMAKE_SYSTEM_PACKAGE_REGISTRY)

        # Restore backups.
        set(CMAKE_FIND_ROOT_PATH "${${tools_package_name}_BACKUP_CMAKE_FIND_ROOT_PATH}")
        set(CMAKE_PREFIX_PATH "${${tools_package_name}_BACKUP_CMAKE_PREFIX_PATH}")
        set(PCTK_NO_CREATE_TARGETS ${BACKUP_PCTK_NO_CREATE_TARGETS})

        if(${${tools_package_name}_FOUND} AND TARGET ${full_name})
            # Even if the tool is already visible, make sure that our modules remain associated
            # with the tools.
            pctk_internal_append_known_modules_with_tools("${arg_TOOLS_TARGET}")
            get_property(path TARGET ${full_name} PROPERTY LOCATION)
            message(STATUS "${full_name} was found at ${path} using package ${tools_package_name}.")
            if(NOT PCTK_FORCE_BUILD_TOOLS)
                return()
            endif()
        endif()
    endif()

    if(NOT PCTK_WILL_BUILD_TOOLS)
        if(${${tools_package_name}_FOUND})
            set(pkg_found_msg "")
            string(APPEND pkg_found_msg
                "the ${tools_package_name} package, but the package did not contain the tool. "
                "Make sure that the host module ${arg_TOOLS_TARGET} was built with all features "
                "enabled (no explicitly disabled tools).")
        else()
            set(pkg_found_msg "")
            string(APPEND pkg_found_msg
                "the ${tools_package_name} package, but the package could not be found. "
                "Make sure you have built and installed the host ${arg_TOOLS_TARGET} module, "
                "which will ensure the creation of the ${tools_package_name} package.")
        endif()
        message(FATAL_ERROR
            "Failed to find the host tool \"${full_name}\". It is part of "
            ${pkg_found_msg})
    else()
        message(STATUS "Tool '${full_name}' will be built from source.")
    endif()

    set(disable_autogen_tools "${arg_DISABLE_AUTOGEN_TOOLS}")
    set(corelib "")
    if(arg_CORE_LIBRARY STREQUAL "Bootstrap" OR arg_CORE_LIBRARY STREQUAL "None")
        set(corelib CORE_LIBRARY ${arg_CORE_LIBRARY})
        list(APPEND disable_autogen_tools "rcc")
    endif()

    set(exceptions "")
    if(arg_EXCEPTIONS)
        set(exceptions EXCEPTIONS)
    endif()

    set(install_dir "${INSTALL_BINDIR}")
    if(arg_INSTALL_DIR)
        set(install_dir "${arg_INSTALL_DIR}")
    endif()

    set(output_dir "${PCTK_BUILD_DIR}/${install_dir}")

    pctk_internal_add_executable("${target_name}"
        OUTPUT_DIRECTORY "${output_dir}"
        ${exceptions}
        NO_INSTALL
        SOURCES ${arg_SOURCES}
        INCLUDE_DIRECTORIES
        ${arg_INCLUDE_DIRECTORIES}
        DEFINES
        PCTK_USE_QSTRINGBUILDER
        ${arg_DEFINES}
        ${corelib}
        LIBRARIES ${arg_LIBRARIES} PCTK::PlatformToolInternal
        COMPILE_OPTIONS ${arg_COMPILE_OPTIONS}
        LINK_OPTIONS ${arg_LINK_OPTIONS}
        MOC_OPTIONS ${arg_MOC_OPTIONS}
        DISABLE_AUTOGEN_TOOLS ${disable_autogen_tools}
        TARGET_VERSION "${arg_TARGET_VERSION}"
        TARGET_PRODUCT "${arg_TARGET_PRODUCT}"
        TARGET_DESCRIPTION "${arg_TARGET_DESCRIPTION}"
        TARGET_COMPANY "${arg_TARGET_COMPANY}"
        TARGET_COPYRIGHT "${arg_TARGET_COPYRIGHT}")
    pctk_internal_add_target_aliases("${target_name}")
    _pctk_internal_apply_strict_cpp("${target_name}")
    pctk_internal_adjust_main_config_runtime_output_dir("${target_name}" "${output_dir}")

    set_target_properties(${target_name} PROPERTIES
        _pctk_package_version "${PROJECT_VERSION}")
    set_property(TARGET ${target_name}
        APPEND PROPERTY
        EXPORT_PROPERTIES "_pctk_package_version")

    if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.19.0" AND PCTK_FEATURE_debug_and_release)
        set_property(TARGET "${target_name}"
            PROPERTY EXCLUDE_FROM_ALL "$<NOT:$<CONFIG:${PCTK_MULTI_CONFIG_FIRST_CONFIG}>>")
    endif()

    if(NOT target_name STREQUAL name)
        set_target_properties(${target_name} PROPERTIES
            OUTPUT_NAME ${name}
            EXPORT_NAME ${name})
    endif()

    if(TARGET host_tools)
        add_dependencies(host_tools "${target_name}")
        if(arg_CORE_LIBRARY STREQUAL "Bootstrap")
            add_dependencies(bootstrap_tools "${target_name}")
        endif()
    endif()

    if(arg_EXTRA_CMAKE_FILES)
        set_target_properties(${target_name} PROPERTIES
            EXTRA_CMAKE_FILES "${arg_EXTRA_CMAKE_FILES}")
    endif()

    if(arg_EXTRA_CMAKE_INCLUDES)
        set_target_properties(${target_name} PROPERTIES
            EXTRA_CMAKE_INCLUDES "${arg_EXTRA_CMAKE_INCLUDES}")
    endif()

    if(arg_USER_FACING)
        set_property(GLOBAL APPEND PROPERTY PCTK_USER_FACING_TOOL_TARGETS ${target_name})
    endif()


    if(NOT arg_NO_INSTALL AND arg_TOOLS_TARGET)
        # Assign a tool to an export set, and mark the module to which the tool belongs.
        pctk_internal_append_known_modules_with_tools("${arg_TOOLS_TARGET}")

        # Also append the tool to the module list.
        pctk_internal_append_known_module_tool("${arg_TOOLS_TARGET}" "${target_name}")

        pctk_get_cmake_configurations(cmake_configs)

        set(install_initial_call_args
            EXPORT "${INSTALL_CMAKE_NAMESPACE}${arg_TOOLS_TARGET}ToolsTargets")

        foreach(cmake_config ${cmake_configs})
            pctk_get_install_target_default_args(
                OUT_VAR install_targets_default_args
                RUNTIME "${install_dir}"
                CMAKE_CONFIG "${cmake_config}"
                ALL_CMAKE_CONFIGS "${cmake_configs}")

            # Make installation optional for targets that are not built by default in this config
            if(PCTK_FEATURE_debug_and_release
                AND NOT (cmake_config STREQUAL PCTK_MULTI_CONFIG_FIRST_CONFIG))
                set(install_optional_arg OPTIONAL)
            else()
                unset(install_optional_arg)
            endif()

            pctk_install(TARGETS "${target_name}"
                ${install_initial_call_args}
                ${install_optional_arg}
                CONFIGURATIONS ${cmake_config}
                ${install_targets_default_args})
            unset(install_initial_call_args)
        endforeach()

        if(arg_INSTALL_VERSIONED_LINK)
            pctk_internal_install_versioned_link("${install_dir}" "${target_name}")
        endif()

        pctk_apply_rpaths(TARGET "${target_name}" INSTALL_PATH "${install_dir}" RELATIVE_RPATH)
        pctk_internal_apply_staging_prefix_build_rpath_workaround()
    endif()

    pctk_enable_separate_debug_info(${target_name} "${install_dir}" PCTK_EXECUTABLE)
    pctk_internal_install_pdb_files(${target_name} "${install_dir}")
endfunction()


# Returns the tool name for a given tool target.
# This is the inverse of pctk_get_tool_target_name.
function(pctk_tool_target_to_name out_var target)
    set(name ${target})
    if(PCTK_WILL_RENAME_TOOL_TARGETS)
        string(REGEX REPLACE "_native$" "" name ${target})
    endif()
    set(${out_var} ${name} PARENT_SCOPE)
endfunction()