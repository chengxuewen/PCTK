########################################################################################################################
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
########################################################################################################################

include(CMakeDependentOption)


# Provides an option that the user can optionally select.
# Can accept condition to control when option is available for user.
# Usage:
#   pctk_option(<option_variable>
#          <help string describing the option>
#          <initial value or boolean expression>
#          [FORCE <force set initial/expression value to variable>]
#          [DEPENDS <dependent on other options or a set of other conditions>]
#          [SET <set variable value to other variables>]
#          [SET_NEGATE <set variable negative value to other variables>]
#          [VERIFY <condition>])
# Examples:
function(pctk_option variable description value)
    pctk_parse_all_arguments(arg
            "pctk_option"
            "FORCE"
            ""
            "DEPENDS;EMIT_IF;SET;SET_NEGATE;VERIFY" ${ARGN})

    pctk_evaluate_expression(result ${value})

    if("${arg_EMIT_IF}" STREQUAL "")
        set(emit_if ON)
    else()
        pctk_evaluate_expression(emit_if ${arg_EMIT_IF})
    endif()

    set(input OFF)
    # If INPUT_ is defined trying to use INPUT_ variable to enable/disable option.
    if((DEFINED "INPUT_${variable}")
            AND (NOT "${INPUT_${variable}}" STREQUAL "undefined")
            AND (NOT "${INPUT_${variable}}" STREQUAL ""))
        set(input ON)
        if(INPUT_${variable})
            set(input_result ON)
        else()
            set(input_result OFF)
        endif()
    endif()

    # Warn about a option which is not emitted, but the user explicitly provided a value for it.
    if(input)
        if(emit_if)
            set(result ${input_result})
        else()
            message(WARNING "Option ${variable} is not emitted, but the user explicitly provided a value for it.")
        endif()
    endif()


    # Evaluate depends result
    if("${arg_DEPENDS}" STREQUAL "")
        set(depends_result ON)
    else()
        pctk_evaluate_expression(depends_result ${arg_DEPENDS})
    endif()

    if(${depends_result})
        if(input AND emit_if)
            unset(${variable} CACHE)
            set(${variable} ${result} CACHE STRING "${description}" FORCE)
        else()
            if(_option_old_visible_${variable})
                unset(${variable} CACHE)
                set(${variable} ${result} CACHE BOOL "${description}")
                set(_option_old_visible_${variable} OFF CACHE INTERNAL "${description}" FORCE)
            else()
                set(${variable} ${result} CACHE BOOL "${description}")
            endif()
        endif()
    else()
        set(${variable} "OFF" CACHE STRING "${description} depends on ${arg_DEPENDS}!" FORCE)
        set(_option_old_visible_${variable} ON CACHE INTERNAL "${description}" FORCE)
    endif()


    foreach(set ${arg_SET})
        set(${set} ${${variable}} PARENT_SCOPE)
    endforeach()

    foreach(set ${arg_SET_NEGATE})
        if(${${variable}})
            set(${set} OFF PARENT_SCOPE)
        else()
            set(${set} ON PARENT_SCOPE)
        endif()
    endforeach()
endfunction()
