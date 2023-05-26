#set(__GlobalConfig_path_suffix "${INSTALL_CMAKE_NAMESPACE}")
#pctk_path_join(__GlobalConfig_build_dir ${PCTK_CONFIG_BUILD_DIR} ${__GlobalConfig_path_suffix})
#pctk_path_join(__GlobalConfig_install_dir ${PCTK_CONFIG_INSTALL_DIR} ${__GlobalConfig_path_suffix})
#set(__GlobalConfig_install_dir_absolute "${__GlobalConfig_install_dir}")
set(__pctk_bin_dir_absolute "${PCTK_INSTALL_DIR}/${INSTALL_BINDIR}")
set(__pctk_libexec_dir_absolute "${PCTK_INSTALL_DIR}/${INSTALL_LIBEXECDIR}")
if(PCTK_WILL_INSTALL)
    # Need to prepend the install prefix when doing prefix builds, because the config install dir
    # is relative then.
#    pctk_path_join(__GlobalConfig_install_dir_absolute
#        ${PCTK_BUILD_INTERNALS_RELOCATABLE_INSTALL_PREFIX}
#        ${__GlobalConfig_install_dir_absolute})
    pctk_path_join(__pctk_bin_dir_absolute
        ${PCTK_BUILD_INTERNALS_RELOCATABLE_INSTALL_PREFIX} ${__pctk_bin_dir_absolute})
    pctk_path_join(__pctk_libexec_dir_absolute
        ${PCTK_BUILD_INTERNALS_RELOCATABLE_INSTALL_PREFIX} ${__pctk_libexec_dir_absolute})
endif()
# Compute relative path from $pctk_prefix/bin dir to global CMake config install dir, to use in the
# unix-y pctk-cmake shell script, to make it work even if the installed PCTK is relocated.
#file(RELATIVE_PATH
#    __GlobalConfig_relative_path_from_bin_dir_to_cmake_config_dir
#    ${__pctk_bin_dir_absolute} ${__GlobalConfig_install_dir_absolute})

# Configure and install the PCTKBuildInternals package.
#set(__build_internals_path_suffix "${INSTALL_CMAKE_NAMESPACE}BuildInternals")
#pctk_path_join(__build_internals_build_dir ${PCTK_CONFIG_BUILD_DIR} ${__build_internals_path_suffix})
#pctk_path_join(__build_internals_install_dir ${PCTK_CONFIG_INSTALL_DIR}
#    ${__build_internals_path_suffix})
#set(__build_internals_standalone_test_template_dir "PCTKStandaloneTestTemplateProject")
#
#configure_file(
#    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/PCTKBuildInternals/PCTKBuildInternalsConfig.cmake"
#    "${__build_internals_build_dir}/${INSTALL_CMAKE_NAMESPACE}BuildInternalsConfig.cmake"
#    @ONLY
#)
#
#write_basic_package_version_file(
#    "${__build_internals_build_dir}/${INSTALL_CMAKE_NAMESPACE}BuildInternalsConfigVersionImpl.cmake"
#    VERSION ${PROJECT_VERSION}
#    COMPATIBILITY AnyNewerVersion
#)
#pctk_internal_write_pctk_package_version_file(
#    "${INSTALL_CMAKE_NAMESPACE}BuildInternals"
#    "${__build_internals_build_dir}/${INSTALL_CMAKE_NAMESPACE}BuildInternalsConfigVersion.cmake"
#)
#
#pctk_install(FILES
#    "${__build_internals_build_dir}/${INSTALL_CMAKE_NAMESPACE}BuildInternalsConfig.cmake"
#    "${__build_internals_build_dir}/${INSTALL_CMAKE_NAMESPACE}BuildInternalsConfigVersion.cmake"
#    "${__build_internals_build_dir}/${INSTALL_CMAKE_NAMESPACE}BuildInternalsConfigVersionImpl.cmake"
#    "${__build_internals_build_dir}/PCTKBuildInternalsExtra.cmake"
#    DESTINATION "${__build_internals_install_dir}"
#    COMPONENT Devel
#    )
#pctk_copy_or_install(
#    DIRECTORY
#    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/PCTKBuildInternals/${__build_internals_standalone_test_template_dir}"
#    DESTINATION "${__build_internals_install_dir}")
#
#set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
#    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/PCTKBuildInternals/${__build_internals_standalone_test_template_dir}/CMakeLists.txt")

include(PCTKToolchainHelpers)
pctk_internal_create_toolchain_file()

