# ######################################################################################################################
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
# ######################################################################################################################


#-----------------------------------------------------------------------------------------------------------------------
# - If NAME of variable not defined, then define this variable
# This module defines
#  NAME - name of target variable
#  VALUE - variable of target variable
#
# Apple readline does not support readline hooks
# So we look for another one by default
#-----------------------------------------------------------------------------------------------------------------------
macro(pctk_ensure_define_variable NAME VALUE)
    if(NOT DEFINED ${NAME})
        set(${NAME} ${VALUE})
    endif()
endmacro()


#-----------------------------------------------------------------------------------------------------------------------
# Normalize the feature name to something CMake can deal with.
# Usage:
#   pctk_normalize_name(<name> <output variable>)
# Examples:
#   pctk_normalize_name("\\" out_var) # out_var = _
#   pctk_normalize_name("\\" out_var) # out_var = _
#   pctk_normalize_name("," out_var) # out_var = _
#   pctk_normalize_name("=" out_var) # out_var = _
#   pctk_normalize_name("hello world!" out_var) # out_var = hello_world_
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_normalize_name name out_var)
    if(name MATCHES "c\\+\\+")
        string(REGEX REPLACE "[^a-zA-Z0-9_]" "x" name "${name}")
    else()
        string(REGEX REPLACE "[^a-zA-Z0-9_]" "_" name "${name}")
    endif()

    set(${out_var} "${name}" PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Evaluate expression_var to boolean value
# Usage:
#   pctk_evaluate_to_boolean(<expression_var>)
# Examples:
#   set(test_val "on")
#   pctk_evaluate_to_boolean(test_var) # test_var = ON
#   set(test_val "y")
#   pctk_evaluate_to_boolean(test_var) # test_var = ON
#   set(test_val "no")
#   pctk_evaluate_to_boolean(test_var) # test_var = OFF
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_evaluate_to_boolean expression_var)
    if(${${expression_var}})
        set(${expression_var} ON PARENT_SCOPE)
    else()
        set(${expression_var} OFF PARENT_SCOPE)
    endif()
endfunction()


