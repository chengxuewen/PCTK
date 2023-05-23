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
# Bail out if any part of the build directory's path is symlinked.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_check_if_path_has_symlinks path)
    get_filename_component(dir "${path}" ABSOLUTE)
    set(is_symlink FALSE)
    if(CMAKE_HOST_WIN32)
        # CMake marks Windows mount points as symbolic links, so use simplified REALPATH check
        # on Windows platforms instead of IS_SYMLINK.
        get_filename_component(dir_realpath "${dir}" REALPATH)
        if(NOT dir STREQUAL dir_realpath)
            set(is_symlink TRUE)
        endif()
    else()
        while(TRUE)
            if(IS_SYMLINK "${dir}")
                set(is_symlink TRUE)
                break()
            endif()

            set(prev_dir "${dir}")
            get_filename_component(dir "${dir}" DIRECTORY)
            if("${dir}" STREQUAL "${prev_dir}")
                return()
            endif()
        endwhile()
    endif()
    if(is_symlink)
        message(FATAL_ERROR "The path \"${path}\" contains symlinks. \
            This is not supported. Possible solutions:
            - map directories using a transparent mechanism such as mount --bind
            - pass the real path of the build directory to CMake, e.g. using \
            cd $(realpath <path>) before invoking cmake <source_dir>.")
    endif()
endfunction()