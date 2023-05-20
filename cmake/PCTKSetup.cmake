## Set a default build type if none was specified

# Set the PCTK_IS_BUILDING_PCTK variable so we can verify whether we are building
# PCTK from source
set(PCTK_BUILDING_PCTK TRUE CACHE
    TYPE STRING "When this is present and set to true, it signals that we are building PCTK from source.")

# Pre-calculate the developer_build feature if it's set by the user via INPUT_developer_build
if(NOT FEATURE_developer_build AND INPUT_developer_build
    AND NOT "${INPUT_developer_build}" STREQUAL "undefined")
    set(FEATURE_developer_build ON)
endif()

# Pre-calculate the no_prefix feature if it's set by configure via INPUT_no_prefix.
# This needs to be done before pctkbase/configure.cmake is processed.
if(NOT FEATURE_no_prefix AND INPUT_no_prefix
    AND NOT "${INPUT_no_prefix}" STREQUAL "undefined")
    set(FEATURE_no_prefix ON)
endif()

set(_default_build_type "Release")
if(FEATURE_developer_build)
    set(_default_build_type "Debug")
endif()

function(pctk_internal_set_message_log_level out_var)
    # Decide whether output should be verbose or not.
    # Default to verbose (--log-level=STATUS) in a developer-build and
    # non-verbose (--log-level=NOTICE) otherwise.
    # If a custom CMAKE_MESSAGE_LOG_LEVEL was specified, it takes priority.
    # Passing an explicit --log-level=Foo has the highest priority.
    if(NOT CMAKE_MESSAGE_LOG_LEVEL)
        if(FEATURE_developer_build OR PCTK_FEATURE_developer_build)
            set(CMAKE_MESSAGE_LOG_LEVEL "STATUS")
        else()
            set(CMAKE_MESSAGE_LOG_LEVEL "NOTICE")
        endif()
        set(${out_var} "${CMAKE_MESSAGE_LOG_LEVEL}" PARENT_SCOPE)
    endif()
endfunction()
pctk_internal_set_message_log_level(CMAKE_MESSAGE_LOG_LEVEL)

# Reset content of extra build internal vars for each inclusion of PCTKSetup.
unset(PCTK_EXTRA_BUILD_INTERNALS_VARS)

