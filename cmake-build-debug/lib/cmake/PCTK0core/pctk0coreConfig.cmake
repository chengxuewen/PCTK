
####### Expanded from @PACKAGE_INIT@ by configure_package_config_file() #######
####### Any changes to this file will be overwritten by the next CMake run ####
####### The input file was PCTKModuleConfig.cmake.in                            ########

get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)

macro(set_and_check _var _file)
  set(${_var} "${_file}")
  if(NOT EXISTS "${_file}")
    message(FATAL_ERROR "File or directory ${_file} referenced by variable ${_var} does not exist !")
  endif()
endmacro()

macro(check_required_components _NAME)
  foreach(comp ${${_NAME}_FIND_COMPONENTS})
    if(NOT ${_NAME}_${comp}_FOUND)
      if(${_NAME}_FIND_REQUIRED_${comp})
        set(${_NAME}_FOUND FALSE)
      endif()
    endif()
  endforeach()
endmacro()

####################################################################################

cmake_minimum_required(VERSION 3.16...3.17)

include(CMakeFindDependencyMacro)

get_filename_component(_import_prefix "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(_import_prefix "${_import_prefix}" REALPATH)

# Extra cmake code begin

# Extra cmake code end

# Find required dependencies, if any.
if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/pctk0coreDependencies.cmake")
    include("${CMAKE_CURRENT_LIST_DIR}/pctk0coreDependencies.cmake")
    _pctk_internal_suggest_dependency_debugging(core
        __pctk_core_pkg ${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE)
endif()

# If *ConfigDependencies.cmake exists, the variable value will be defined there.
# Don't override it in that case.
if(NOT DEFINED "pctk0core_FOUND")
    set("pctk0core_FOUND" TRUE)
endif()

if (NOT PCTK_NO_CREATE_TARGETS AND pctk0core_FOUND)
    include("${CMAKE_CURRENT_LIST_DIR}/pctk0coreTargets.cmake")
    include("${CMAKE_CURRENT_LIST_DIR}/pctk0coreAdditionalTargetInfo.cmake")
    if(NOT PCTK_NO_CREATE_VERSIONLESS_TARGETS)
        include("${CMAKE_CURRENT_LIST_DIR}/pctk0coreVersionlessTargets.cmake")
    endif()

    # DEPRECATED
    # Provide old style variables for includes, compile definitions, etc.
    # These variables are deprecated and only provided on a best-effort basis to facilitate porting.
    # Consider using target_link_libraries(app PRIVATE pctk0core) instead.
    set(pctk0core_LIBRARIES "pctk0::core")

    get_target_property(_pctk0core_OWN_INCLUDE_DIRS
                        pctk0::core INTERFACE_INCLUDE_DIRECTORIES)
    if(NOT _pctk0core_OWN_INCLUDE_DIRS)
        set(_pctk0core_OWN_INCLUDE_DIRS "")
    endif()

    if(TARGET pctk0::corePrivate)
        get_target_property(_pctk0core_OWN_PRIVATE_INCLUDE_DIRS
                            pctk0::corePrivate INTERFACE_INCLUDE_DIRECTORIES)
        if(NOT _pctk0core_OWN_PRIVATE_INCLUDE_DIRS)
            set(_pctk0core_OWN_PRIVATE_INCLUDE_DIRS "")
        endif()
    endif()

    get_target_property(pctk0core_DEFINITIONS
                        pctk0::core INTERFACE_COMPILE_DEFINITIONS)
    if(NOT pctk0core_DEFINITIONS)
        set(pctk0core_DEFINITIONS "")
    else()
        list(TRANSFORM pctk0core_DEFINITIONS PREPEND "-D")
    endif()

    get_target_property(pctk0core_COMPILE_DEFINITIONS
                        pctk0::core INTERFACE_COMPILE_DEFINITIONS)
    if(NOT pctk0core_COMPILE_DEFINITIONS)
        set(pctk0core_COMPILE_DEFINITIONS "")
    endif()

    set(pctk0core_INCLUDE_DIRS
        ${_pctk0core_OWN_INCLUDE_DIRS})

    set(pctk0core_PRIVATE_INCLUDE_DIRS
        ${_pctk0core_OWN_PRIVATE_INCLUDE_DIRS})

    foreach(_module_dep ${_pctk0core_MODULE_DEPENDENCIES})
        list(APPEND pctk0core_INCLUDE_DIRS
             ${pctk0${_module_dep}_INCLUDE_DIRS})
        list(APPEND pctk0core_PRIVATE_INCLUDE_DIRS
             ${pctk0${_module_dep}_PRIVATE_INCLUDE_DIRS})
        list(APPEND pctk0core_DEFINITIONS
             ${pctk0${_module_dep}_DEFINITIONS})
        list(APPEND pctk0core_COMPILE_DEFINITIONS
             ${pctk0${_module_dep}_COMPILE_DEFINITIONS})
    endforeach()

    list(REMOVE_DUPLICATES pctk0core_INCLUDE_DIRS)
    list(REMOVE_DUPLICATES pctk0core_PRIVATE_INCLUDE_DIRS)
    list(REMOVE_DUPLICATES pctk0core_DEFINITIONS)
    list(REMOVE_DUPLICATES pctk0core_COMPILE_DEFINITIONS)
endif()

if (TARGET pctk0::core)
    foreach(extra_cmake_include )
        include("${CMAKE_CURRENT_LIST_DIR}/${extra_cmake_include}")
    endforeach()

    pctk_make_features_available(pctk0::core)

    if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/pctk0corePlugins.cmake")
        include("${CMAKE_CURRENT_LIST_DIR}/pctk0corePlugins.cmake")
    endif()

    list(APPEND PCTK_ALL_MODULES_FOUND_VIA_FIND_PACKAGE "core")

    get_target_property(_pctk_module_target_type "pctk0::core" TYPE)
    if(NOT _pctk_module_target_type STREQUAL "INTERFACE_LIBRARY")
        get_target_property(_pctk_module_plugin_types
                            pctk0::core MODULE_PLUGIN_TYPES)
        if(_pctk_module_plugin_types)
            list(APPEND PCTK_ALL_PLUGIN_TYPES_FOUND_VIA_FIND_PACKAGE "${_pctk_module_plugin_types}")
        endif()
    endif()


    # Load Module's BuildInternals should any exist
    if (pctk0BuildInternals_DIR AND
        EXISTS "${CMAKE_CURRENT_LIST_DIR}/pctk0coreBuildInternals.cmake")
        include("${CMAKE_CURRENT_LIST_DIR}/pctk0coreBuildInternals.cmake")
    endif()
else()

    set(pctk0core_FOUND FALSE)
    if(NOT DEFINED pctk0core_NOT_FOUND_MESSAGE)
        set(pctk0core_NOT_FOUND_MESSAGE
            "Target \"pctk0::core\" was not found.")

        if(PCTK_NO_CREATE_TARGETS)
            string(APPEND pctk0core_NOT_FOUND_MESSAGE
                "Possibly due to PCTK_NO_CREATE_TARGETS being set to TRUE and thus "
                "${CMAKE_CURRENT_LIST_DIR}/pctk0coreTargets.cmake was not "
                "included to define the target.")
        endif()
    endif()
endif()
