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


#-----------------------------------------------------------------------------------------------------------------------
# pctk_set01 finction
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_set01 result)
    if(${ARGN})
        set("${result}" 1 PARENT_SCOPE)
    else()
        set("${result}" 0 PARENT_SCOPE)
    endif()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# pctk set system variable
#-----------------------------------------------------------------------------------------------------------------------
message(STATUS "Build in system: ${CMAKE_SYSTEM_NAME}")
set(PCTK_SYSTEM_NAME ${CMAKE_SYSTEM_NAME})
set(PCTK_SYSTEM_VERSION ${CMAKE_SYSTEM_VERSION})
set(PCTK_SYSTEM_PROCESSOR ${CMAKE_SYSTEM_PROCESSOR})
pctk_set01(PCTK_SYSTEM_LINUX
    CMAKE_SYSTEM_NAME STREQUAL "Linux")
pctk_set01(PCTK_SYSTEM_WINCE
    CMAKE_SYSTEM_NAME STREQUAL "WindowsCE")
pctk_set01(PCTK_SYSTEM_WIN
    PCTK_SYSTEM_WINCE OR CMAKE_SYSTEM_NAME STREQUAL "Windows")
pctk_set01(PCTK_SYSTEM_HPUX
    CMAKE_SYSTEM_NAME STREQUAL "HPUX")
pctk_set01(PCTK_SYSTEM_ANDROID
    CMAKE_SYSTEM_NAME STREQUAL "Android")
pctk_set01(PCTK_SYSTEM_NACL
    CMAKE_SYSTEM_NAME STREQUAL "NaCl")
pctk_set01(PCTK_SYSTEM_INTEGRITY
    CMAKE_SYSTEM_NAME STREQUAL "Integrity")
pctk_set01(PCTK_SYSTEM_VXWORKS
    CMAKE_SYSTEM_NAME STREQUAL "VxWorks")
pctk_set01(PCTK_SYSTEM_QNX
    CMAKE_SYSTEM_NAME STREQUAL "QNX")
pctk_set01(PCTK_SYSTEM_OPENBSD
    CMAKE_SYSTEM_NAME STREQUAL "OpenBSD")
