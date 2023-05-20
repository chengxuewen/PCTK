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


#-----------------------------------------------------------------------------------------------------------------------
# pctk_add_test finction
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_add_test NAME)
    set(multiValueArgs SOURCES INCLUDE_DIRECTORIES LIBRARIES OUTPUT_DIRECTORY DEFINES)
    cmake_parse_arguments(ARG "" "" "${multiValueArgs}" "${ARGN}")

    if("x${ARG_OUTPUT_DIRECTORY}" STREQUAL "x")
        set(ARG_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
    endif()

    if(ARG_SOURCES)
        set(private_includes
                ${CMAKE_CURRENT_SOURCE_DIR}
                ${CMAKE_CURRENT_BINARY_DIR}
                ${ARG_INCLUDE_DIRECTORIES})

        add_executable(${NAME} ${ARG_SOURCES})

        set_target_properties(${NAME} PROPERTIES
                ARCHIVE_OUTPUT_DIRECTORY ${ARG_OUTPUT_DIRECTORY}
                RUNTIME_OUTPUT_DIRECTORY ${ARG_OUTPUT_DIRECTORY}
                LIBRARY_OUTPUT_DIRECTORY ${ARG_OUTPUT_DIRECTORY})

        target_link_libraries(${NAME} PRIVATE ${ARG_LIBRARIES})

        target_include_directories(${NAME} PRIVATE
                ${CMAKE_CURRENT_BINARY_DIR}
                ${CMAKE_CURRENT_SOURCE_DIR}
                ${ARG_INCLUDE_DIRECTORIES})

        target_compile_definitions(${NAME} PRIVATE ${ARG_DEFINES})

        set_property(TARGET ${TEST_NAME} PROPERTY INTERFACE_C_EXTENSIONS OFF)
    endif()
    add_test(NAME ${NAME} COMMAND ${NAME} WORKING_DIRECTORY ${ARG_OUTPUT_DIRECTORY})
endfunction()
