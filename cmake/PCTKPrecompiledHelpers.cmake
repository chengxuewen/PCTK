########################################################################################################################
#
# Library: PCTK
#
# Copyright (C) 2021~2022 ChengXueWen. Contact: 1398831004@qq.com
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
# Creates a PreCompiled Header
# TARGET target name
# SCOPE INTERFACE|PUBLIC|PRIVATE
# PCH_FILES The full path of the dependency incl. FileName
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_target_precompile_headers TARGET SCOPE PCH_FILES)
    if(COMMAND target_precompile_headers)
        target_precompile_headers(${TARGET} ${SCOPE} ${PCH_FILES})
    else()
        set_target_properties(${TARGET} PROPERTIES COTIRE_C_PREFIX_HEADER_INIT "${PCH_FILES}")
        include(cotire)
        cotire(${TARGET})
    endif()
endfunction(pctk_target_precompile_headers)


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_update_precompiled_header target precompiled_header)
    if(precompiled_header AND BUILD_WITH_PCH)
        set_property(TARGET "${target}" APPEND PROPERTY "PRECOMPILE_HEADERS"
            "$<$<OR:$<COMPILE_LANGUAGE:CXX>,$<COMPILE_LANGUAGE:OBJCXX>>:${precompiled_header}>")
    endif()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_update_ignore_pch_source target sources)
    if(sources)
        set_source_files_properties(${sources} PROPERTIES SKIP_PRECOMPILE_HEADERS ON)
    endif()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_ignore_pch_obj_c_sources target sources)
    # No obj-cxx PCH support for versions lower than 3.16.
    if(CMAKE_VERSION VERSION_LESS 3.16.0)
        list(FILTER sources INCLUDE REGEX "\\.mm$")
        pctk_update_ignore_pch_source("${target}" "${sources}")
    endif()
endfunction()

    