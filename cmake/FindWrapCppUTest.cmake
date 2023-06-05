# ######################################################################################################################
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
# ######################################################################################################################

# We can't create the same interface imported target multiple times, CMake will complain if we do
# that. This can happen if the find_package call is done in multiple different subdirectories.
if(TARGET WrapCppUTest::WrapCppUTest)
    set(WrapCppUTest_FOUND ON)
    return()
endif()

include(CheckCXXSourceCompiles)

set(cpputest_test_sources
    "#include <CppUTest/CommandLineTestRunner.h>
    int main(int, char **)
    {
        MemoryLeakWarningPlugin::turnOffNewDeleteOverloads();
        return 0;
    }")

check_cxx_source_compiles("${cpputest_test_sources}" HAVE_CPPUTEST)
if(NOT HAVE_CPPUTEST)
    set(_req_libraries "${CMAKE_REQUIRE_LIBRARIES}")
    set(CMAKE_REQUIRE_LIBRARIES "CppUTest")
    check_cxx_source_compiles("${cpputest_test_sources}" HAVE_CPPUTEST_WITH_LIB)
    set(CMAKE_REQUIRE_LIBRARIES "${_req_libraries}")
endif()

add_library(WrapCppUTest::WrapCppUTest INTERFACE IMPORTED)
if(HAVE_CPPUTEST_WITH_LIB)
    target_link_libraries(WrapCppUTest::WrapCppUTest INTERFACE CppUTest)
else()
    message(STATUS "add 3rdparty cpputest library")
    include(cpputest-4.0)
    find_package(CppUTest 4.0 PATHS ${CPPUTEST_INSTALL_DIR} REQUIRED)
    set_target_properties(WrapCppUTest::WrapCppUTest PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${CppUTest_INCLUDE_DIRS}")
    set_target_properties(WrapCppUTest::WrapCppUTest PROPERTIES INTERFACE_LINK_LIBRARIES "${CppUTest_LIBRARIES}")
endif()

set(WrapCppUTest_FOUND 1)
