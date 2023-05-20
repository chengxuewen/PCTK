########################################################################################################################
#
# Library: PCTK
#
# Copyright (C) 2023 ChengXueWen. Contact: 1398831004@qq.com
# Copyright 2007 Alexander Neundorf <neundorf@kde.org>
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
# pctk_configure_feature finction : Make subdirectories optional.
#
#   pctk_optional_add_subdirectory(<dir>)
#
# This behaves like add_subdirectory(), except that it does not complain if the directory does not exist.  Additionally,
# if the directory does exist, it creates an option to allow the user to skip it. The option will be named BUILD_<dir>.
#
# This is useful for "meta-projects" that combine several mostly-independent sub-projects.
#
# If the CMake variable DISABLE_ALL_OPTIONAL_SUBDIRECTORIES is set to TRUE for the first CMake run on the project,
# all optional subdirectories will be disabled by default (but can of course be enabled via the respective options).
# For example, the following will disable all optional subdirectories except the one named "foo":
#
# .. code-block:: sh
#
#   cmake -DDISABLE_ALL_OPTIONAL_SUBDIRECTORIES=TRUE -DBUILD_foo=TRUE myproject
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_optional_add_subdirectory _dir)
    get_filename_component(_fullPath ${_dir} ABSOLUTE)
    if(EXISTS ${_fullPath}/CMakeLists.txt)
        if(DISABLE_ALL_OPTIONAL_SUBDIRECTORIES)
            set(_DEFAULT_OPTION_VALUE FALSE)
        else()
            set(_DEFAULT_OPTION_VALUE TRUE)
        endif()
        if(DISABLE_ALL_OPTIONAL_SUBDIRS AND NOT DEFINED BUILD_${_dir})
            set(_DEFAULT_OPTION_VALUE FALSE)
        endif()
        option(BUILD_${_dir} "Build directory ${_dir}" ${_DEFAULT_OPTION_VALUE})
        if(BUILD_${_dir})
            add_subdirectory(${_dir})
        endif()
    endif()
endfunction()
