########################################################################################################################
#
# Library: PCTK
#
# Copyright (C) 2023 ChengXueWen. Contact: 1398831004@qq.com
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

cmake_minimum_required(VERSION 3.16)


# Get the repo version and CMake policy details
include(.cmake.conf)


# This call will load any provided cmake toolchain file.
project(pctk_core
    VERSION "${PCTK_REPO_MODULE_VERSION}"
    DESCRIPTION "PCTK Core Libraries"
    LANGUAGES CXX C ASM)


# Should this Qt be static or dynamically linked?
option(BUILD_SHARED_LIBS "Build PCTK statically or dynamically" ON)
set(PCTK_BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS})


## Add some paths to check for cmake modules:
list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
if(MACOS)
    # Add module directory to pick up custom Info.plist template
    list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/macos")
elseif(IOS)
    # Add module directory to pick up custom Info.plist template
    list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/ios")
endif()


# Bail out if any part of the build directory's path is symlinked.
include(PCTKPathHasSymlinksCheck)
pctk_internal_check_if_path_has_symlinks("${CMAKE_BINARY_DIR}")

include(PCTKPlatformTargets)
include(PCTKInternalTargets)

#-----------------------------------------------------------------------------------------------------------------------
# Set build configs
#-----------------------------------------------------------------------------------------------------------------------
#add_library(pctk_config INTERFACE)
#pctk_configure_module_begin(NO_MODULE
#        PUBLIC_FILE include/pctk_core/pctk_config.h
#        PRIVATE_FILE include/pctk_core/private/pctk_config_p.h)
#target_include_directories(pctk_config INTERFACE
#        $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>
#        $<INSTALL_INTERFACE:${INSTALL_INCLUDEDIR}>)
#pctk_configure_reset(${PCTK_CMAKE_CXX_FLAGS_CHANGED})
#include(${PROJECT_SOURCE_DIR}/cmake/PCTKConfigure.cmake)
#pctk_configure_module_end(pctk_config)
#
#
pctk_internal_add_module(core
    EXCEPTIONS
    SOURCES
    source/object.h
    source/object.cpp
    INCLUDE_DIRECTORIES
    "${CMAKE_CURRENT_BINARY_DIR}/global" # special case
    PRECOMPILED_HEADER
    "source/core_pch.h")


if(PCTK_BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

if(PCTK_BUILD_TESTS)
    add_subdirectory(tests)
endif()