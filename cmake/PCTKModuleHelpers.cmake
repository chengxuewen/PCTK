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
# Populates $out_module_list with all subdirectories that have a CMakeLists.txt file
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_find_modules out_module_list)
    set(module_list "")
    file(GLOB directories LIST_DIRECTORIES true RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" *)
    foreach(directory IN LISTS directories)
        if(IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${directory}"
            AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${directory}/CMakeLists.txt")
            list(APPEND module_list "${directory}")
        endif()
    endforeach()
    message(DEBUG "pctk_internal_find_modules: ${module_list}")
    set(${out_module_list} "${module_list}" PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# poor man's yaml parser, populating $out_dependencies with all dependencies
# in the $depends_file
# Each entry will be in the format dependency/sha1/required
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_parse_dependencies depends_file out_dependencies)
    file(STRINGS "${depends_file}" lines)
    set(eof_marker "---EOF---")
    list(APPEND lines "${eof_marker}")
    set(required_default TRUE)
    set(dependencies "")
    set(dependency "")
    set(revision "")
    set(required "${required_default}")
    foreach(line IN LISTS lines)
        if(line MATCHES "^  (.+):$" OR line STREQUAL "${eof_marker}")
            # Found a repo entry or end of file. Add the last seen dependency.
            if(NOT dependency STREQUAL "")
                if(revision STREQUAL "")
                    message(FATAL_ERROR "Format error in ${depends_file} - ${dependency} does not specify revision!")
                endif()
                list(APPEND dependencies "${dependency}/${revision}/${required}")
            endif()
            # Remember the current dependency
            if(NOT line STREQUAL "${eof_marker}")
                set(dependency "${CMAKE_MATCH_1}")
                set(revision "")
                set(required "${required_default}")
                # dependencies are specified with relative path to this module
                string(REPLACE "../" "" dependency ${dependency})
            endif()
        elseif(line MATCHES "^    ref: (.+)$")
            set(revision "${CMAKE_MATCH_1}")
        elseif(line MATCHES "^    required: (.+)$")
            string(TOUPPER "${CMAKE_MATCH_1}" required)
        endif()
    endforeach()
    message(DEBUG "pctk_internal_parse_dependencies for ${depends_file}\n    dependencies: ${dependencies}")
    set(${out_dependencies} "${dependencies}" PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Resolve the dependencies of the given module.
# "Module" in the sense of PCTK repository.
#
# Side effects: Sets the global properties PCTK_DEPS_FOR_${module} and PCTK_REQUIRED_DEPS_FOR_${module}
# with the direct (required) dependencies of module.
#
#
# Positional arguments:
#
# module is the PCTK repository.
#
# out_ordered is where the result is stored. This is a list of all dependencies, including
# transitive ones, in topologically sorted order. Note that ${module} itself is also part of
# out_ordered.
#
# out_revisions is a list of git commit IDs for each of the dependencies in ${out_ordered}. This
# list has the same length as ${out_ordered}.
#
#
# Keyword arguments:
#
# PARSED_DEPENDENCIES is a list of dependencies of module in the format that
# pctk_internal_parse_dependenciesdependencies returns. If this argument is not provided, dependencies.yaml of the
# module is parsed.
#
# IN_RECURSION is an internal option that is set when the function is in recursion.
#
# REVISION is an internal value with the git commit ID that belongs to ${module}.
#
# SKIPPED_VAR is an output variable name that is set to TRUE if the module was skipped, to FALSE
# otherwise.
#
# NORMALIZE_REPO_NAME_IF_NEEDED Will remove 'tpctkc-' from the beginning of submodule dependencies
# if a tpctkc- named directory does not exist.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_resolve_module_dependencies module out_ordered out_revisions)
    set(options IN_RECURSION NORMALIZE_REPO_NAME_IF_NEEDED)
    set(oneValueArgs REVISION SKIPPED_VAR)
    set(multiValueArgs PARSED_DEPENDENCIES)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Clear the property that stores the repositories we've already seen.
    if(NOT arg_IN_RECURSION)
        set_property(GLOBAL PROPERTY _pctk_internal_seen_repos)
    endif()

    # Bail out if we've seen the module already.
    pctk_internal_resolve_module_dependencies_set_skipped(FALSE)
    get_property(seen GLOBAL PROPERTY _pctk_internal_seen_repos)
    if(module IN_LIST seen)
        pctk_internal_resolve_module_dependencies_set_skipped(TRUE)
        return()
    endif()

    set_property(GLOBAL APPEND PROPERTY _pctk_internal_seen_repos ${module})

    # Set a default REVISION.
    if("${arg_REVISION}" STREQUAL "")
        set(arg_REVISION HEAD)
    endif()

    # Retrieve the dependencies.
    if(DEFINED arg_PARSED_DEPENDENCIES)
        set(dependencies "${arg_PARSED_DEPENDENCIES}")
    else()
        set(depends_file "${CMAKE_CURRENT_SOURCE_DIR}/${module}/dependencies.yaml")
        set(dependencies "")
        if(EXISTS "${depends_file}")
            pctk_internal_parse_dependencies("${depends_file}" dependencies)
        endif()
    endif()

    # Traverse the dependencies.
    set(ordered)
    set(revisions)
    foreach(dependency IN LISTS dependencies)
        if(dependency MATCHES "(.*)/([^/]+)/([^/]+)")
            set(dependency "${CMAKE_MATCH_1}")
            set(revision "${CMAKE_MATCH_2}")
            set(required "${CMAKE_MATCH_3}")
        else()
            message(FATAL_ERROR "Internal Error: wrong dependency format ${dependency}")
        endif()

        set(normalize_arg "")
        if(arg_NORMALIZE_REPO_NAME_IF_NEEDED)
            pctk_internal_use_normalized_repo_name_if_needed("${dependency}" dependency)
            set(normalize_arg "NORMALIZE_REPO_NAME_IF_NEEDED")
        endif()

        set_property(GLOBAL APPEND PROPERTY PCTK_DEPS_FOR_${module} ${dependency})
        if(required)
            set_property(GLOBAL APPEND PROPERTY PCTK_REQUIRED_DEPS_FOR_${module} ${dependency})
        endif()

        pctk_internal_resolve_module_dependencies(${dependency} dep_ordered dep_revisions
            REVISION "${revision}"
            SKIPPED_VAR skipped
            IN_RECURSION
            ${normalize_arg})
        if(NOT skipped)
            list(APPEND ordered ${dep_ordered})
            list(APPEND revisions ${dep_revisions})
        endif()
    endforeach()

    list(APPEND ordered ${module})
    list(APPEND revisions ${arg_REVISION})
    set(${out_ordered} "${ordered}" PARENT_SCOPE)
    set(${out_revisions} "${revisions}" PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Helper macro for pctk_internal_resolve_module_dependencies.
#-----------------------------------------------------------------------------------------------------------------------
macro(pctk_internal_resolve_module_dependencies_set_skipped value)
    if(DEFINED arg_SKIPPED_VAR)
        set(${arg_SKIPPED_VAR} ${value} PARENT_SCOPE)
    endif()
endmacro()


#-----------------------------------------------------------------------------------------------------------------------
# Strips tpctkc- prefix from a repo name.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_normalize_repo_name repo_name out_var)
    string(REGEX REPLACE "^tpctkc-" "" normalized "${repo_name}")
    set(${out_var} "${normalized}" PARENT_SCOPE)
endfunction()

#-----------------------------------------------------------------------------------------------------------------------
# Checks if a directory with the given repo name exists in the current
# source / working directory. If it doesn't, it strips the tpctkc- prefix.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_use_normalized_repo_name_if_needed repo_name out_var)
    set(base_dir "${CMAKE_CURRENT_SOURCE_DIR}")
    set(repo_dir "${base_dir}/${repo_name}")
    if(NOT IS_DIRECTORY "${repo_dir}")
        pctk_internal_normalize_repo_name("${repo_name}" repo_name)
    endif()
    set(${out_var} "${repo_name}" PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Resolves the dependencies of the given modules.
# "Module" is here used in the sense of PCTK repository.
#
# Returns all dependencies, including transitive ones, in topologically sorted order.
#
# Arguments:
# modules is the initial list of repos.
# out_all_ordered is the variable name where the result is stored.
#
# See pctk_internal_resolve_module_dependencies for side effects.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_sort_module_dependencies modules out_all_ordered)
    # Create a fake repository "all_selected_repos" that has all repositories from the input as
    # required dependency. The format must match what pctk_internal_parse_dependencies produces.
    set(all_selected_repos_as_parsed_dependencies)
    foreach(module IN LISTS modules)
        list(APPEND all_selected_repos_as_parsed_dependencies "${module}/HEAD/FALSE")
    endforeach()

    pctk_internal_resolve_module_dependencies(all_selected_repos ordered unused_revisions
        PARSED_DEPENDENCIES ${all_selected_repos_as_parsed_dependencies}
        NORMALIZE_REPO_NAME_IF_NEEDED)

    # Drop "all_selected_repos" from the output. It depends on all selected repos, thus it must be
    # the last element in the topologically sorted list.
    list(REMOVE_AT ordered -1)

    message(DEBUG "pctk_internal_sort_module_dependencies input modules: ${modules}\n    topo-sorted:   ${ordered}")
    set(${out_all_ordered} "${ordered}" PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_apply_win_prefix_and_suffix target)
    if(WIN32)
        # Table of prefix / suffixes for MSVC libraries as qmake expects them to be created.
        # static - pctk_edid_support.lib (platform support libraries / or static pctk_core, etc)
        # shared - pctk_core.dll
        # shared import library - pctk_core.lib
        # module aka PCTK plugin - pctk_windows.dll
        # module import library - pctk_windows.lib
        #
        # The CMake defaults are fine for us.

        # Table of prefix / suffixes for MinGW libraries as qmake expects them to be created.
        # static - pctk_edid_support.a (platform support libraries / or static pctk_core, etc)
        # shared - pctk_core.dll
        # shared import library - libpctk_core.a
        # module aka PCTK plugin - pctk_windows.dll
        # module import library - libpctk_windows.a
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
# Get a set of PCTK module related values based on the target.
#
# The function uses the _pctk_library_interface_name and _pctk_library_include_name target properties to
# preform values for the output variables. _pctk_library_interface_name it's the basic name of module
# without "PCTKfication" and the "Private" suffix if we speak about INTERNAL_LIBRARYs. Typical value of
# the _pctk_library_interface_name is the provided to pctk_internal_add_library ${target} name, e.g. Core.
# _pctk_library_interface_name is used to preform all the include paths unless the
# _pctk_library_include_name property is specified. _pctk_library_include_name is legacy property that
# replaces the module name in include paths and has a higher priority than the
# _pctk_library_interface_name property.
#
# When doing pctk_internal_library_info(foo Core) this method will set the following variables in
# the caller's scope:
#  * foo with the value "PCTKCore"
#  * foo_versioned with the value "PCTKCore" (based on major PCTK version)
#  * foo_upper with the value "CORE"
#  * foo_lower with the value "core"
#  * foo_include_name with the value"PCTKCore"
#    Usually the module name from ${foo} is used, but the name might be different if the
#    LIBRARY_INCLUDE_NAME argument is set when creating the module.
#  * foo_versioned_include_dir with the value "PCTKCore/6.2.0"
#  * foo_versioned_inner_include_dir with the value "PCTKCore/6.2.0/PCTKCore"
#  * foo_private_include_dir with the value "PCTKCore/6.2.0/PCTKCore/private"
#  * foo_qpa_include_dir with the value "PCTKCore/6.2.0/PCTKCore/qpa"
#  * foo_interface_name the interface name of the module stored in _pctk_library_interface_name
#    property, e.g. Core.
#
# The function also sets a bunch of module include paths for the build and install interface.
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
# <build_directory>/pctkbase/include, e.g foo_build_interface_include_dir of the Qml module looks
# like pctk_toplevel_build_dir/pctkbase/include/PCTKQml
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_library_info result target)
    if(result STREQUAL "repo")
        message(FATAL_ERROR "'repo' keyword is reserved for internal use, please specify \
            the different base name for the module info variables.")
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
    #    set("${result}_qpa_include_dir"
    #        "${${result}_versioned_inner_include_dir}/qpa")

    # Module build interface directories
    set(repo_build_interface_include_dir "${PCTK_BUILD_DIR}/include")
    set("${result}_build_interface_include_dir"
        "${repo_build_interface_include_dir}/${${result}_include_name}")
    set("${result}_build_interface_versioned_include_dir"
        "${repo_build_interface_include_dir}/${${result}_versioned_include_dir}")
    set("${result}_build_interface_versioned_inner_include_dir"
        "${repo_build_interface_include_dir}/${${result}_versioned_inner_include_dir}")
    set("${result}_build_interface_private_include_dir"
        "${repo_build_interface_include_dir}/${${result}_private_include_dir}")

    # Module install interface directories
    set(repo_install_interface_include_dir "${INSTALL_INCLUDEDIR}")
    set("${result}_install_interface_include_dir"
        "${repo_install_interface_include_dir}/${${result}_include_name}")
    set("${result}_install_interface_versioned_include_dir"
        "${repo_install_interface_include_dir}/${${result}_versioned_include_dir}")
    set("${result}_install_interface_versioned_inner_include_dir"
        "${repo_install_interface_include_dir}/${${result}_versioned_inner_include_dir}")
    set("${result}_install_interface_private_include_dir"
        "${repo_install_interface_include_dir}/${${result}_private_include_dir}")

    set("${result}" "${module}" PARENT_SCOPE)
    set("${result}_versioned" "${module_versioned}" PARENT_SCOPE)
    string(TOUPPER "${library_interface_name}" upper)
    string(TOLOWER "${library_interface_name}" lower)
    set("${result}_upper" "${upper}" PARENT_SCOPE)
    set("${result}_lower" "${lower}" PARENT_SCOPE)
    set("${result}_include_name" "${${result}_include_name}" PARENT_SCOPE)
    set("${result}_versioned_include_dir" "${${result}_versioned_include_dir}" PARENT_SCOPE)
    set("${result}_versioned_inner_include_dir"
        "${${result}_versioned_inner_include_dir}" PARENT_SCOPE)
    set("${result}_private_include_dir" "${${result}_private_include_dir}" PARENT_SCOPE)
    #    set("${result}_qpa_include_dir" "${${result}_qpa_include_dir}" PARENT_SCOPE)
    set("${result}_interface_name" "${library_interface_name}" PARENT_SCOPE)

    # Setting module build interface directories in parent scope
    set(repo_build_interface_include_dir "${repo_build_interface_include_dir}" PARENT_SCOPE)
    set("${result}_build_interface_include_dir"
        "${${result}_build_interface_include_dir}" PARENT_SCOPE)
    set("${result}_build_interface_versioned_include_dir"
        "${${result}_build_interface_versioned_include_dir}" PARENT_SCOPE)
    set("${result}_build_interface_versioned_inner_include_dir"
        "${${result}_build_interface_versioned_inner_include_dir}" PARENT_SCOPE)
    set("${result}_build_interface_private_include_dir"
        "${${result}_build_interface_private_include_dir}" PARENT_SCOPE)
    #    set("${result}_build_interface_qpa_include_dir"
    #        "${${result}_build_interface_qpa_include_dir}" PARENT_SCOPE)

    # Setting module install interface directories in parent scope
    set(repo_install_interface_include_dir "${repo_install_interface_include_dir}" PARENT_SCOPE)
    set("${result}_install_interface_include_dir"
        "${${result}_install_interface_include_dir}" PARENT_SCOPE)
    set("${result}_install_interface_versioned_include_dir"
        "${${result}_install_interface_versioned_include_dir}" PARENT_SCOPE)
    set("${result}_install_interface_versioned_inner_include_dir"
        "${${result}_install_interface_versioned_inner_include_dir}" PARENT_SCOPE)
    set("${result}_install_interface_private_include_dir"
        "${${result}_install_interface_private_include_dir}" PARENT_SCOPE)
    #    set("${result}_install_interface_qpa_include_dir"
    #        "${${result}_install_interface_qpa_include_dir}" PARENT_SCOPE)
endfunction()


# Generate a module description file based on the template in ModuleDescription.json.in
function(pctk_describe_module target)
    set(path_suffix "${INSTALL_DESCRIPTIONSDIR}")
    pctk_path_join(build_dir ${PCTK_BUILD_DIR} ${path_suffix})
    pctk_path_join(install_dir ${PCTK_INSTALL_DIR} ${path_suffix})

    set(descfile_in "${PCTK_CMAKE_DIR}/ModuleDescription.json.in")
    set(descfile_out "${build_dir}/${target}.json")
    set(cross_compilation "false")
    if(CMAKE_CROSSCOMPILING)
        set(cross_compilation "true")
    endif()

    configure_file("${descfile_in}" "${descfile_out}")

    pctk_install(FILES "${descfile_out}" DESTINATION "${install_dir}")
endfunction()


function(pctk_internal_apply_strict_cpp target)
    # Disable C, Obj-C and C++ GNU extensions aka no "-std=gnu++11".
    # Similar to mkspecs/features/default_post.prf's CONFIG += strict_cpp.
    # Allow opt-out via variable.
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


function(pctk_internal_disable_static_default_plugins target)
    set_target_properties(${target} PROPERTIES PCTK_DEFAULT_PLUGINS 0)
endfunction()


# Generate Win32 RC files for a target. All entries in the RC file are generated
# from target properties:
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
# If you do not wish to auto-generate rc files, it's possible to provide your
# own RC file by setting the property PCTK_TARGET_WINDOWS_RC_FILE with a path to
# an existing rc file.
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
        # However, https://gitlab.kitware.com/cmake/cmake/-/issues/20682 doesn't let us do that
        # in CMake 3.19 and earlier.
        # We can do it in CMake 3.20 and later.
        # And we have to do it with CMake 3.21.0 to avoid a different issue
        # https://gitlab.kitware.com/cmake/cmake/-/issues/22436
        #
        # So use the object lib work around for <= 3.19 and target_sources directly for later
        # versions.
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


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_get_pctk_repo_known_modules out_var)
    set("${out_var}" "${PCTK_REPO_KNOWN_MODULES}" PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
macro(pctk_internal_set_pctk_known_plugins)
    set(PCTK_KNOWN_PLUGINS ${ARGN} CACHE INTERNAL "Known PCTK plugins" FORCE)
endmacro()


#-----------------------------------------------------------------------------------------------------------------------
# Gets the list of all known PCTK modules both found and that were built as part of the current project.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_get_pctk_all_known_modules out_var)
    pctk_internal_get_pctk_repo_known_modules(repo_known_modules)
    set(known_modules ${PCTK_ALL_MODULES_FOUND_VIA_FIND_PACKAGE} ${repo_known_modules})
    list(REMOVE_DUPLICATES known_modules)
    set("${out_var}" "${known_modules}" PARENT_SCOPE)
endfunction()


function(pctk_finalize_module target)
    pctk_finalize_framework_headers_copy(${target})
    pctk_internal_generate_pkg_config_file(${target})
endfunction()