# Evaluate expression result value.
# Usage:
#   pctk_evaluate_expression(<result_var> [expression ...NOT/AND/STREQUAL/variable ])
# Examples:
#   set(VAL1 "")
#   pctk_evaluate_expression(test_var VAL1) # test_var = OFF
#   set(VAL2 ON)
#   pctk_evaluate_expression(test_var VAL1 AND VAL2) # test_var = OFF
#   pctk_evaluate_expression(test_var VAL1 OR VAL2) # test_var = ON
function(pctk_evaluate_expression result_var)
    set(result "")
    set(nesting_level 0)
    set(skip_next OFF)
    set(expression "${ARGN}")
    list(LENGTH expression length)

    if(0 EQUAL length)
        message(FATAL_ERROR "expression cannot be empty!")
    elseif(1 EQUAL length)
        set(result ${expression})
    else()
        math(EXPR last_index "${length} - 1")
        foreach(member_index RANGE ${last_index})
            if(${skip_next})
                set(skip_next OFF)
                continue()
            endif()

            list(GET expression ${member_index} member)
            if("${member}" STREQUAL "(")
                if(${nesting_level} GREATER 0)
                    list(APPEND result ${member})
                endif()
                math(EXPR nesting_level "${nesting_level} + 1")
                continue()
            elseif("${member}" STREQUAL ")")
                math(EXPR nesting_level "${nesting_level} - 1")
                if(nesting_level LESS 0)
                    break()
                endif()
                if(${nesting_level} EQUAL 0)
                    pctk_evaluate_expression(result ${result})
                else()
                    list(APPEND result ${member})
                endif()
                continue()
            elseif(${nesting_level} GREATER 0)
                list(APPEND result ${member})
                continue()
            elseif("${member}" STREQUAL "NOT")
                list(APPEND result ${member})
                continue()
            elseif("${member}" STREQUAL "TARGET")
                list(APPEND result ${member})
                continue()
            elseif("${member}" STREQUAL "AND")
                pctk_evaluate_to_boolean(result)
                if(NOT ${result})
                    break()
                endif()
                set(result "")
            elseif("${member}" STREQUAL "OR")
                pctk_evaluate_to_boolean(result)
                if(${result})
                    break()
                endif()
                set(result "")
            elseif("${member}" STREQUAL "STREQUAL" AND member_index LESS ${length})
                # Unfortunately the semantics for STREQUAL in if() are broken when the
                # RHS is an empty string and the parameters to if are coming through a variable.
                # So we expect people to write the empty string with single quotes and then we
                # do the comparison manually here.
                list(LENGTH result lhsIndex)
                math(EXPR lhsIndex "${lhsIndex}-1")
                list(GET result ${lhsIndex} lhs)
                list(REMOVE_AT result ${lhsIndex})
                set(lhs "${${lhs}}")

                math(EXPR rhsIndex "${member_index}+1")
                set(skip_next ON)

                list(GET expression ${rhsIndex} rhs)
                # We can't pass through an empty string with double quotes through various
                # stages of substitution, so instead it is represented using single quotes
                # and resolve here.
                string(REGEX REPLACE "'(.*)'" "\\1" rhs "${rhs}")

                string(COMPARE EQUAL "${lhs}" "${rhs}" string_compare_result)
                list(APPEND result ${string_compare_result})
            else()
                if(DEFINED "${member}")
                    list(APPEND result ${member})
                endif()
            endif()
        endforeach()
    endif()


    if("${result}" STREQUAL "")
        set(result ON)
    else()
        pctk_evaluate_to_boolean(result)
    endif()

    set(${result_var} ${result} PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# pctk_configure_file(OUTPUT output-file <INPUT input-file | CONTENT content>)
# input-file is relative to ${CMAKE_CURRENT_SOURCE_DIR}
# output-file is relative to ${CMAKE_CURRENT_BINARY_DIR}
#
# This function is similar to file(GENERATE OUTPUT) except it writes the content to the file at configure time, rather
# than at generate time. Once CMake 3.18 is released, it can use file(CONFIGURE) in its implmenetation. Until then, it
# uses configure_file() with a generic input file as source, when used with the CONTENT signature.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_configure_file)
    pctk_parse_all_arguments(arg "pctk_configure_file" "" "OUTPUT;INPUT;CONTENT" "" ${ARGN})

    if(NOT arg_OUTPUT)
        message(FATAL_ERROR "No output file provided to pctk_configure_file.")
    endif()

    if(arg_CONTENT)
        set(template_name "PCTKFileConfigure.txt.in")
        set(input_file "${PROJECT_SOURCE_DIR}/cmake/${template_name}")
        set(__pctk_file_configure_content "${arg_CONTENT}")
    elseif(arg_INPUT)
        set(input_file "${arg_INPUT}")
    else()
        message(FATAL_ERROR "No input value provided to pctk_configure_file.")
    endif()

    configure_file("${input_file}" "${arg_OUTPUT}" @ONLY)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# A version of cmake_parse_arguments that makes sure all arguments are processed and errors out
# with a message about ${type} having received unknown arguments.
#
# pctk_parse_all_arguments(arg "test_func" "" "OUTPUT;INPUT;CONTENT" "" ${ARGN})
#-----------------------------------------------------------------------------------------------------------------------
macro(pctk_parse_all_arguments result type flags options multiopts)
    cmake_parse_arguments(${result} "${flags}" "${options}" "${multiopts}" ${ARGN})

    if(DEFINED ${result}_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "Unknown arguments were passed to ${type} (${${result}_UNPARSED_ARGUMENTS}).")
    endif()
endmacro()


#-----------------------------------------------------------------------------------------------------------------------
# Print all variables defined in the current scope.
#-----------------------------------------------------------------------------------------------------------------------
macro(pctk_debug_print_variables)
    cmake_parse_arguments(__arg "DEDUP" "" "MATCH;IGNORE" ${ARGN})
    message("Known Variables:")
    get_cmake_property(__variableNames VARIABLES)
    list(SORT __variableNames)

    if(__arg_DEDUP)
        list(REMOVE_DUPLICATES __variableNames)
    endif()

    foreach(__var ${__variableNames})
        set(__ignore OFF)

        foreach(__i ${__arg_IGNORE})
            if(__var MATCHES "${__i}")
                set(__ignore ON)
                break()
            endif()
        endforeach()

        if(__ignore)
            continue()
        endif()

        set(__show OFF)

        foreach(__i ${__arg_MATCH})
            if(__var MATCHES "${__i}")
                set(__show ON)
                break()
            endif()
        endforeach()

        if(__show)
            message("    ${__var}=${${__var}}.")
        endif()
    endforeach()
endmacro()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
macro(assert)
    if(${ARGN})
    else()
        message(FATAL_ERROR "ASSERT: ${ARGN}.")
    endif()
endmacro()


#-----------------------------------------------------------------------------------------------------------------------
# Takes a list of path components and joins them into one path separated by forward slashes "/",
# and saves the path in out_var.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_path_join out_var)
    string(JOIN "/" path ${ARGN})
    set(${out_var} ${path} PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# pctk_remove_args can remove arguments from an existing list of function
# arguments in order to pass a filtered list of arguments to a different function.
# Parameters:
# out_var: result of remove all arguments specified by ARGS_TO_REMOVE from ALL_ARGS
# ARGS_TO_REMOVE: Arguments to remove.
# ALL_ARGS: All arguments supplied to cmake_parse_arguments or
# pctk_parse_all_arguments
# from which ARGS_TO_REMOVE should be removed from. We require all the
# arguments or we can't properly identify the range of the arguments detailed
# in ARGS_TO_REMOVE.
# ARGS: Arguments passed into the function, usually ${ARGV}
#
# E.g.:
# We want to forward all arguments from foo to bar, execpt ZZZ since it will
# trigger an error in bar.
#
# foo(target BAR .... ZZZ .... WWW ...)
# bar(target BAR.... WWW...)
#
# function(foo target)
# pctk_parse_all_arguments(arg "" "" "BAR;ZZZ;WWW ${ARGV})
# pctk_remove_args(forward_args
# ARGS_TO_REMOVE ${target} ZZZ
# ALL_ARGS ${target} BAR ZZZ WWW
# ARGS ${ARGV}
# )
# bar(${target} ${forward_args})
# endfunction()
#
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_remove_args out_var)
    cmake_parse_arguments(arg "" "" "ARGS_TO_REMOVE;ALL_ARGS;ARGS" ${ARGN})
    set(result ${arg_ARGS})

    foreach(arg IN LISTS arg_ARGS_TO_REMOVE)
        # find arg
        list(FIND result ${arg} find_result)

        if(NOT find_result EQUAL -1)
            # remove arg
            list(REMOVE_AT result ${find_result})
            list(LENGTH result result_len)
            list(GET result ${find_result} arg_current)

            # remove values until we hit another arg or the end of the list
            while(NOT ${arg_current} IN_LIST arg_ALL_ARGS AND find_result LESS result_len)
                list(REMOVE_AT result ${find_result})
                list(LENGTH result result_len)

                if(NOT find_result EQUAL result_len)
                    list(GET result ${find_result} arg_current)
                endif()
            endwhile()
        endif()
    endforeach()

    set(${out_var} "${result}" PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Creates a regular expression that exactly matches the given string
# Found in https://gitlab.kitware.com/cmake/cmake/issues/18580
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_re_escape out_var str)
    string(REGEX REPLACE "([][+.*()^])" "\\\\\\1" regex "${str}")
    set(${out_var} ${regex} PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Gets a target property, and returns "" if the property was not found
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_get_target_property out_var target property)
    get_target_property(result "${target}" "${property}")

    if("${result}" STREQUAL "result-NOTFOUND")
        set(result "")
    endif()

    set(${out_var} "${result}" PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Creates a wrapper ConfigVersion.cmake file to be loaded by find_package when checking for
# compatible versions. It expects a ConfigVersionImpl.cmake file in the same directory which will
# be included to do the regular version checks.
# The version check result might be overridden by the wrapper.
# package_name is used by the content of the wrapper file to include the basic package version file.
#   example: PCTK1Gui
# out_path should be the build path where the write the file.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_write_pctk_package_version_file package_name out_path)
    set(extra_code "")

    # Need to check for FEATURE_developer_build as well, because PCTK_FEATURE_developer_build is not
    # yet available when configuring the file for the BuildInternals package.
    if(FEATURE_developer_build OR PCTK_FEATURE_developer_build)
        string(APPEND extra_code "
            # Disabling version check because PCTK was configured with -developer-build.
            set(__pctk_disable_package_version_check TRUE)
            set(__pctk_disable_package_version_check_due_to_developer_build TRUE)")
    endif()

    configure_file("${PCTK_CMAKE_DIR}/PCTKCMakePackageVersionFile.cmake.in" "${out_path}" @ONLY)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Input: string
# Output: regex string to match the string case insensitively
# Example: "Release" -> "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$"
#
# Regular expressions like this are used in cmake_install.cmake files for case-insensitive string comparison.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_create_case_insensitive_regex out_var input)
    set(result "^(")
    string(LENGTH "${input}" n)
    math(EXPR n "${n} - 1")
    foreach(i RANGE 0 ${n})
        string(SUBSTRING "${input}" ${i} 1 c)
        string(TOUPPER "${c}" uc)
        string(TOLOWER "${c}" lc)
        string(APPEND result "[${uc}${lc}]")
    endforeach()
    string(APPEND result ")$")
    set(${out_var} "${result}" PARENT_SCOPE)
endfunction()