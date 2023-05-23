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

#--------------------------------------------------------------------------------
# Set lib base name and out put path
#--------------------------------------------------------------------------------
set(PCTK_LIB_NAME Core)
set(LIBRARY_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR})


#--------------------------------------------------------------------------------
# append platform impl file
#--------------------------------------------------------------------------------
if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/source/platform/mkspecs/${PCTK_DEFAULT_MKSPEC}/pctkPlatformDefs.h)
    message(FATAL_ERROR "${CMAKE_CURRENT_SOURCE_DIR}/source/platform/mkspecs/${PCTK_DEFAULT_MKSPEC}/pctkPlatformDefs.h not exist!")
else()
    set(PCTK_CORE_PLATFORM_MKSPECS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/source/platform/mkspecs")
    configure_file(
        "source/platform/pctkPlatformDefs.h.in"
        "${CMAKE_CURRENT_BINARY_DIR}/include/pctkPlatformDefs.h")
    set(PCTK_CORE_PLATFORM_MKSPECS_COPYED_DIR ${CMAKE_CURRENT_BINARY_DIR}/include/platform)
    if(NOT EXISTS ${PCTK_CORE_PLATFORM_MKSPECS_COPYED_DIR})
        execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${PCTK_CORE_PLATFORM_MKSPECS_DIR} ${PCTK_CORE_PLATFORM_MKSPECS_COPYED_DIR})
    endif()
endif()


#-----------------------------------------------------------------------------------------------------------------------
# Add library
#-----------------------------------------------------------------------------------------------------------------------
pctk_add_library(${PCTK_LIB_NAME}
    EXCEPTIONS
    PUBLIC_HEADERS
    source/global/pctkCompiler.h
    source/global/pctkGlobal.h
    source/global/pctkLimits.h
    source/global/pctkMacros.h
    source/global/pctkPreprocessor.h
    source/global/pctkProcessor.h
    source/global/pctkSystem.h
    source/thread/pctkAtomic.h
    source/kernel/pctkObject.h
    HEADERS
    source/thread/pctkAtomic_p.h
    source/kernel/pctkObject_p.h
    SOURCES
    source/thread/pctkAtomic.cpp
    source/kernel/pctkObject.cpp
    PRECOMPILED_HEADER
    "source/pctkCorePch.h")


#-----------------------------------------------------------------------------------------------------------------------
# Add examples and tests
#-----------------------------------------------------------------------------------------------------------------------
if(PCTK_BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

if(PCTK_BUILD_TESTS)
    add_subdirectory(tests)
endif()