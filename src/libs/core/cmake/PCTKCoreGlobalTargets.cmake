
## Library to hold global features:
## These features are stored and accessed via PCTK::GlobalConfig, but the
## files always lived in PCTK::Core, so we keep it that way
#add_library(GlobalConfig INTERFACE)
#target_include_directories(GlobalConfig INTERFACE
#    $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>
#    $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include/PCTKCore>
#    $<INSTALL_INTERFACE:${INSTALL_INCLUDEDIR}>
#    $<INSTALL_INTERFACE:${INSTALL_INCLUDEDIR}/PCTKCore>)
#pctk_configure_module_begin(NO_MODULE
#    PUBLIC_FILE PCTKCore/global/config.h
#    PRIVATE_FILE PCTKCore/global/config_p.h)
#include("${CMAKE_CURRENT_SOURCE_DIR}/configure.cmake")


#add_library(PCTK::GlobalConfig ALIAS GlobalConfig)
#
#add_library(GlobalConfigPrivate INTERFACE)
#target_link_libraries(GlobalConfigPrivate INTERFACE GlobalConfig)
#target_include_directories(GlobalConfigPrivate INTERFACE
#    $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include/PCTKCore/${PROJECT_VERSION}>
#    $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include/PCTKCore/${PROJECT_VERSION}/PCTKCore>
#    $<INSTALL_INTERFACE:${INSTALL_INCLUDEDIR}/PCTKCore/${PROJECT_VERSION}>
#    $<INSTALL_INTERFACE:${INSTALL_INCLUDEDIR}/PCTKCore/${PROJECT_VERSION}/PCTKCore>
#    )
#add_library(PCTK::GlobalConfigPrivate ALIAS GlobalConfigPrivate)

include(PCTKPlatformTargetHelpers)
pctk_internal_setup_public_platform_target()