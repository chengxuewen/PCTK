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
# Set lib base name and out put path
#-----------------------------------------------------------------------------------------------------------------------
set(PCTK_LIB_NAME Osgi)
set(LIBRARY_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR})


#-----------------------------------------------------------------------------------------------------------------------
# Add library
#-----------------------------------------------------------------------------------------------------------------------
pctk_add_library(${PCTK_LIB_NAME}
    EXCEPTIONS
    PUBLIC_HEADERS
    source/pctkOsgiFramework.h
    source/pctkOsgiGlobal.h
    SOURCES
    source/pctkOsgiFramework.cpp
    LIBRARIES
    PCTK::CorePrivate
    PUBLIC_LIBRARIES
    PCTK::Core
    PRECOMPILED_HEADER
    "source/pctkOsgiPch.h")


#-----------------------------------------------------------------------------------------------------------------------
# Add examples and tests
#-----------------------------------------------------------------------------------------------------------------------
if(PCTK_BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

if(PCTK_BUILD_TESTS)
    add_subdirectory(tests)
endif()