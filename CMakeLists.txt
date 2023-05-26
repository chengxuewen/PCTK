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

set(CMAKE_MESSAGE_LOG_LEVEL DEBUG)
message(STATUS "====================================PCTK========================================")
#-----------------------------------------------------------------------------------------------------------------------
# Set cmake min version and policy
#-----------------------------------------------------------------------------------------------------------------------
cmake_minimum_required(VERSION 3.17)
cmake_policy(SET CMP0075 NEW) # use CMAKE_REQUIRED_LIBRARIES


#-----------------------------------------------------------------------------------------------------------------------
# Set project name and version
#-----------------------------------------------------------------------------------------------------------------------
project(PCTK VERSION 0.1.1.1
    DESCRIPTION "Cpp portable commmon toolkit (PCTK)"
    LANGUAGES CXX C ASM)
set(PCTK_VERSION_NAME ${PROJECT_VERSION})
set(PCTK_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(PCTK_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(PCTK_VERSION_PATCH ${PROJECT_VERSION_PATCH})
set(PCTK_VERSION_TWEAK ${PROJECT_VERSION_TWEAK})
set(PCTK_VERSION ${PCTK_VERSION_MAJOR}.${PCTK_VERSION_MINOR}.${PCTK_VERSION_PATCH})
set(PCTK_SO_VERSION ${PCTK_VERSION_MAJOR}.${PCTK_VERSION_MINOR})
set(PCTK_DEBUG_POSTFIX "d")
set(PCTK_VERSION_STR "${PCTK_VERSION_MAJOR}.${PCTK_VERSION_MINOR}.${PCTK_VERSION_PATCH}")
set(PCTK_COPYRIGHT "Copyright (c) 2021~2023 ChengXueWen 1398831004@qq.com")
set(PCTK_BRIEF "Portable Commmon Toolkit (PCTK)")
set(PCTK_LICENSE "MIT License")
set(PCTK_PROJECT_NAME ${PROJECT_NAME})
math(EXPR PCTK_VERSION_CALC "${PCTK_VERSION_MAJOR}*1000 + ${PCTK_VERSION_MINOR}*100 + ${PCTK_VERSION_PATCH}")
message(STATUS "Project version: ${PCTK_VERSION}")
message(STATUS "Project copyright: ${PCTK_COPYRIGHT}")
message(STATUS "Project brief: ${PCTK_BRIEF}")
message(STATUS "Project license: ${PCTK_LICENSE}")
set(CMAKE_STAGING_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/install")


#-----------------------------------------------------------------------------------------------------------------------
# Set the rpath for executables
#-----------------------------------------------------------------------------------------------------------------------
set(CMAKE_LINK_DEPENDS_NO_SHARED ON) # Do not relink dependent libraries when no header has changed:
set(CMAKE_SKIP_BUILD_RPATH OFF) # use, i.e. don't skip the full RPATH for the build tree
set(CMAKE_BUILD_WITH_INSTALL_RPATH OFF) # when building, don't use the install RPATH already (but later on when installing)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH OFF) # NO automatic rpath for INSTALL


#-----------------------------------------------------------------------------------------------------------------------
# Detect prefix and install
#-----------------------------------------------------------------------------------------------------------------------
# Pre-calculate the developer_build feature if it's set by the user via INPUT_PCTK_FEATURE_DEV_BUILD
if(NOT PCTK_FEATURE_DEV_BUILD AND INPUT_PCTK_FEATURE_DEV_BUILD AND NOT "${INPUT_PCTK_FEATURE_DEV_BUILD}" STREQUAL "undefined")
    set(PCTK_FEATURE_DEV_BUILD ON)
endif()

# Pre-calculate the no_prefix feature if it's set by configure via INPUT_PCTK_FEATURE_NO_PREFIX.
# This needs to be done before configure.cmake is processed.
if(NOT PCTK_FEATURE_NO_PREFIX AND INPUT_PCTK_FEATURE_NO_PREFIX AND NOT "${INPUT_PCTK_FEATURE_NO_PREFIX}" STREQUAL "undefined")
    set(PCTK_FEATURE_NO_PREFIX ON)
endif()

if(NOT PCTK_BUILD_STANDALONE_TESTS)
    if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
        # Handle both FEATURE_ and PCTK_FEATURE_ cases when they are specified on the command line explicitly.
        # It's possible for one to be set, but not the other, because core/configure.cmake is not processed by this point.
        if((PCTK_FEATURE_DEV_BUILD OR PCTK_FEATURE_NO_PREFIX) AND NOT CMAKE_STAGING_PREFIX)
            # Handle non-prefix builds by setting the CMake install prefix to point to PCTK's build dir.
            set(PCTK_DEFAULT_PREFIX "${PCTK_BINARY_DIR}")
        else()
            if(CMAKE_HOST_WIN32)
                set(PCTK_DEFAULT_PREFIX "C:/PCTK/")
            else()
                set(PCTK_DEFAULT_PREFIX "/usr/local/")
            endif()
            string(APPEND PCTK_DEFAULT_PREFIX "PCTK-${PCTK_VERSION}")
        endif()
        set(CMAKE_INSTALL_PREFIX ${PCTK_DEFAULT_PREFIX} CACHE PATH "Install path prefix, prepended onto install directories." FORCE)
    endif()
    if(CMAKE_STAGING_PREFIX)
        set(PCTK_PREFIX "${CMAKE_STAGING_PREFIX}")
    else()
        set(PCTK_PREFIX "${CMAKE_INSTALL_PREFIX}")
    endif()
    if(PCTK_PREFIX STREQUAL PCTK_BINARY_DIR)
        set(PCTK_WILL_INSTALL_VALUE OFF)
    else()
        set(PCTK_WILL_INSTALL_VALUE ON)
    endif()
    set(PCTK_WILL_INSTALL ${PCTK_WILL_INSTALL_VALUE} CACHE BOOL "Boolean indicating if doing a PCTK prefix build (vs non-prefix build)." FORCE)
endif()

if(PCTK_FEATURE_DEV_BUILD)
    if(DEFINED PCTK_CMAKE_EXPORT_COMPILE_COMMANDS)
        set(CMAKE_EXPORT_COMPILE_COMMANDS ${PCTK_CMAKE_EXPORT_COMPILE_COMMANDS})
    else()
        set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
    endif()
    set(__pctk_build_warnings_as_errors ON)
    set(__pctk_build_tests_default ON)
    set(__pctk_build_benchmarks ON)

    # Tests are not built by default with qmake for iOS and friends, and thus the overall build
    # tends to fail. Disable them by default when targeting uikit.
    if(UIKIT OR ANDROID)
        set(__pctk_build_tests_default OFF)
    endif()

    # Disable benchmarks for single configuration generators which do not build
    # with release configuration.
    if(CMAKE_BUILD_TYPE AND CMAKE_BUILD_TYPE STREQUAL Debug)
        set(__pctk_build_benchmarks OFF)
    endif()
else()
    set(__pctk_build_warnings_as_errors OFF)
    set(__pctk_build_tests_default OFF)
    set(__pctk_build_benchmarks OFF)
endif()

# When cross-building, we don't build tools by default. Sometimes this also covers pctk apps as well.
set(__pctk_build_tools_default ON)
if(CMAKE_CROSSCOMPILING AND NOT PCTK_FORCE_BUILD_TOOLS)
    set(__pctk_build_tools_default OFF)
endif()


#-----------------------------------------------------------------------------------------------------------------------
# Decide whether output should be verbose or not. # Default to verbose (--log-level=STATUS) in a developer-build and
# non-verbose (--log-level=NOTICE) otherwise. If a custom CMAKE_MESSAGE_LOG_LEVEL was specified, it takes priority.
# Passing an explicit --log-level=Foo has the highest priority.
#-----------------------------------------------------------------------------------------------------------------------
if(NOT CMAKE_MESSAGE_LOG_LEVEL)
    if(PCTK_FEATURE_DEV_BUILD)
        set(CMAKE_MESSAGE_LOG_LEVEL "STATUS")
    else()
        set(CMAKE_MESSAGE_LOG_LEVEL "NOTICE")
    endif()
endif()


#-----------------------------------------------------------------------------------------------------------------------
# Set build type
#-----------------------------------------------------------------------------------------------------------------------
set(PCTK_DEFAULT_BUILD_TYPE "Release")
if(PCTK_FEATURE_DEV_BUILD)
    set(PCTK_DEFAULT_BUILD_TYPE "Debug")
endif()
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Setting build type to '${PCTK_DEFAULT_BUILD_TYPE}' as none was specified.")
    set(CMAKE_BUILD_TYPE "${PCTK_DEFAULT_BUILD_TYPE}" CACHE STRING "Choose the type of build." FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE
        PROPERTY STRINGS
        "Debug" "Release" "MinSizeRel" "RelWithDebInfo") # Set the possible values for cmake-gui.
elseif(CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Building for multiple configurations: ${CMAKE_CONFIGURATION_TYPES}.")
    message(STATUS "Main configuration is: ${PCTK_MULTI_CONFIG_FIRST_CONFIG}.")
    if(CMAKE_NINJA_MULTI_DEFAULT_BUILD_TYPE)
        message(STATUS "Default build configuration set to '${CMAKE_NINJA_MULTI_DEFAULT_BUILD_TYPE}'.")
    endif()
    if(CMAKE_GENERATOR STREQUAL "Ninja")
        message(FATAL_ERROR
            "It's not possible to build multiple configurations with the single config Ninja "
            "generator. Consider configuring with -G\"Ninja Multi-Config\" instead of -GNinja.")
    endif()
else()
    message(STATUS "CMAKE_BUILD_TYPE was set to: '${CMAKE_BUILD_TYPE}'")
endif()


#-----------------------------------------------------------------------------------------------------------------------
# Set multi-config
# Append a config-specific postfix to library names to ensure distinct names in a multi-config build. e.g.
# lib/libpctk_core_relwithdebinfo.0.1.1.dylib
# Don't apply the postfix to the first encountered release-like config, so we have at least one config without a postifx.
#-----------------------------------------------------------------------------------------------------------------------
# Save the global property in a variable to make it available to feature conditions.
get_property(PCTK_GENERATOR_IS_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(PCTK_GENERATOR_IS_MULTI_CONFIG AND CMAKE_CONFIGURATION_TYPES)
    set(__pctk_setup_release_configs Release RelWithDebInfo MinSizeRel)
    set(__pctk_setup_found_first_release_config FALSE)
    foreach(__pctk_setup_config_type IN LISTS CMAKE_CONFIGURATION_TYPES)
        # Skip assigning postfix for the first release-like config.
        if(NOT __pctk_setup_found_first_release_config AND __pctk_setup_config_type IN_LIST __pctk_setup_release_configs)
            set(__pctk_setup_found_first_release_config TRUE)
            continue()
        endif()

        string(TOLOWER "${__pctk_setup_config_type}" __pctk_setup_config_type_lower)
        string(TOUPPER "${__pctk_setup_config_type}" __pctk_setup_config_type_upper)
        set(CMAKE_${__pctk_setup_config_type_upper}_POSTFIX "_${__pctk_setup_config_type_lower}")
        if(APPLE)
            set(CMAKE_FRAMEWORK_MULTI_CONFIG_POSTFIX_${__pctk_setup_config_type_upper} "_${__pctk_setup_config_type_lower}")
        endif()
    endforeach()
endif()

# Override the generic debug postfixes above with custom debug postfixes (even in a single config build) to follow the
# conventions we had. lib/libpctk_core_debug.6.3.0.dylib
if(WIN32)
    if(MINGW)
        # On MinGW we don't have "d" suffix for debug libraries like on Linux, unless we're building debug and release
        # libraries in one go.
        if(PCTK_GENERATOR_IS_MULTI_CONFIG)
            set(CMAKE_DEBUG_POSTFIX "d")
        endif()
    else()
        set(CMAKE_DEBUG_POSTFIX "d")
    endif()
elseif(APPLE)
    set(CMAKE_DEBUG_POSTFIX "_debug")
    set(CMAKE_FRAMEWORK_MULTI_CONFIG_POSTFIX_DEBUG "_debug")
endif()

## Position independent code:
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Does the linker support position independent code?
include(CheckPIESupported)
check_pie_supported()

# Do not relink dependent libraries when no header has changed:
set(CMAKE_LINK_DEPENDS_NO_SHARED ON)


#-----------------------------------------------------------------------------------------------------------------------
# Add CMake function(s) and macro(s)
#-----------------------------------------------------------------------------------------------------------------------
set(PCTK_CMAKE_DIR "${PROJECT_SOURCE_DIR}/cmake")
set(CMAKE_MODULE_PATH ${PCTK_CMAKE_DIR} ${CMAKE_MODULE_PATH})
# Internal helpers available only while building PCTK itself.
#include(PCTK3rdPartyLibraryHelpers)
#include(PCTKAppHelpers)
#include(PCTKAutogenHelpers)
include(PCTKCMakeHelpers)
include(PCTKCMakeVersionHelpers)
include(PCTKOptionHelpers)
include(PCTKConfigureHelpers)
include(PCTKCompilerHelpers)
#include(PCTKDeferredDependenciesHelpers)
include(PCTKScopeFinalizerHelpers)
include(PCTKSeparateDebugInfo)
#include(PCTKDocsHelpers)
include(PCTKDoxygenHelpers)
include(PCTKExecutableHelpers)
include(PCTKFindPackageHelpers)
include(PCTKFlagHandlingHelpers)
include(PCTKGlobalStateHelpers)
include(PCTKSubdirectoryHelpers)
include(PCTKSyncIncludeHelpers)
include(PCTKFrameworkHelpers)
include(PCTKInstallHelpers)
include(PCTKModuleHelpers)
include(PCTKLibraryHelpers)
#include(PCTKNoLinkTargetHelpers)
include(PCTKPathHasSymlinksCheck)
include(PCTKPluginHelpers)
include(PCTKPrecompiledHelpers)
include(PCTKPkgConfigHelpers)
include(PCTKResourceHelpers)
include(PCTKRpathHelpers)
include(PCTKModuleHelpers)
include(PCTKTargetHelpers)
include(PCTKTestHelpers)
include(PCTKToolHelpers)
#include(PCTKHeadersClean)
#include(PCTKJavaHelpers)
if(ANDROID)
    include(PCTKAndroidHelpers)
endif()
if(WASM)
    include(PCTKWasmHelpers)
endif()
# Helpers that are available in public projects and while building PCTK itself.
#include(PCTKPublicAppleHelpers)
#include(PCTKPublicCMakeHelpers)
#include(PCTKPublicPluginHelpers)
include(PCTKPublicTargetHelpers)
include(PCTKPublicWalkLibsHelpers)
#include(PCTKPublicFindPackageHelpers)
include(PCTKPublicDependencyHelpers)
#include(PCTKPublicTestHelpers)
#include(PCTKPublicToolHelpers)


#-----------------------------------------------------------------------------------------------------------------------
# Set build options
#-----------------------------------------------------------------------------------------------------------------------
pctk_option(PCTK_BUILD_ALL "Enable this to build all artifacts" OFF)
pctk_option(PCTK_BUILD_SHARED_LIBS "Enable this to build as dynamically" ON
    SET BUILD_SHARED_LIBS)
pctk_option(PCTK_BUILD_USE_PCH "Enable this to build use precompiled header files for compilation" ON
    DEPENDS PCTK_BUILD_SHARED_LIBS)
pctk_option(PCTK_BUILD_COMPILER_WARNING "Enable this to build target with compiler warnings" OFF)
pctk_option(PCTK_BUILD_WARNINGS_ARE_ERRORS "Build PCTK with warnings as errors" ${__pctk_build_warnings_as_errors})
pctk_option(PCTK_BUILD_BENCHMARKS "Enable this to build the benchmarks" ${__pctk_build_benchmarks}
    SET __pctk_build_tests_default)
pctk_option(PCTK_BUILD_EXAMPLES "Enable this to build examples" ON)
pctk_option(PCTK_BUILD_TESTS "Enable this to build tests" OFF)
pctk_option(PCTK_BUILD_MINIMAL_STATIC_TESTS "Build minimal subset of tests for static PCTK builds" ON)
pctk_option(PCTK_BUILD_PLUGINS "Enable this to build the plugins." ON)
pctk_option(PCTK_BUILD_TOOLS "Enable this to build the tools." "${__pctk_build_tools_default}")
pctk_option(PCTK_BUILD_APPS "Enable this to build apps" ON)
pctk_option(PCTK_BUILD_DOCUMENTATION "Enable this to build the documentation" ON)


#-----------------------------------------------------------------------------------------------------------------------
# Set install and paths
#-----------------------------------------------------------------------------------------------------------------------
# Install locations:
pctk_configure_process_path(INSTALL_BINDIR "bin" "Executables [PREFIX/bin]")
pctk_configure_process_path(INSTALL_INCLUDEDIR "include" "Header files [PREFIX/include]")
pctk_configure_process_path(INSTALL_LIBDIR "lib" "Libraries [PREFIX/lib]")
pctk_configure_process_path(INSTALL_MKSPECSDIR "mkspecs" "Mkspecs files [PREFIX/mkspecs]")
pctk_configure_process_path(INSTALL_ARCHDATADIR "." "Arch-dependent data [PREFIX]")
pctk_configure_process_path(INSTALL_PLUGINSDIR "${INSTALL_ARCHDATADIR}/plugins" "Plugins [ARCHDATADIR/plugins]")

if(NOT INSTALL_MKSPECSDIR MATCHES "(^|/)mkspecs")
    message(FATAL_ERROR "INSTALL_MKSPECSDIR must end with '/mkspecs'")
endif()

if(WIN32)
    set(_default_libexec "${INSTALL_ARCHDATADIR}/bin")
else()
    set(_default_libexec "${INSTALL_ARCHDATADIR}/libexec")
endif()

pctk_configure_process_path(INSTALL_LIBEXECDIR
    "${_default_libexec}" "Helper programs [ARCHDATADIR/bin on Windows, ARCHDATADIR/libexec otherwise]")
pctk_configure_process_path(INSTALL_QMLDIR "${INSTALL_ARCHDATADIR}/qml" "QML imports [ARCHDATADIR/qml]")
pctk_configure_process_path(INSTALL_DATADIR "." "Arch-independent data [PREFIX]")
pctk_configure_process_path(INSTALL_DOCDIR "${INSTALL_DATADIR}/doc" "Documentation [DATADIR/doc]")
pctk_configure_process_path(INSTALL_TRANSLATIONSDIR "${INSTALL_DATADIR}/translations" "Translations [DATADIR/translations]")
if(APPLE)
    set(PCTK_DEFAULT_SYS_CONF_DIR "/Library/Preferences/PCTK")
else()
    set(PCTK_DEFAULT_SYS_CONF_DIR "etc/xdg")
endif()
pctk_configure_process_path(INSTALL_SYSCONFDIR
    "${PCTK_DEFAULT_SYS_CONF_DIR}" "Settings used by PCTK programs [PREFIX/etc/xdg]/[/Library/Preferences/PCTK]")
pctk_configure_process_path(INSTALL_EXAMPLESDIR "examples" "Examples [PREFIX/examples]")
pctk_configure_process_path(INSTALL_TESTSDIR "tests" "Tests [PREFIX/tests]")
pctk_configure_process_path(INSTALL_DESCRIPTIONSDIR
    "${INSTALL_DATADIR}/modules" "Module description files directory")

if(NOT "${CMAKE_STAGING_PREFIX}" STREQUAL "")
    set(PCTK_STAGING_PREFIX "${CMAKE_STAGING_PREFIX}")
else()
    set(PCTK_STAGING_PREFIX "${CMAKE_INSTALL_PREFIX}")
endif()

function(pctk_internal_set_up_global_paths)
    # Compute the values of PCTK_BUILD_DIR, PCTK_INSTALL_DIR, PCTK_CONFIG_BUILD_DIR, PCTK_CONFIG_INSTALL_DIR
    # taking into account whether the current build is a prefix build or a non-prefix build,
    # and whether it is a superbuild or non-superbuild.
    # A third case is when another module or standalone tests are built against a super-built PCTK.
    # The layout for the third case is the same as for non-superbuilds.
    #
    # These values should be prepended to file paths in commands or properties,
    # in order to correctly place generated Config files, generated Targets files,
    # executables / libraries, when copying / installing files, etc.
    #
    # The build dir variables will always be absolute paths.
    # The PCTK_INSTALL_DIR variable will have a relative path in a prefix build,
    # which means that it can be empty, so use pctk_join_path to prevent accidental absolute paths.
    if(PCTK_SUPERBUILD)
        # In this case, we always copy all the build products in PCTK_BUILD_DIR/{bin,lib,...}
        if(PCTK_WILL_INSTALL)
            set(PCTK_BUILD_DIR "${PCTK_BINARY_DIR}")
            set(PCTK_INSTALL_DIR "")
        else()
            if("${CMAKE_STAGING_PREFIX}" STREQUAL "")
                set(PCTK_BUILD_DIR "${PCTK_BINARY_DIR}")
                set(PCTK_INSTALL_DIR "${PCTK_BINARY_DIR}")
            else()
                set(PCTK_BUILD_DIR "${CMAKE_STAGING_PREFIX}")
                set(PCTK_INSTALL_DIR "${CMAKE_STAGING_PREFIX}")
            endif()
        endif()
    else()
        if(PCTK_WILL_INSTALL)
            # In the usual prefix build case, the build dir is the current module build dir,
            # and the install dir is the prefix, so we don't set it.
            set(PCTK_BUILD_DIR "${CMAKE_BINARY_DIR}")
            set(PCTK_INSTALL_DIR "")
        else()
            # When doing a non-prefix build, both the build dir and install dir are the same, pointing to the PCTK build dir.
            set(PCTK_BUILD_DIR "${PCTK_STAGING_PREFIX}")
            set(PCTK_INSTALL_DIR "${PCTK_BUILD_DIR}")
        endif()
    endif()

    set(__config_path_part "${INSTALL_LIBDIR}/cmake")
    set(PCTK_CONFIG_BUILD_DIR "${PCTK_BUILD_DIR}/${__config_path_part}")
    set(PCTK_CONFIG_INSTALL_DIR "${PCTK_INSTALL_DIR}")
    if(PCTK_CONFIG_INSTALL_DIR)
        string(APPEND PCTK_CONFIG_INSTALL_DIR "/")
    endif()
    string(APPEND PCTK_CONFIG_INSTALL_DIR ${__config_path_part})

    set(PCTK_BUILD_DIR "${PCTK_BUILD_DIR}" PARENT_SCOPE)
    set(PCTK_INSTALL_DIR "${PCTK_INSTALL_DIR}" PARENT_SCOPE)
    set(PCTK_CONFIG_BUILD_DIR "${PCTK_CONFIG_BUILD_DIR}" PARENT_SCOPE)
    set(PCTK_CONFIG_INSTALL_DIR "${PCTK_CONFIG_INSTALL_DIR}" PARENT_SCOPE)
endfunction()
pctk_internal_set_up_global_paths()


###TODO:del
## Find the path to mkspecs/, depending on whether we are building as part of a standard pctkbuild,
## or a module against an already installed version of pctk.
#if(NOT PCTK_MKSPECS_DIR)
#    if("${PCTK_BUILD_INTERNALS_PATH}" STREQUAL "")
#        get_filename_component(PCTK_MKSPECS_DIR "${CMAKE_CURRENT_LIST_DIR}/../mkspecs" ABSOLUTE)
#    else()
#        # We can rely on PCTK_BUILD_INTERNALS_RELOCATABLE_INSTALL_PREFIX being set by
#        # PCTKBuildInternalsExtra.cmake.
#        get_filename_component(PCTK_MKSPECS_DIR
#            "${PCTK_BUILD_INTERNALS_RELOCATABLE_INSTALL_PREFIX}/${INSTALL_MKSPECSDIR}" ABSOLUTE)
#    endif()
#    set(PCTK_MKSPECS_DIR "${PCTK_MKSPECS_DIR}" CACHE INTERNAL "")
#endif()

# the default RPATH to be used when installing, but only if it's not a system directory
list(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/${INSTALL_LIBDIR}" isSystemDir)
if("${isSystemDir}" STREQUAL "-1")
    set(_default_install_rpath "${CMAKE_INSTALL_PREFIX}/${INSTALL_LIBDIR}")
endif("${isSystemDir}" STREQUAL "-1")

# The default rpath settings for installed targets is empty.
# The rpaths will instead be computed for each target separately using pctk_apply_rpaths().
# Additional rpaths can be passed via PCTK_EXTRA_RPATHS.
# By default this will include $ORIGIN / @loader_path, so the installation is relocatable.
# Bottom line: No need to pass anything to CMAKE_INSTALL_RPATH.
set(CMAKE_INSTALL_RPATH "" CACHE STRING "RPATH for installed binaries")

# By default, don't embed auto-determined RPATHs pointing to directories
# outside of the build tree, into the installed binaries.
# This ended up adding rpaths like ${CMAKE_INSTALL_PREFIX}/lib (or /Users/pctk/work/install/lib into
# the official libraries created by the CI) into the non-pctkbase libraries, plugins, etc.
#
# It should not be necessary, given that pctk_apply_rpaths() already adds the necessary rpaths, either
# relocatable ones or absolute ones, depending on what the platform supports.
if(NOT PCTK_NO_DISABLE_CMAKE_INSTALL_RPATH_USE_LINK_PATH)
    set(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)
endif()

# Ensure that GNUInstallDirs's CMAKE_INSTALL_LIBDIR points to the same lib dir that PCTK was
# configured with. Currently this is important for QML plugins, which embed an rpath based
# on that value.
set(CMAKE_INSTALL_LIBDIR "${INSTALL_LIBDIR}")

function(pctk_setup_tool_path_command)
    if(NOT CMAKE_HOST_WIN32)
        return()
    endif()
    set(bindir "${PCTK_BUILD_INTERNALS_RELOCATABLE_INSTALL_PREFIX}/${INSTALL_BINDIR}")
    file(TO_NATIVE_PATH "${bindir}" bindir)
    list(APPEND command COMMAND)
    list(APPEND command set PATH=${bindir}$<SEMICOLON>%PATH%)
    set(PCTK_TOOL_PATH_SETUP_COMMAND "${command}" CACHE INTERNAL "internal command prefix for tool invocations" FORCE)
    # PCTK_TOOL_PATH_SETUP_COMMAND is deprecated. Please use _pctk_internal_get_wrap_tool_script_path
    # instead.
endfunction()
pctk_setup_tool_path_command()


#-----------------------------------------------------------------------------------------------------------------------
# Set platform and mkspecs define
#-----------------------------------------------------------------------------------------------------------------------
include(PCTKPlatformSupport)


#-----------------------------------------------------------------------------------------------------------------------
# Set namespace and separator
#-----------------------------------------------------------------------------------------------------------------------
set(PCTK_NAMESPACE_VERSION ${PCTK_VERSION_MAJOR})
if(0 EQUAL ${PCTK_VERSION_MAJOR})
    set(PCTK_NAMESPACE_VERSION "")
endif()
set(PCTK_NAMESPACE "" CACHE STRING "PCTK Namespace")
if(NOT INSTALL_CMAKE_NAMESPACE)
    set(INSTALL_CMAKE_NAMESPACE "PCTK${PCTK_NAMESPACE_VERSION}"
        CACHE STRING "CMake namespace [PCTK${PCTK_NAMESPACE_VERSION}]")
endif()
if(NOT PCTK_CMAKE_EXPORT_NAMESPACE)
    set(PCTK_CMAKE_EXPORT_NAMESPACE "PCTK${PCTK_NAMESPACE_VERSION}"
        CACHE STRING "CMake namespace used when exporting targets [PCTK${PCTK_NAMESPACE_VERSION}]")
endif()

set(PCTK_KNOWN_LIBRARIES_WITH_TOOLS "" CACHE INTERNAL "Known PCTK modules with tools" FORCE)

# For adjusting variables when running tests, we need to know what
# the correct variable is for separating entries in PATH-alike
# variables.
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    set(PCTK_PATH_SEPARATOR "\\;")
else()
    set(PCTK_PATH_SEPARATOR ":")
endif()


#-----------------------------------------------------------------------------------------------------------------------
# Prevent warnings about object files without any symbols. This is a common thing in PCTK as we tend to build files
# unconditionally, and then use ifdefs to compile out parts that are not relevant.
#-----------------------------------------------------------------------------------------------------------------------
if(CMAKE_HOST_APPLE AND APPLE)
    foreach(lang ASM C CXX)
        # We have to tell 'ar' to not run ranlib by itself, by passing the 'S' option
        set(CMAKE_${lang}_ARCHIVE_CREATE "<CMAKE_AR> qcS <TARGET> <LINK_FLAGS> <OBJECTS>")
        set(CMAKE_${lang}_ARCHIVE_APPEND "<CMAKE_AR> qS <TARGET> <LINK_FLAGS> <OBJECTS>")
        set(CMAKE_${lang}_ARCHIVE_FINISH "<CMAKE_RANLIB> -no_warning_for_no_symbols <TARGET>")
    endforeach()
endif()



#-----------------------------------------------------------------------------------------------------------------------
# build directory check
#-----------------------------------------------------------------------------------------------------------------------
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    message(FATAL_ERROR "In-source builds not allowed. Please make a new directory (called a build directory) and run "
        "CMake from there. You may need to remove CMakeCache.txt.")
endif()

if(CMAKE_CROSSCOMPILING AND NOT IS_DIRECTORY "${PCTK_HOST_PATH}")
    message(FATAL_ERROR "You need to set PCTK_HOST_PATH to cross compile PCTK.")
endif()


#-----------------------------------------------------------------------------------------------------------------------
# Set default param args
#-----------------------------------------------------------------------------------------------------------------------
set(PCTK_DEFAULT_PRIVATE_ARGS
    DEFINES
    SOURCES
    LIBRARIES
    INCLUDE_DIRECTORIES
    FEATURE_DEPENDENCIES
    COMPILE_OPTIONS
    LINK_OPTIONS
    PLUGIN_TYPES)
set(PCTK_DEFAULT_PUBLIC_ARGS
    PUBLIC_DEFINES
    PUBLIC_LIBRARIES
    PUBLIC_INCLUDE_DIRECTORIES
    PUBLIC_COMPILE_OPTIONS
    PUBLIC_LINK_OPTIONS)
set(PCTK_DEFAULT_PRIVATE_LIBRARY_ARGS
    PRIVATE_LIBRARY_INTERFACE)
set(PCTK_DEFAULT_TARGET_INFO_ARGS
    TARGET_VERSION
    TARGET_PRODUCT
    TARGET_DESCRIPTION
    TARGET_COMPANY
    TARGET_COPYRIGHT)


# Collection of arguments so they can be shared across pctk_internal_add_executable and pctk_internal_add_test_helper.
set(PCTK_INTERNAL_ADD_EXECUTABLE_OPTIONAL_ARGS
    GUI
    NO_INSTALL
    EXCEPTIONS
    DELAY_RC
    DELAY_TARGET_INFO
    PCTK_APP)
set(PCTK_INTERNAL_ADD_EXECUTABLE_SINGLE_ARGS
    CORE_LIBRARY
    OUTPUT_DIRECTORY
    INSTALL_DIRECTORY
    VERSION
    ${PCTK_DEFAULT_TARGET_INFO_ARGS})
set(PCTK_INTERNAL_ADD_EXECUTABLE_MULTI_ARGS
    ${PCTK_DEFAULT_PRIVATE_ARGS}
    ${PCTK_DEFAULT_PUBLIC_ARGS})


#-----------------------------------------------------------------------------------------------------------------------
# add subdirectory
#-----------------------------------------------------------------------------------------------------------------------
# Bail out if any part of the build directory's path is symlinked.
pctk_internal_check_if_path_has_symlinks("${CMAKE_BINARY_DIR}")

#pctk_build_repo_begin()

## Targets for global features, etc.:
#include(PCTKGlobalTargets)

## Should this Qt be built with Werror?
# Find Apple frameworks if needed.
pctk_find_apple_system_frameworks()
# Decide whether tools will be built.
pctk_check_if_tools_will_be_built()

pctk_add_subdirectory(src/libs)
pctk_add_subdirectory(src/apps PCTK_BUILD_APPS)
pctk_add_subdirectory(src/tools PCTK_BUILD_TOOLS)
pctk_add_subdirectory(src/plugins PCTK_BUILD_PLUGINS)
pctk_add_subdirectory(src/bundles TARGET Osgi)

#pctk_build_repo_end()

#pctk_internal_create_depends_files()
if(PCTK_BUILD_TESTS)
    include(CTest)
    enable_testing()
    add_subdirectory(3rdparty/cpputest-4.0)
endif()