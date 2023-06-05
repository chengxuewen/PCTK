# ######################################################################################################################
#
# Library: PCTK
#
# Copyright (C) 2022 ChengXueWen. Contact: 1398831004@qq.com
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

set(LIBFFI_DIR_NAME "libffi-3.4.4")
set(LIBFFI_PARENT_DIR "${PROJECT_BINARY_DIR}/3rdparty")
set(LIBFFI_ROOT_DIR "${LIBFFI_PARENT_DIR}/${LIBFFI_DIR_NAME}")
set(LIBFFI_TAR_GZ_NAME "libffi-3.4.4.tar.gz")
set(LIBFFI_TAR_GZ_PATH "${PROJECT_SOURCE_DIR}/3rdparty/${LIBFFI_TAR_GZ_NAME}")
message(STATUS "Checking ${LIBFFI_TAR_GZ_NAME}...")

# Check whether the package exists
if(NOT EXISTS "${LIBFFI_TAR_GZ_PATH}")
    message(FATAL_ERROR "${LIBFFI_TAR_GZ_NAME} is not exists.")
endif()

# Check whether the compressed package is decompressed in the 3rdparty folder
unset(LIBFFI_DECOMPRESSED_DIR CACHE)
find_file(LIBFFI_DECOMPRESSED_DIR
        NAMES ${LIBFFI_DIR_NAME}
        HINTS "${LIBFFI_PARENT_DIR}"
        NO_DEFAULT_PATH)

# A prompt is displayed to verify the decompression path
message(STATUS "Checking the direction of ${LIBFFI_ROOT_DIR}")
# If there is no decompression file in the path
if(NOT LIBFFI_DECOMPRESSED_DIR)
    # A message is displayed indicating that you are ready to decompress
    message(STATUS "cd ${LIBFFI_PARENT_DIR} && tar -xzvf ${LIBFFI_TAR_GZ_PATH} -C ${LIBFFI_PARENT_DIR}/")

    # Obtain the size of the downloaded package for basic judgment
    file(SIZE ${LIBFFI_TAR_GZ_PATH} LIBFFI_TAR_GZ_SIZE)
    message(STATUS "${LIBFFI_TAR_GZ_PATH} size is ${LIBFFI_TAR_GZ_SIZE}")

    # If the size of the compressed package is 0, an error message is displayed
    if(${LIBFFI_TAR_GZ_SIZE} EQUAL 0)
        message(FATAL_ERROR "${LIBFFI_TAR_GZ_SIZE} is zero length. it had been deleted.")
    else()
        # Unzip file
        execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${LIBFFI_PARENT_DIR})
        execute_process(
                COMMAND ${CMAKE_COMMAND} -E tar -xzvf ${LIBFFI_TAR_GZ_PATH}
                WORKING_DIRECTORY ${LIBFFI_PARENT_DIR}
                RESULT_VARIABLE 100
                RESULT_VARIABLE RESULT_TAR_GZ)
        if(RESULT_TAR_GZ MATCHES 0)
            # If 0 is returned, the decompression is successful
            message(STATUS "tar -xzvf ${LIBFFI_TAR_GZ_PATH} -C ${LIBFFI_PARENT_DIR}/")
        else()
            # If the value returned is not 0, the decompression fails
            message(FATAL_ERROR "[ERROR] tar -xzvf ${LIBFFI_TAR_GZ_PATH} -C ${LIBFFI_PARENT_DIR}/ failed.")
        endif()
        unset(RESULT_TAR_GZ)
    endif()
endif()

set(LIBFFI_INSTALL_DIR "${LIBFFI_ROOT_DIR}/install")
if(EXISTS ${LIBFFI_ROOT_DIR})
    if(NOT EXISTS ${LIBFFI_INSTALL_DIR})
        execute_process(
                COMMAND ./configure --prefix=${LIBFFI_INSTALL_DIR} --disable-shared --with-pic
                WORKING_DIRECTORY "${LIBFFI_ROOT_DIR}")
        execute_process(
                COMMAND make -j4
                COMMAND make install
                WORKING_DIRECTORY "${LIBFFI_ROOT_DIR}"
                RESULT_VARIABLE RESULT_BUILD_INSTALL)
        if(RESULT_BUILD_INSTALL MATCHES 0)
            message(STATUS "libffi build install success")
        else()
            message(FATAL_ERROR "[ERROR] libffi build install failed.")
        endif()
    endif()
    set(LIBFFI_BUILD_INSTALL ON CACHE INTERNAL "libffi build install success" FORCE)
endif()