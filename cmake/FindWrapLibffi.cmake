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
if(TARGET WrapLibffi::WrapLibffi)
    set(WrapLibffi_FOUND ON)
    return()
endif()

include(CheckCSourceCompiles)

set(libffi_test_sources
    "#include <ffi.h>
    int main(int, char **)
    {
        ffi_type type;
        return 0;
    }")

check_c_source_compiles("${libffi_test_sources}" HAVE_LIBFFI)
if(NOT HAVE_LIBFFI)
    set(_req_libraries "${CMAKE_REQUIRE_LIBRARIES}")
    set(CMAKE_REQUIRE_LIBRARIES "libffi")
    check_c_source_compiles("${libffi_test_sources}" HAVE_LIBFFI_WITH_LIB)
    set(CMAKE_REQUIRE_LIBRARIES "${_req_libraries}")
endif()

add_library(WrapLibffi::WrapLibffi INTERFACE IMPORTED)
if(HAVE_LIBFFI_WITH_LIB)
    target_link_libraries(WrapLibffi::WrapLibffi INTERFACE libffi)
else()
    include(libffi-3.4.4)
    if(LIBFFI_BUILD_INSTALL)
        # add libffi libffi_a library
        message(STATUS "add 3rdparty libffi library")
        add_library(__libffi STATIC IMPORTED GLOBAL)
        set_target_properties(__libffi PROPERTIES
                INTERFACE_INCLUDE_DIRECTORIES ${LIBFFI_INSTALL_DIR}/include)
        if(WIN32)
            set_target_properties(__libffi PROPERTIES
                    IMPORTED_LOCATION ${LIBFFI_INSTALL_DIR}/lib/libffi.dll
                    IMPORTED_IMPLIB ${LIBFFI_INSTALL_DIR}/lib/libffi.lib)
        else()
            set_target_properties(__libffi PROPERTIES
                    IMPORTED_LOCATION ${LIBFFI_INSTALL_DIR}/lib/libffi.a)
        endif()
        target_link_libraries(WrapLibffi::WrapLibffi INTERFACE __libffi)
    endif()
endif()

set(WrapLibffi_FOUND 1)
