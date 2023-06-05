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

set(CPPUTEST_DIR_NAME "cpputest-4.0")
set(CPPUTEST_PARENT_DIR "${PROJECT_BINARY_DIR}/3rdparty")
set(CPPUTEST_ROOT_DIR "${CPPUTEST_PARENT_DIR}/${CPPUTEST_DIR_NAME}")
set(CPPUTEST_BUILD_DIR "${CPPUTEST_ROOT_DIR}/build")
set(CPPUTEST_INSTALL_DIR "${CPPUTEST_ROOT_DIR}/install_")
set(CPPUTEST_TAR_GZ_NAME "cpputest-4.0.tar.gz")
set(CPPUTEST_TAR_GZ_PATH "${PROJECT_SOURCE_DIR}/3rdparty/${CPPUTEST_TAR_GZ_NAME}")
message(STATUS "Checking ${CPPUTEST_TAR_GZ_NAME}...")

# Check whether the package exists
if (NOT EXISTS "${CPPUTEST_TAR_GZ_PATH}")
    message(FATAL_ERROR "${CPPUTEST_TAR_GZ_NAME} is not exists.")
endif()

# Check whether the compressed package is decompressed in the 3rdparty folder
unset(CPPUTEST_DECOMPRESSED_DIR CACHE)
find_file(CPPUTEST_DECOMPRESSED_DIR
    NAMES ${CPPUTEST_DIR_NAME}
    HINTS "${CPPUTEST_PARENT_DIR}"
    NO_DEFAULT_PATH)


# A prompt is displayed to verify the decompression path
message(STATUS "Checking the direction of ${CPPUTEST_ROOT_DIR}")
# If there is no decompression file in the path
if(NOT CPPUTEST_DECOMPRESSED_DIR)
    # A message is displayed indicating that you are ready to decompress
    message(STATUS "cd ${CPPUTEST_PARENT_DIR} && tar -xzvf ${CPPUTEST_TAR_GZ_PATH} -C ${CPPUTEST_PARENT_DIR}/")

    # Obtain the size of the downloaded package for basic judgment
    file(SIZE ${CPPUTEST_TAR_GZ_PATH} CPPUTEST_TAR_GZ_SIZE)
    message(STATUS "${CPPUTEST_TAR_GZ_PATH} size is ${CPPUTEST_TAR_GZ_SIZE}")

    # If the size of the compressed package is 0, an error message is displayed
    if(${CPPUTEST_TAR_GZ_SIZE} EQUAL 0)
        message(FATAL_ERROR "${CPPUTEST_TAR_GZ_SIZE} is zero length. it had been deleted.")
    else()
        # Unzip file
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E make_directory ${PROJECT_BINARY_DIR}/3rdparty
            WORKING_DIRECTORY "${PROJECT_BINARY_DIR}")
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E make_directory ${CPPUTEST_PARENT_DIR}
            COMMAND ${CMAKE_COMMAND} -E tar -xzvf ${CPPUTEST_TAR_GZ_PATH}
            WORKING_DIRECTORY ${CPPUTEST_PARENT_DIR}
#            COMMAND tar -xzvf ${CPPUTEST_TAR_GZ_PATH} -C "${CPPUTEST_PARENT_DIR}/"
            RESULT_VARIABLE 100
            RESULT_VARIABLE RESULT_TAR)
        # If 0 is returned, the decompression is successful
        if(RESULT_TAR MATCHES 0)
            message(STATUS "tar -xzvf ${CPPUTEST_TAR_GZ_PATH} -C ${CPPUTEST_PARENT_DIR}/")
            execute_process(
                COMMAND ${CMAKE_COMMAND} -E make_directory ${CPPUTEST_BUILD_DIR}
                WORKING_DIRECTORY "${CPPUTEST_ROOT_DIR}")
            execute_process(
                COMMAND ${CMAKE_COMMAND} -E make_directory ${CPPUTEST_INSTALL_DIR}
                WORKING_DIRECTORY "${CPPUTEST_ROOT_DIR}")
            execute_process(
                COMMAND cmake -DCMAKE_INSTALL_PREFIX=${CPPUTEST_INSTALL_DIR} ${CPPUTEST_ROOT_DIR}
                WORKING_DIRECTORY "${CPPUTEST_BUILD_DIR}")
            execute_process(
                COMMAND make -j4
                COMMAND make install
                WORKING_DIRECTORY "${CPPUTEST_BUILD_DIR}")
        else()
            # If the value returned is not 0, the decompression fails
            message(FATAL_ERROR "[ERROR] tar -xzvf ${CPPUTEST_TAR_GZ_PATH} -C ${CPPUTEST_PARENT_DIR}/ failed.\n")
        endif()
        unset(RESULT_TAR)
    endif()
endif()
