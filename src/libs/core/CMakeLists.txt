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
# Add link library
#-----------------------------------------------------------------------------------------------------------------------
if(UNIX)
    list(APPEND PCTK_LIB_LINK_LIBRARIES ${CMAKE_DL_LIBS})
endif()

if(APPLE)
    list(APPEND PCTK_LIB_LINK_LIBRARIES "-framework Cocoa" "iconv")
endif()

if(WIN32)
    # shlwapi.lib           ->  shell,string
    # ws2_32.lib            ->  network
    # Synchronization.lib   ->  sync
    if(${CMAKE_SYSTEM_VERSION} EQUAL 6.1) # Windows 7
    elseif(${CMAKE_SYSTEM_VERSION} GREATER_EQUAL 6.2) # Windows 8
        list(APPEND PCTK_LIB_LINK_LIBRARIES Synchronization.lib)
    endif()
    list(APPEND PCTK_LIB_LINK_LIBRARIES shlwapi.lib ws2_32.lib)
endif()

if(CMAKE_THREAD_LIBS_INIT)
    list(APPEND PCTK_LIB_LINK_LIBRARIES ${CMAKE_THREAD_LIBS_INIT})
endif()


#-----------------------------------------------------------------------------------------------------------------------
# Add library
#-----------------------------------------------------------------------------------------------------------------------
pctk_add_library(${PCTK_LIB_NAME}
    EXCEPTIONS
    SOURCES
    source/global/pctkCompiler.h
    source/global/pctkGlobal.h
    source/global/pctkLimits.h
    source/global/pctkMacros.h
    source/global/pctkPreprocessor.h
    source/global/pctkProcessor.h
    source/global/pctkSystem.h
    source/io/pctkFileSystem.h
    source/io/pctkFileSystem.cpp
    source/kernel/pctkObject.cpp
    source/kernel/pctkObject.h
    source/kernel/pctkObject_p.h
    source/plugin/pctkSharedLibrary.cpp
    source/plugin/pctkSharedLibrary.h
    source/plugin/pctkSharedLibrary_p.h
    source/thread/pctkAtomicInt.h
    source/tools/pctkError.cpp
    source/tools/pctkError.h
    PRECOMPILED_HEADER
    "source/pctkCorePch.h"
    LIBRARIES
    ${PCTK_LIB_LINK_LIBRARIES})

pctk_internal_extend_target(${PCTK_LIB_NAME} CONDITION PCTK_FEATURE_STDCXX_ATOMIC
    SOURCES source/thread/pctkAtomicInt_cxx11.cpp)
pctk_internal_extend_target(${PCTK_LIB_NAME} CONDITION PCTK_FEATURE_STDC_ATOMIC
    SOURCES source/thread/pctkAtomicInt_c11.cpp)
pctk_internal_extend_target(${PCTK_LIB_NAME} CONDITION PCTK_CXX_COMPILER_GCC
    SOURCES source/thread/pctkAtomicInt_gcc.cpp)
pctk_internal_extend_target(${PCTK_LIB_NAME} CONDITION PCTK_CXX_COMPILER_MSVC
    SOURCES source/thread/pctkAtomicInt_msvc.cpp)
pctk_internal_extend_target(${PCTK_LIB_NAME}
    CONDITION UNIX AND (NOT PCTK_FEATURE_STDCXX_ATOMIC) AND (NOT PCTK_FEATURE_STDC_ATOMIC) AND (NOT PCTK_CXX_COMPILER_GCC)
    SOURCES source/thread/pctkAtomicInt_unix.cpp)


#-----------------------------------------------------------------------------------------------------------------------
# Add examples and tests
#-----------------------------------------------------------------------------------------------------------------------
if(PCTK_BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

if(PCTK_BUILD_TESTS)
    add_subdirectory(tests)
endif()