pctk_set01(PCTK_SYSTEM_FREEBSD
    CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
pctk_set01(PCTK_SYSTEM_NETBSD
    CMAKE_SYSTEM_NAME STREQUAL "NetBSD")
pctk_set01(PCTK_SYSTEM_WASM
    CMAKE_SYSTEM_NAME STREQUAL "Emscripten" OR EMSCRIPTEN)
pctk_set01(PCTK_SYSTEM_SOLARIS
    CMAKE_SYSTEM_NAME STREQUAL "SunOS")
pctk_set01(PCTK_SYSTEM_HURD
    CMAKE_SYSTEM_NAME STREQUAL "GNU")
# This is the only reliable way we can determine the webOS platform as the yocto recipe adds this compile definition
# into its generated toolchain.cmake file
pctk_set01(PCTK_SYSTEM_WEBOS
    CMAKE_CXX_FLAGS MATCHES "-D__WEBOS__")
pctk_set01(PCTK_SYSTEM_APPLE
    APPLE)
pctk_set01(PCTK_SYSTEM_BSD
    APPLE OR OPENBSD OR FREEBSD OR NETBSD)
pctk_set01(PCTK_SYSTEM_DARWIN
    APPLE OR CMAKE_SYSTEM_NAME STREQUAL "Darwin")
pctk_set01(PCTK_SYSTEM_IOS
    APPLE AND CMAKE_SYSTEM_NAME STREQUAL "iOS")
pctk_set01(PCTK_SYSTEM_TVOS
    APPLE AND CMAKE_SYSTEM_NAME STREQUAL "tvOS")
pctk_set01(PCTK_SYSTEM_WATCHOS
    APPLE AND CMAKE_SYSTEM_NAME STREQUAL "watchOS")
pctk_set01(PCTK_SYSTEM_UIKIT
    APPLE AND (IOS OR TVOS OR WATCHOS))
pctk_set01(PCTK_SYSTEM_MACOS
    APPLE AND NOT UIKIT)


#-----------------------------------------------------------------------------------------------------------------------
# pctk set processor variable
#-----------------------------------------------------------------------------------------------------------------------
message(STATUS "Build in processor: ${CMAKE_SYSTEM_PROCESSOR}")
set(PCTK_SYSTEM_PROCESSOR ${CMAKE_SYSTEM_PROCESSOR})
pctk_set01(PCTK_PROCESSOR_I386
    CMAKE_SYSTEM_PROCESSOR STREQUAL "i386")
pctk_set01(PCTK_PROCESSOR_I686
    CMAKE_CXX_COMPILER_ID MATCHES "i686")
pctk_set01(PCTK_PROCESSOR_X86_64
    CMAKE_CXX_COMPILER_ID MATCHES "x86_64")
pctk_set01(PCTK_PROCESSOR_AMD64
    CMAKE_CXX_COMPILER_ID STREQUAL "amd64")
pctk_set01(PCTK_PROCESSOR_ARM64
    CMAKE_CXX_COMPILER_ID STREQUAL "arm64")
pctk_set01(PCTK_PROCESSOR_ARM32
    CMAKE_CXX_COMPILER_ID STREQUAL "arm32")


#-----------------------------------------------------------------------------------------------------------------------
# pctk set cxx compiler variable
#-----------------------------------------------------------------------------------------------------------------------
message(STATUS "Build in cxx compiler: ${CMAKE_CXX_COMPILER_ID}")
set(PCTK_CXX_COMPILER_ID ${CMAKE_CXX_COMPILER_ID})
set(PCTK_CXX_COMPILER_VERSION ${CMAKE_CXX_COMPILER_VERSION})
pctk_set01(PCTK_CXX_COMPILER_GCC
    CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
pctk_set01(PCTK_CXX_COMPILER_MSVC
    MSVC OR CMAKE_CXX_COMPILER_ID STREQUAL "Msvc")
pctk_set01(PCTK_CXX_COMPILER_MINGW
    MINGW OR CMAKE_CXX_COMPILER_ID STREQUAL "Mingw")
pctk_set01(PCTK_CXX_COMPILER_CLANG
    CMAKE_CXX_COMPILER_ID MATCHES "Clang|IntelLLVM")
pctk_set01(PCTK_CXX_COMPILER_APPLE_CLANG
    CMAKE_CXX_COMPILER_ID MATCHES "AppleClang")
pctk_set01(PCTK_CXX_COMPILER_INTEL_LLVM
    CMAKE_CXX_COMPILER_ID STREQUAL "IntelLLVM")
pctk_set01(PCTK_CXX_COMPILER_QCC
    CMAKE_CXX_COMPILER_ID STREQUAL "QCC") # CMP0047


#-----------------------------------------------------------------------------------------------------------------------
# pctk arch size variable
#-----------------------------------------------------------------------------------------------------------------------
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(PCTK_ARCH_64BIT TRUE)
elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(PCTK_ARCH_32BIT TRUE)
endif()


#-----------------------------------------------------------------------------------------------------------------------
# pctk mkspecs version
#-----------------------------------------------------------------------------------------------------------------------
if(PCTK_SYSTEM_WIN32)
    set(PCTK_DEFAULT_PLATFORM_DEFINITIONS WIN32 _ENABLE_EXTENDED_ALIGNED_STORAGE)
    if(PCTK_ARCH_64BIT)
        list(APPEND PCTK_DEFAULT_PLATFORM_DEFINITIONS WIN64 _WIN64)
    endif()
    if(PCTK_CXX_COMPILER_MSVC)
        if(PCTK_CXX_COMPILER_CLANG)
            set(PCTK_DEFAULT_MKSPEC win32-clang-msvc)
        elseif(PCTK_PROCESSOR_ARM64)
            set(PCTK_DEFAULT_MKSPEC win32-arm64-msvc)
        else()
            set(PCTK_DEFAULT_MKSPEC win32-msvc)
        endif()
    elseif(PCTK_CXX_COMPILER_CLANG AND PCTK_CXX_COMPILER_MINGW)
        set(PCTK_DEFAULT_MKSPEC win32-clang-g++)
    elseif(PCTK_CXX_COMPILER_MINGW)
        set(PCTK_DEFAULT_MKSPEC win32-g++)
    endif()

    if(PCTK_CXX_COMPILER_MINGW)
        list(APPEND PCTK_DEFAULT_PLATFORM_DEFINITIONS MINGW_HAS_SECURE_API=1)
    endif()
elseif(PCTK_SYSTEM_LINUX)
    if(PCTK_CXX_COMPILER_GCC)
        set(PCTK_DEFAULT_MKSPEC linux-g++)
    elseif(PCTK_CXX_COMPILER_CLANG)
        set(PCTK_DEFAULT_MKSPEC linux-clang)
    endif()
elseif(PCTK_SYSTEM_ANDROID)
    if(PCTK_CXX_COMPILER_GCC)
        set(PCTK_DEFAULT_MKSPEC android-g++)
    elseif(PCTK_CXX_COMPILER_CLANG)
        set(PCTK_DEFAULT_MKSPEC android-clang)
    endif()
elseif(PCTK_SYSTEM_IOS)
    set(PCTK_DEFAULT_MKSPEC macx-ios-clang)
elseif(PCTK_SYSTEM_APPLE)
    set(PCTK_DEFAULT_MKSPEC macx-clang)
elseif(PCTK_SYSTEM_WASM)
    set(PCTK_DEFAULT_MKSPEC wasm-emscripten)
elseif(PCTK_SYSTEM_QNX)
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
elseif(PCTK_SYSTEM_FREEBSD)
    if(PCTK_CXX_COMPILER_CLANG)
        set(PCTK_DEFAULT_MKSPEC freebsd-clang)
    elseif(PCTK_CXX_COMPILER_GCC)
        set(PCTK_DEFAULT_MKSPEC freebsd-g++)
    endif()
elseif(PCTK_SYSTEM_NETBSD)
    set(PCTK_DEFAULT_MKSPEC netbsd-g++)
elseif(PCTK_SYSTEM_OPENBSD)
    set(PCTK_DEFAULT_MKSPEC openbsd-g++)
elseif(PCTK_SYSTEM_SOLARIS)
    if(PCTK_CXX_COMPILER_GCC)
        if(PCTK_ARCH_64BIT)
            set(PCTK_DEFAULT_MKSPEC solaris-g++-64)
        else()
            set(PCTK_DEFAULT_MKSPEC solaris-g++)
        endif()
    else()
        if(PCTK_ARCH_64BIT)
            set(PCTK_DEFAULT_MKSPEC solaris-cc-64)
        else()
            set(PCTK_DEFAULT_MKSPEC solaris-cc)
        endif()
    endif()
elseif(PCTK_SYSTEM_HURD)
    set(PCTK_DEFAULT_MKSPEC hurd-g++)
endif()

if(NOT PCTK_DEFAULT_MKSPEC)
    message(FATAL_ERROR "mkspec not Detected!")
else()
    message(STATUS "Build in mkspec: ${PCTK_DEFAULT_MKSPEC}")
endif()

if(NOT DEFINED PCTK_DEFAULT_PLATFORM_DEFINITIONS)
    set(PCTK_DEFAULT_PLATFORM_DEFINITIONS "")
endif()

set(PCTK_PLATFORM_DEFINITIONS ${PCTK_DEFAULT_PLATFORM_DEFINITIONS} CACHE STRING "PCTK platform specific pre-processor defines")


#-----------------------------------------------------------------------------------------------------------------------
# pctk parse version
#-----------------------------------------------------------------------------------------------------------------------
# Parses a version string like "xx.yy.zz" and sets the major, minor and patch variables.
function(pctk_parse_version_string version_string out_var_prefix)
    string(REPLACE "." ";" version_list ${version_string})
    list(LENGTH version_list length)

    set(out_var "${out_var_prefix}_MAJOR")
    set(value "")
    if(length GREATER 0)
        list(GET version_list 0 value)
        list(REMOVE_AT version_list 0)
        math(EXPR length "${length}-1")
    endif()
    set(${out_var} "${value}" PARENT_SCOPE)

    set(out_var "${out_var_prefix}_MINOR")
    set(value "")
    if(length GREATER 0)
        list(GET version_list 0 value)
        set(${out_var} "${value}" PARENT_SCOPE)
        list(REMOVE_AT version_list 0)
        math(EXPR length "${length}-1")
    endif()
    set(${out_var} "${value}" PARENT_SCOPE)

    set(out_var "${out_var_prefix}_PATCH")
    set(value "")
    if(length GREATER 0)
        list(GET version_list 0 value)
        set(${out_var} "${value}" PARENT_SCOPE)
        list(REMOVE_AT version_list 0)
        math(EXPR length "${length}-1")
    endif()
    set(${out_var} "${value}" PARENT_SCOPE)
endfunction()

# Set up the separate version components for the compiler version, to allow mapping of qmake
# conditions like 'equals(PCTK_GCC_MAJOR_VERSION,5)'.
if(CMAKE_CXX_COMPILER_VERSION)
    pctk_parse_version_string("${CMAKE_CXX_COMPILER_VERSION}" "PCTK_COMPILER_VERSION")
endif()
