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

#cmake_policy(SET CMP0075 NEW) # use CMAKE_REQUIRED_LIBRARIES


#-----------------------------------------------------------------------------------------------------------------------
# Set project name and version
#-----------------------------------------------------------------------------------------------------------------------
project(PCTK VERSION 0.4.18.2 LANGUAGES CXX C ASM)
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
set(PCTK_BRIEF "Cpp portable commmon toolkit (PCTK)")
set(PCTK_LICENSE "MIT License")
set(PCTK_PROJECT_NAME ${PROJECT_NAME})
math(EXPR PCTK_VERSION_CALC "${PCTK_VERSION_MAJOR}*1000 + ${PCTK_VERSION_MINOR}*100 + ${PCTK_VERSION_PATCH}")
message(STATUS "Project version: ${PCTK_VERSION}")
message(STATUS "Project copyright: ${PCTK_COPYRIGHT}")
message(STATUS "Project brief: ${PCTK_BRIEF}")
message(STATUS "Project license: ${PCTK_LICENSE}")


#-----------------------------------------------------------------------------------------------------------------------
# Set the rpath for executables
#-----------------------------------------------------------------------------------------------------------------------
set(CMAKE_SKIP_BUILD_RPATH OFF)            # use, i.e. don't skip the full RPATH for the build tree
set(CMAKE_BUILD_WITH_INSTALL_RPATH OFF)    # when building, don't use the install RPATH already (but later on when installing)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH OFF) # NO automatic rpath for INSTALL


if(CMAKE_BUILD_TYPE AND CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(PCTK_DEBUG ON)
else()
    set(PCTK_DEBUG OFF)
endif()
message(STATUS "Build mode: ${CMAKE_BUILD_TYPE}")


#-----------------------------------------------------------------------------------------------------------------------
# Add CMake function(s) and macro(s)
#-----------------------------------------------------------------------------------------------------------------------
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})
include(PCTKSetup)


#-----------------------------------------------------------------------------------------------------------------------
# Set build options
#-----------------------------------------------------------------------------------------------------------------------
pctk_option(PCTK_BUILD_ALL "Enable this to build all artifacts" OFF)
pctk_option(PCTK_BUILD_SHARED_LIBS "Enable this to build as dynamically" ON
    SET BUILD_SHARED_LIBS)
pctk_option(PCTK_BUILD_USE_PCH "Enable this to build use precompiled header files for compilation" ON
    DEPENDS PCTK_BUILD_SHARED_LIBS)
pctk_option(PCTK_BUILD_COMPILER_WARNING "Enable this to build target with compiler warnings" OFF)
pctk_option(PCTK_BUILD_EXAMPLES "Enable this to build examples" ON)
pctk_option(PCTK_BUILD_TESTS "Enable this to build tests" ON)
pctk_option(PCTK_BUILD_BENCHMARKS "Enable this to build the benchmarks" OFF)
pctk_option(PCTK_BUILD_DOCUMENTATION "Enable this to build the documentation" ON)
pctk_option(PCTK_BUILD_INSTALL "Enable this to build the installer" ON)

if(PCTK_BUILD_TESTS OR PCTK_BUILD_ALL)
    enable_testing()
endif()


#-----------------------------------------------------------------------------------------------------------------------
# Check and add submodules
#-----------------------------------------------------------------------------------------------------------------------
pctk_internal_find_modules(PCTK_BUILD_SUBMODULES)
pctk_internal_sort_module_dependencies("${PCTK_BUILD_SUBMODULES}" PCTK_BUILD_SUBMODULES)

foreach(module IN LISTS PCTK_BUILD_SUBMODULES)
    # Check for unmet dependencies
    if(NOT DEFINED BUILD_${module} OR BUILD_${module})
        message(NOTICE "Checking dependencies of submodule '${module}'")
        get_property(required_deps GLOBAL PROPERTY PCTK_REQUIRED_DEPS_FOR_${module})
        get_property(dependencies GLOBAL PROPERTY PCTK_DEPS_FOR_${module})
        foreach(dep IN LISTS dependencies)
            if(dep STREQUAL "pctk_core")
                # Always available skip
                continue()
            endif()

            set(required FALSE)
            if(dep IN_LIST required_deps)
                set(required TRUE)
            endif()

            set(error_reason "")
            if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${dep}/CMakeLists.txt")
                set(error_reason "${dep}'s CMakeLists.txt couldn't be found")
            elseif(DEFINED BUILD_${dep} AND NOT BUILD_${dep})
                set(error_reason "building '${dep}' was explicitly disabled")
            endif()

            if(NOT error_reason STREQUAL "")
                if(required)
                    message(FATAL_ERROR "Module '${module}' depends on '${dep}', but ${error_reason}.\n"
                        "Note: Use '-skip ${module}' to exclude it from the build.")
                else()
                    message(NOTICE "Skipping optional dependency '${dep}' of '${module}', because ${error_reason}.")
                endif()
            endif()
        endforeach()
    endif()
endforeach()

foreach(module IN LISTS PCTK_BUILD_SUBMODULES)
    message(NOTICE "Configuring submodule '${module}'")
    pctk_optional_add_subdirectory("${module}")

    if(module STREQUAL "pctk_core")
        if(NOT PCTK_BUILD_STANDALONE_TESTS)
            list(APPEND CMAKE_PREFIX_PATH "${PCTK_BINARY_DIR}/${INSTALL_LIBDIR}/cmake")
            list(APPEND CMAKE_FIND_ROOT_PATH "${PCTK_BINARY_DIR}")
        endif()
    endif()
endforeach()


#-----------------------------------------------------------------------------------------------------------------------
# build directory check
#-----------------------------------------------------------------------------------------------------------------------
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    message(FATAL_ERROR "In-source builds not allowed. Please make a new directory (called a build directory) and run "
        "CMake from there. You may need to remove CMakeCache.txt.")
endif()