# Save the global property in a variable to make it available to feature conditions.
get_property(PCTK_GENERATOR_IS_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Setting build type to '${_default_build_type}' as none was specified.")
    set(CMAKE_BUILD_TYPE "${_default_build_type}" CACHE STRING "Choose the type of build." FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE
        PROPERTY STRINGS
        "Debug" "Release" "MinSizeRel" "RelWithDebInfo") # Set the possible values for cmake-gui.
elseif(CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Building for multiple configurations: ${CMAKE_CONFIGURATION_TYPES}.")
    message(STATUS "Main configuration is: ${PCTK_MULTI_CONFIG_FIRST_CONFIG}.")
    if(CMAKE_NINJA_MULTI_DEFAULT_BUILD_TYPE)
        message(STATUS
            "Default build configuration set to '${CMAKE_NINJA_MULTI_DEFAULT_BUILD_TYPE}'.")
    endif()
    if(CMAKE_GENERATOR STREQUAL "Ninja")
        message(FATAL_ERROR
            "It's not possible to build multiple configurations with the single config Ninja "
            "generator. Consider configuring with -G\"Ninja Multi-Config\" instead of -GNinja.")
    endif()
else()
    message(STATUS "CMAKE_BUILD_TYPE was set to: '${CMAKE_BUILD_TYPE}'")
endif()

# Append a config-specific postfix to library names to ensure distinct names
# in a multi-config build.
# e.g. lib/libPCTK6DBus_relwithdebinfo.6.3.0.dylib
# Don't apply the postfix to the first encountered release-like config, so we have at least one
# config without a postifx.
if(PCTK_GENERATOR_IS_MULTI_CONFIG AND CMAKE_CONFIGURATION_TYPES)
    set(__pctk_setup_release_configs Release RelWithDebInfo MinSizeRel)
    set(__pctk_setup_found_first_release_config FALSE)
    foreach(__pctk_setup_config_type IN LISTS CMAKE_CONFIGURATION_TYPES)
        # Skip assigning postfix for the first release-like config.
        if(NOT __pctk_setup_found_first_release_config
            AND __pctk_setup_config_type IN_LIST __pctk_setup_release_configs)
            set(__pctk_setup_found_first_release_config TRUE)
            continue()
        endif()

        string(TOLOWER "${__pctk_setup_config_type}" __pctk_setup_config_type_lower)
        string(TOUPPER "${__pctk_setup_config_type}" __pctk_setup_config_type_upper)
        set(CMAKE_${__pctk_setup_config_type_upper}_POSTFIX "_${__pctk_setup_config_type_lower}")
        if(APPLE)
            set(CMAKE_FRAMEWORK_MULTI_CONFIG_POSTFIX_${__pctk_setup_config_type_upper}
                "_${__pctk_setup_config_type_lower}")
        endif()
    endforeach()
endif()

# Override the generic debug postfixes above with custom debug postfixes (even in a single config
# build) to follow the conventions we had since PCTK 5.
# e.g. lib/libPCTK6DBus_debug.6.3.0.dylib
if(WIN32)
    if(MINGW)
        # On MinGW we don't have "d" suffix for debug libraries like on Linux,
        # unless we're building debug and release libraries in one go.
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

# Detect non-prefix builds: either when the pctkbase install prefix is set to the binary dir
# or when a developer build is explicitly enabled and no install prefix (or staging prefix)
# is specified.
# This detection only happens when building pctkbase, and later is propagated via the generated
# PCTKBuildInternalsExtra.cmake file.
if(PROJECT_NAME STREQUAL "PCTK" AND NOT PCTK_BUILD_STANDALONE_TESTS)
    if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
        # Handle both FEATURE_ and PCTK_FEATURE_ cases when they are specified on the command line
        # explicitly. It's possible for one to be set, but not the other, because
        # pctkbase/configure.cmake is not processed by this point.
        if((FEATURE_developer_build
            OR PCTK_FEATURE_developer_build
            OR FEATURE_no_prefix
            OR PCTK_FEATURE_no_prefix
            )
            AND NOT CMAKE_STAGING_PREFIX)
            # Handle non-prefix builds by setting the CMake install prefix to point to pctkbase's
            # build dir. While building another repo (like pctksvg) the CMAKE_PREFIX_PATH should be
            # set on the command line to point to the pctkbase build dir.
            set(__pctk_default_prefix "${PCTK_BINARY_DIR}")
        else()
            if(CMAKE_HOST_WIN32)
                set(__pctk_default_prefix "C:/PCTK/")
            else()
                set(__pctk_default_prefix "/usr/local/")
            endif()
            string(APPEND __pctk_default_prefix
                "PCTK-${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")
        endif()
        set(CMAKE_INSTALL_PREFIX ${__pctk_default_prefix} CACHE PATH
            "Install path prefix, prepended onto install directories." FORCE)
        unset(__pctk_default_prefix)
    endif()
    if(CMAKE_STAGING_PREFIX)
        set(__pctk_prefix "${CMAKE_STAGING_PREFIX}")
    else()
        set(__pctk_prefix "${CMAKE_INSTALL_PREFIX}")
    endif()
    if(__pctk_prefix STREQUAL PCTK_BINARY_DIR)
        set(__pctk_will_install_value OFF)
    else()
        set(__pctk_will_install_value ON)
    endif()
    set(PCTK_WILL_INSTALL ${__pctk_will_install_value} CACHE BOOL
        "Boolean indicating if doing a PCTK prefix build (vs non-prefix build)." FORCE)
    unset(__pctk_prefix)
    unset(__pctk_will_install_value)
endif()

# Specify the PCTK_SOURCE_TREE only when building pctkbase. Needed by some tests when the tests are
# built as part of the project, and not standalone. For standalone tests, the value is set in
# PCTKBuildInternalsExtra.cmake.
if(PROJECT_NAME STREQUAL "PCTK")
    set(PCTK_SOURCE_TREE "${PCTK_SOURCE_DIR}" CACHE PATH
        "A path to the source tree of the previously configured PCTK project." FORCE)
endif()

if(FEATURE_developer_build)
    if(DEFINED PCTK_CMAKE_EXPORT_COMPILE_COMMANDS)
        set(CMAKE_EXPORT_COMPILE_COMMANDS ${PCTK_CMAKE_EXPORT_COMPILE_COMMANDS})
    else()
        set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
    endif()
    set(_pctk_build_tests_default ON)
    set(__build_benchmarks ON)

    # Tests are not built by default with qmake for iOS and friends, and thus the overall build
    # tends to fail. Disable them by default when targeting uikit.
    if(UIKIT OR ANDROID)
        set(_pctk_build_tests_default OFF)
    endif()

    # Disable benchmarks for single configuration generators which do not build
    # with release configuration.
    if(CMAKE_BUILD_TYPE AND CMAKE_BUILD_TYPE STREQUAL Debug)
        set(__build_benchmarks OFF)
    endif()
else()
    set(_pctk_build_tests_default OFF)
    set(__build_benchmarks OFF)
endif()

# Build Benchmarks
option(PCTK_BUILD_BENCHMARKS "Build PCTK Benchmarks" ${__build_benchmarks})
if(PCTK_BUILD_BENCHMARKS)
    set(_pctk_build_tests_default ON)
endif()

## Set up testing
option(PCTK_BUILD_TESTS "Build the testing tree." ${_pctk_build_tests_default})
unset(_pctk_build_tests_default)
option(PCTK_BUILD_TESTS_BY_DEFAULT "Should tests be built as part of the default 'all' target." ON)
if(PCTK_BUILD_STANDALONE_TESTS)
    # BuildInternals might have set it to OFF on initial configuration. So force it to ON when
    # building standalone tests.
    set(PCTK_BUILD_TESTS ON CACHE BOOL "Build the testing tree." FORCE)

    # Also force the tests to be built as part of the default build target.
    set(PCTK_BUILD_TESTS_BY_DEFAULT ON CACHE BOOL
        "Should tests be built as part of the default 'all' target." FORCE)
endif()
set(BUILD_TESTING ${PCTK_BUILD_TESTS} CACHE INTERNAL "")

# PCTK_BUILD_TOOLS_WHEN_CROSSCOMPILING -> PCTK_FORCE_BUILD_TOOLS
# pre-6.4 compatibility flag (remove sometime in the future)
if(CMAKE_CROSSCOMPILING AND PCTK_BUILD_TOOLS_WHEN_CROSSCOMPILING)
    message(WARNING "PCTK_BUILD_TOOLS_WHEN_CROSSCOMPILING is deprecated. "
        "Please use PCTK_FORCE_BUILD_TOOLS instead.")
    set(PCTK_FORCE_BUILD_TOOLS TRUE CACHE INTERNAL "" FORCE)
endif()

# When cross-building, we don't build tools by default. Sometimes this also covers PCTK apps as well.
# Like in pctktools/assistant/assistant.pro, load(pctk_app), which is guarded by a pctkNomakeTools() call.

set(_pctk_build_tools_by_default_default ON)
if(CMAKE_CROSSCOMPILING AND NOT PCTK_FORCE_BUILD_TOOLS)
    set(_pctk_build_tools_by_default_default OFF)
endif()
option(PCTK_BUILD_TOOLS_BY_DEFAULT "Should tools be built as part of the default 'all' target."
    "${_pctk_build_tools_by_default_default}")
unset(_pctk_build_tools_by_default_default)

include(CTest)
enable_testing()

option(PCTK_BUILD_EXAMPLES "Build PCTK examples" OFF)
option(PCTK_BUILD_EXAMPLES_BY_DEFAULT "Should examples be built as part of the default 'all' target." ON)

# FIXME: Support prefix builds as well PCTKBUG-96232
if(PCTK_WILL_INSTALL)
    set(_pctk_build_examples_as_external OFF)
else()
    set(_pctk_build_examples_as_external ON)
endif()
option(PCTK_BUILD_EXAMPLES_AS_EXTERNAL "Should examples be built as ExternalProjects."
    ${_pctk_build_examples_as_external})
unset(_pctk_build_examples_as_external)

option(PCTK_BUILD_MANUAL_TESTS "Build PCTK manual tests" OFF)

if(WASM)
    option(PCTK_BUILD_MINIMAL_STATIC_TESTS "Build minimal subset of tests for static PCTK builds" ON)
else()
    option(PCTK_BUILD_MINIMAL_STATIC_TESTS "Build minimal subset of tests for static PCTK builds" OFF)
endif()

## Path used to find host tools, either when cross-compiling or just when using the tools from
## a different host build.
set(PCTK_HOST_PATH "$ENV{PCTK_HOST_PATH}" CACHE PATH "Installed PCTK host directory path, used for cross compiling.")

## Android platform settings
if(ANDROID)
    include(PCTKPlatformAndroid)
endif()


include(CMakePackageConfigHelpers)
#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_configure_process_path name default docstring)
    # No value provided, set the default.
    if(NOT DEFINED "${name}")
        set("${name}" "${default}" CACHE STRING "${docstring}")
    else()
        get_filename_component(given_path_as_abs "${${name}}" ABSOLUTE BASE_DIR "${CMAKE_INSTALL_PREFIX}")
        file(RELATIVE_PATH rel_path "${CMAKE_INSTALL_PREFIX}" "${given_path_as_abs}")

        # If absolute path given, check that it's inside the prefix (error out if not).
        # TODO: Figure out if we need to support paths that are outside the prefix.
        #
        # If relative path given, it's relative to the install prefix (rather than the binary dir,
        # which is what qmake does for some reason).
        # In both cases, store the value as a relative path.
        if("${rel_path}" STREQUAL "")
            # file(RELATIVE_PATH) returns an empty string if the given absolute paths are equal
            set(rel_path ".")
        elseif(rel_path MATCHES "^\.\./")
            # INSTALL_SYSCONFDIR is allowed to be outside the prefix.
            if(NOT name STREQUAL "INSTALL_SYSCONFDIR")
                message(FATAL_ERROR "Path component '${name}' is outside computed install prefix: ${rel_path} ")
                return()
            endif()
            set("${name}" "${${name}}" CACHE STRING "${docstring}" FORCE)
        else()
            set("${name}" "${rel_path}" CACHE STRING "${docstring}" FORCE)
        endif()
    endif()
endfunction()

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

# Given CMAKE_CONFIG and ALL_CMAKE_CONFIGS, determines if a directory suffix needs to be appended
# to each destination, and sets the computed install target destination arguments in OUT_VAR.
# Defaults used for each of the destination types, and can be configured per destination type.
function(pctk_get_install_target_default_args)
    pctk_parse_all_arguments(arg "pctk_get_install_target_default_args"
        "" "OUT_VAR;CMAKE_CONFIG;RUNTIME;LIBRARY;ARCHIVE;INCLUDES;BUNDLE"
        "ALL_CMAKE_CONFIGS" ${ARGN})

    if(NOT arg_CMAKE_CONFIG)
        message(FATAL_ERROR "No value given for CMAKE_CONFIG.")
    endif()
    if(NOT arg_ALL_CMAKE_CONFIGS)
        message(FATAL_ERROR "No value given for ALL_CMAKE_CONFIGS.")
    endif()
    list(LENGTH arg_ALL_CMAKE_CONFIGS all_configs_count)
    list(GET arg_ALL_CMAKE_CONFIGS 0 first_config)

    set(suffix "")
    if(all_configs_count GREATER 1 AND NOT arg_CMAKE_CONFIG STREQUAL first_config)
        set(suffix "/${arg_CMAKE_CONFIG}")
    endif()

    set(runtime "${INSTALL_BINDIR}")
    if(arg_RUNTIME)
        set(runtime "${arg_RUNTIME}")
    endif()

    set(library "${INSTALL_LIBDIR}")
    if(arg_LIBRARY)
        set(library "${arg_LIBRARY}")
    endif()

    set(archive "${INSTALL_LIBDIR}")
    if(arg_ARCHIVE)
        set(archive "${arg_ARCHIVE}")
    endif()

    set(includes "${INSTALL_INCLUDEDIR}")
    if(arg_INCLUDES)
        set(includes "${arg_INCLUDES}")
    endif()

    set(bundle "${INSTALL_BINDIR}")
    if(arg_BUNDLE)
        set(bundle "${arg_BUNDLE}")
    endif()

    set(args
        RUNTIME DESTINATION "${runtime}${suffix}"
        LIBRARY DESTINATION "${library}${suffix}"
        ARCHIVE DESTINATION "${archive}${suffix}" COMPONENT Devel
        BUNDLE DESTINATION "${bundle}${suffix}"
        INCLUDES DESTINATION "${includes}${suffix}")
    set(${arg_OUT_VAR} "${args}" PARENT_SCOPE)
endfunction()

if(WIN32)
    set(_default_libexec "${INSTALL_ARCHDATADIR}/bin")
else()
    set(_default_libexec "${INSTALL_ARCHDATADIR}/libexec")
endif()

pctk_configure_process_path(
    INSTALL_LIBEXECDIR
    "${_default_libexec}"
    "Helper programs [ARCHDATADIR/bin on Windows, ARCHDATADIR/libexec otherwise]")
pctk_configure_process_path(INSTALL_QMLDIR "${INSTALL_ARCHDATADIR}/qml" "QML imports [ARCHDATADIR/qml]")
pctk_configure_process_path(INSTALL_DATADIR "." "Arch-independent data [PREFIX]")
pctk_configure_process_path(INSTALL_DOCDIR "${INSTALL_DATADIR}/doc" "Documentation [DATADIR/doc]")
pctk_configure_process_path(INSTALL_TRANSLATIONSDIR "${INSTALL_DATADIR}/translations"
    "Translations [DATADIR/translations]")
if(APPLE)
    set(PCTK_DEFAULT_SYS_CONF_DIR "/Library/Preferences/PCTK")
else()
    set(PCTK_DEFAULT_SYS_CONF_DIR "etc/xdg")
endif()
pctk_configure_process_path(INSTALL_SYSCONFDIR
    "${PCTK_DEFAULT_SYS_CONF_DIR}"
    "Settings used by PCTK programs [PREFIX/etc/xdg]/[/Library/Preferences/PCTK]")
pctk_configure_process_path(INSTALL_EXAMPLESDIR "examples" "Examples [PREFIX/examples]")
pctk_configure_process_path(INSTALL_TESTSDIR "tests" "Tests [PREFIX/tests]")
pctk_configure_process_path(INSTALL_DESCRIPTIONSDIR
    "${INSTALL_DATADIR}/modules"
    "Module description files directory")

if(NOT "${CMAKE_STAGING_PREFIX}" STREQUAL "")
    set(PCTK_STAGING_PREFIX "${CMAKE_STAGING_PREFIX}")
else()
    set(PCTK_STAGING_PREFIX "${CMAKE_INSTALL_PREFIX}")
endif()

if(PROJECT_NAME STREQUAL "PCTK")
    set(PCTK_COORD_TYPE double CACHE STRING "Type of qreal")
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
        # In this case, we always copy all the build products in pctkcore/{bin,lib,...}
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
            # When doing a non-prefix build, both the build dir and install dir are the same,
            # pointing to the pctkbase build dir.
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

set(PCTK_CMAKE_DIR "${CMAKE_CURRENT_LIST_DIR}")

# Find the path to mkspecs/, depending on whether we are building as part of a standard pctkbuild,
# or a module against an already installed version of pctk.
if(NOT PCTK_MKSPECS_DIR)
    if("${PCTK_BUILD_INTERNALS_PATH}" STREQUAL "")
        get_filename_component(PCTK_MKSPECS_DIR "${CMAKE_CURRENT_LIST_DIR}/../mkspecs" ABSOLUTE)
    else()
        # We can rely on PCTK_BUILD_INTERNALS_RELOCATABLE_INSTALL_PREFIX being set by
        # PCTKBuildInternalsExtra.cmake.
        get_filename_component(PCTK_MKSPECS_DIR
            "${PCTK_BUILD_INTERNALS_RELOCATABLE_INSTALL_PREFIX}/${INSTALL_MKSPECSDIR}" ABSOLUTE)
    endif()
    set(PCTK_MKSPECS_DIR "${PCTK_MKSPECS_DIR}" CACHE INTERNAL "")
endif()

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

# platform define path, etc.
if(WIN32)
    set(PCTK_DEFAULT_PLATFORM_DEFINITIONS WIN32 _ENABLE_EXTENDED_ALIGNED_STORAGE)
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        list(APPEND PCTK_DEFAULT_PLATFORM_DEFINITIONS WIN64 _WIN64)
    endif()
    if(MSVC)
        if(CLANG)
            set(PCTK_DEFAULT_MKSPEC win32-clang-msvc)
        elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "arm64")
            set(PCTK_DEFAULT_MKSPEC win32-arm64-msvc)
        else()
            set(PCTK_DEFAULT_MKSPEC win32-msvc)
        endif()
    elseif(CLANG AND MINGW)
        set(PCTK_DEFAULT_MKSPEC win32-clang-g++)
    elseif(MINGW)
        set(PCTK_DEFAULT_MKSPEC win32-g++)
    endif()

    if(MINGW)
        list(APPEND PCTK_DEFAULT_PLATFORM_DEFINITIONS MINGW_HAS_SECURE_API=1)
    endif()
elseif(LINUX)
    if(GCC)
        set(PCTK_DEFAULT_MKSPEC linux-g++)
    elseif(CLANG)
        set(PCTK_DEFAULT_MKSPEC linux-clang)
    endif()
elseif(ANDROID)
    if(GCC)
        set(PCTK_DEFAULT_MKSPEC android-g++)
    elseif(CLANG)
        set(PCTK_DEFAULT_MKSPEC android-clang)
    endif()
elseif(IOS)
    set(PCTK_DEFAULT_MKSPEC macx-ios-clang)
elseif(APPLE)
    set(PCTK_DEFAULT_MKSPEC macx-clang)
elseif(WASM)
    set(PCTK_DEFAULT_MKSPEC wasm-emscripten)
elseif(QNX)
    # Certain POSIX defines are not set if we don't compile with -std=gnuXX
    set(PCTK_ENABLE_CXX_EXTENSIONS ON)

    list(APPEND PCTK_DEFAULT_PLATFORM_DEFINITIONS _FORTIFY_SOURCE=2 _REENTRANT)

    set(compiler_aarch64le aarch64le)
    set(compiler_armle-v7 armv7le)
    set(compiler_x86-64 x86_64)
    set(compiler_x86 x86)
    foreach(arch aarch64le armle-v7 x86-64 x86)
        if(CMAKE_CXX_COMPILER_TARGET MATCHES "${compiler_${arch}}$")
            set(PCTK_DEFAULT_MKSPEC qnx-${arch}-qcc)
        endif()
    endforeach()
elseif(FREEBSD)
    if(CLANG)
        set(PCTK_DEFAULT_MKSPEC freebsd-clang)
    elseif(GCC)
        set(PCTK_DEFAULT_MKSPEC freebsd-g++)
    endif()
elseif(NETBSD)
    set(PCTK_DEFAULT_MKSPEC netbsd-g++)
elseif(OPENBSD)
    set(PCTK_DEFAULT_MKSPEC openbsd-g++)
elseif(SOLARIS)
    if(GCC)
        if(PCTK_64BIT)
            set(PCTK_DEFAULT_MKSPEC solaris-g++-64)
        else()
            set(PCTK_DEFAULT_MKSPEC solaris-g++)
        endif()
    else()
        if(PCTK_64BIT)
            set(PCTK_DEFAULT_MKSPEC solaris-cc-64)
        else()
            set(PCTK_DEFAULT_MKSPEC solaris-cc)
        endif()
    endif()
elseif(HURD)
    set(PCTK_DEFAULT_MKSPEC hurd-g++)
endif()

if(NOT DEFINED PCTK_DEFAULT_PLATFORM_DEFINITIONS)
    set(PCTK_DEFAULT_PLATFORM_DEFINITIONS "")
endif()

set(PCTK_PLATFORM_DEFINITIONS ${PCTK_DEFAULT_PLATFORM_DEFINITIONS}
    CACHE STRING "PCTK platform specific pre-processor defines")

set(PCTK_NAMESPACE "" CACHE STRING "PCTK Namespace")
# The variables might have already been set in PCTKBuildInternalsExtra.cmake if the file is included
# while building a new module and not PCTK. In that case, stop overriding the value.
if(NOT INSTALL_CMAKE_NAMESPACE)
    set(INSTALL_CMAKE_NAMESPACE "pctk${PROJECT_VERSION_MAJOR}"
        CACHE STRING "CMake namespace [pctk${PROJECT_VERSION_MAJOR}]")
endif()
if(NOT PCTK_CMAKE_EXPORT_NAMESPACE)
    set(PCTK_CMAKE_EXPORT_NAMESPACE "pctk${PROJECT_VERSION_MAJOR}"
        CACHE STRING "CMake namespace used when exporting targets [pctk${PROJECT_VERSION_MAJOR}]")
endif()


set(PCTK_KNOWN_MODULES_WITH_TOOLS "" CACHE INTERNAL "Known PCTK modules with tools" FORCE)

# For adjusting variables when running tests, we need to know what
# the correct variable is for separating entries in PATH-alike
# variables.
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    set(PCTK_PATH_SEPARATOR "\\;")
else()
    set(PCTK_PATH_SEPARATOR ":")
endif()

# This is used to hold extra cmake code that should be put into PCTKBuildInternalsExtra.cmake file
# at the PCTKPostProcess stage.
set(PCTK_BUILD_INTERNALS_EXTRA_CMAKE_CODE "")

# Save the value of the current first project source dir.
# This will be /path/to/pctkbase for pctkbase both in a super-build and a non super-build.
# This will be /path/to/pctkbase/tests when building standalone tests.
set(PCTK_TOP_LEVEL_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")

# Prevent warnings about object files without any symbols. This is a common
# thing in PCTK as we tend to build files unconditionally, and then use ifdefs
# to compile out parts that are not relevant.
if(CMAKE_HOST_APPLE AND APPLE)
    foreach(lang ASM C CXX)
        # We have to tell 'ar' to not run ranlib by itself, by passing the 'S' option
        set(CMAKE_${lang}_ARCHIVE_CREATE "<CMAKE_AR> qcS <TARGET> <LINK_FLAGS> <OBJECTS>")
        set(CMAKE_${lang}_ARCHIVE_APPEND "<CMAKE_AR> qS <TARGET> <LINK_FLAGS> <OBJECTS>")
        set(CMAKE_${lang}_ARCHIVE_FINISH "<CMAKE_RANLIB> -no_warning_for_no_symbols <TARGET>")
    endforeach()
endif()

# Functions and macros:

# Needed for pctk_internal_add_link_flags_no_undefined.
include(CheckCXXSourceCompiles)

set(__default_private_args
    SOURCES
    LIBRARIES
    INCLUDE_DIRECTORIES
    DEFINES
    FEATURE_DEPENDENCIES
    COMPILE_OPTIONS
    LINK_OPTIONS
    DISABLE_AUTOGEN_TOOLS
    ENABLE_AUTOGEN_TOOLS
    PLUGIN_TYPES)
set(__default_public_args
    PUBLIC_LIBRARIES
    PUBLIC_INCLUDE_DIRECTORIES
    PUBLIC_DEFINES
    PUBLIC_COMPILE_OPTIONS
    PUBLIC_LINK_OPTIONS)
set(__default_private_module_args
    PRIVATE_MODULE_INTERFACE)
set(__default_target_info_args
    TARGET_VERSION
    TARGET_PRODUCT
    TARGET_DESCRIPTION
    TARGET_COMPANY
    TARGET_COPYRIGHT)

# Collection of arguments so they can be shared across pctk_internal_add_executable
# and pctk_internal_add_test_helper.
set(__pctk_internal_add_executable_optional_args
    GUI
    NO_INSTALL
    EXCEPTIONS
    DELAY_RC
    DELAY_TARGET_INFO
    PCTK_APP)
set(__pctk_internal_add_executable_single_args
    CORE_LIBRARY
    OUTPUT_DIRECTORY
    INSTALL_DIRECTORY
    VERSION
    ${__default_target_info_args})
set(__pctk_internal_add_executable_multi_args
    ${__default_private_args}
    ${__default_public_args})

option(PCTK_CMAKE_DEBUG_EXTEND_TARGET "Debug extend_target calls in PCTK's build system" OFF)


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
include(PCTKSubdirectoryHelpers)
include(PCTKFrameworkHelpers)
include(PCTKInstallHelpers)
include(PCTKModuleHelpers)
#include(PCTKNoLinkTargetHelpers)
#include(PCTKPluginHelpers)
include(PCTKPrecompiledHelpers)
include(PCTKPkgConfigHelpers)
#include(PCTKResourceHelpers)
include(PCTKRpathHelpers)
include(PCTKModuleHelpers)
include(PCTKTargetHelpers)
include(PCTKTestHelpers)
#include(PCTKToolHelpers)
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
#include(PCTKPublicDependencyHelpers)
#include(PCTKPublicTestHelpers)
#include(PCTKPublicToolHelpers)

if(CMAKE_CROSSCOMPILING)
    if(NOT IS_DIRECTORY "${PCTK_HOST_PATH}")
        message(FATAL_ERROR "You need to set PCTK_HOST_PATH to cross compile PCTK.")
    endif()
endif()