include(PCTKWrapperScriptHelpers)
pctk_internal_create_wrapper_scripts()

## Library to hold global features:
## These features are stored and accessed via PCTK::GlobalConfig, but the
## files always lived in PCTK::Core, so we keep it that way
#add_library(GlobalConfig INTERFACE)
#target_include_directories(GlobalConfig INTERFACE
#    $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>
#    $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include/PCTKCore>
#    $<INSTALL_INTERFACE:${INSTALL_INCLUDEDIR}>
#    $<INSTALL_INTERFACE:${INSTALL_INCLUDEDIR}/PCTKCore>
#    )
#pctk_feature_module_begin(NO_MODULE
#    PUBLIC_FILE src/corelib/global/qconfig.h
#    PRIVATE_FILE src/corelib/global/qconfig_p.h
#    )
#include("${CMAKE_CURRENT_SOURCE_DIR}/configure.cmake")

# Do what mkspecs/features/uikit/default_pre.prf does, aka enable sse2 for
# simulator_and_device_builds.
#
#pctk_internal_get_first_osx_arch(__pctk_osx_first_arch)
#set(__pctk_apple_silicon_arches "arm64;arm64e")
#if((UIKIT AND NOT PCTK_UIKIT_SDK) OR (MACOS AND PCTK_IS_MACOS_UNIVERSAL AND __pctk_osx_first_arch IN_LIST __pctk_apple_silicon_arches))
#    set(PCTK_FORCE_FEATURE_SSE2 ON CACHE INTERNAL "Force enable sse2 due to platform requirements.")
#    set(__pctk_configure_custom_enabled_cache_variables
#        TEST_subarch_sse2
#        FEATURE_sse2
#        PCTK_FEATURE_sse2)
#endif()
#
#if(MACOS AND PCTK_IS_MACOS_UNIVERSAL AND __pctk_osx_first_arch STREQUAL "x86_64")
#    set(PCTK_FORCE_FEATURE_neon ON CACHE INTERNAL "Force enable neon due to platform requirements.")
#    set(__pctk_configure_custom_enabled_cache_variables
#        TEST_subarch_neon
#        FEATURE_neon
#        PCTK_FEATURE_neon)
#endif()

#pctk_feature_module_end(GlobalConfig OUT_VAR_PREFIX "__GlobalConfig_")

# The version script support check has to happen after we determined which linker is going
# to be used. The linker decision happens in the pctkbase/configure.cmake file that is processed
# above.
pctk_run_linker_version_script_support()


include(PCTKPlatformTargetHelpers)
pctk_internal_setup_public_platform_target()

# defines PlatformCommonInternal PlatformModuleInternal PlatformPluginInternal PlatformToolInternal
include(PCTKInternalTargets)
pctk_internal_run_common_config_tests()

# Setup sanitizer options for pctkbase directory scope based on features computed above.
pctk_internal_set_up_sanitizer_options()
include("${CMAKE_CURRENT_LIST_DIR}/3rdparty/extra-cmake-modules/modules/ECMEnableSanitizers.cmake")

set(__export_targets Platform
    GlobalConfig
    GlobalConfigPrivate
    PlatformCommonInternal
    PlatformModuleInternal
    PlatformPluginInternal
    PlatformAppInternal
    PlatformToolInternal)
set(__export_name "${INSTALL_CMAKE_NAMESPACE}Targets")
pctk_install(TARGETS ${__export_targets} EXPORT "${__export_name}")
pctk_install(EXPORT ${__export_name}
    NAMESPACE ${PCTK_CMAKE_EXPORT_NAMESPACE}::
    DESTINATION "${__GlobalConfig_install_dir}")

pctk_internal_export_modern_cmake_config_targets_file(TARGETS ${__export_targets}
    EXPORT_NAME_PREFIX ${INSTALL_CMAKE_NAMESPACE}
    CONFIG_INSTALL_DIR
    ${__GlobalConfig_install_dir})

# Save minimum required CMake version to use PCTK.
#pctk_internal_get_supported_min_cmake_version_for_using_pctk(supported_min_version_for_using_pctk)
#pctk_internal_get_computed_min_cmake_version_for_using_pctk(computed_min_version_for_using_pctk)

# Get the lower and upper policy range to embed into the PCTK6 config file.
pctk_internal_get_min_new_policy_cmake_version(min_new_policy_version)
pctk_internal_get_max_new_policy_cmake_version(max_new_policy_version)


include(PCTKPlatformTargetHelpers)
pctk_internal_setup_public_platform_target()