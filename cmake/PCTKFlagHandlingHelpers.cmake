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
# Set CXX standard
#-----------------------------------------------------------------------------------------------------------------------
#set(PCTK_CXX_STANDARD 98 CACHE STRING "PCTK CXX standard.")
#set(CMAKE_CXX_STANDARD ${PCTK_CXX_STANDARD})
#set(CMAKE_CXX_EXTENSIONS ON)
#set(CMAKE_CXX_STANDARD_REQUIRED OFF)
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -std=c++${PCTK_CXX_STANDARD}")
#set(PCTK_VALID_CXX_STANDARDS 98 11 14 17 20)
#if(NOT PCTK_CXX_STANDARD IN_LIST PCTK_VALID_CXX_STANDARDS)
#    message(FATAL_ERROR "Invalid CXX standard in CXX${PCTK_CXX_STANDARD}")
#endif()
#if(PCTK_CXX_STANDARD_CACHE EQUAL PCTK_CXX_STANDARD)
#    set(PCTK_CMAKE_CXX_FLAGS_CHANGED NO)
#else()
#    set(PCTK_CMAKE_CXX_FLAGS_CHANGED YES)
#endif()
#set(PCTK_CXX_STANDARD_CACHE ${PCTK_CXX_STANDARD} CACHE INTERNAL "cache PCTK_CXX_STANDARD value." FORCE)
#message(STATUS "Using CXX: ${CMAKE_CXX_STANDARD}")
#message(STATUS "Set CXX extensions: ${CMAKE_CXX_EXTENSIONS}")
#


function(pctk_set_language_standards target)
    if(PCTK_FEATURE_CXX20)
        set(CMAKE_CXX_STANDARD 20 PARENT_SCOPE)
    elseif(PCTK_FEATURE_CXX17)
        set(CMAKE_CXX_STANDARD 17 PARENT_SCOPE)
    elseif(PCTK_FEATURE_CXX14)
        set(CMAKE_CXX_STANDARD 14 PARENT_SCOPE)
    elseif(PCTK_FEATURE_CXX11)
        set(CMAKE_CXX_STANDARD 11 PARENT_SCOPE)
    else()
        set(CMAKE_CXX_STANDARD 98 PARENT_SCOPE)
    endif()
    set(${target}_CXX_STANDARD ${CMAKE_CXX_STANDARD} CACHE STRING "${target} CXX standard.")

    set(CMAKE_C_STANDARD 99 PARENT_SCOPE)
    set(CMAKE_C_STANDARD_REQUIRED ON PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_skip_warnings_are_errors_when_repo_unclean target)
    if(PCTK_REPO_NOT_WARNINGS_CLEAN)
        pctk_skip_warnings_are_errors("${target}")
    endif()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_skip_warnings_are_errors target)
    get_target_property(target_type "${target}" TYPE)
    if(target_type STREQUAL "INTERFACE_LIBRARY")
        return()
    endif()
    set_target_properties("${target}" PROPERTIES PCTK_SKIP_WARNINGS_ARE_ERRORS ON)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_library_deprecation_level result)
    # PCTK_DISABLE_DEPPRECATED_BEFORE controls which version we use as a cut-off
    # compiling in to the library. E.g. if it is set to PCTK_VERSION then no
    # code which was deprecated before PCTK_VERSION will be compiled in.
    if(WIN32)
        # On Windows, due to the way DLLs work, we need to export all functions,
        # including the inlines
        list(APPEND deprecations "PCTK_DISABLE_DEPRECATED_BEFORE=0x040800")
    else()
        # On other platforms, PCTK's own compilation goes needs to compile the PCTK 5.0 API
        list(APPEND deprecations "PCTK_DISABLE_DEPRECATED_BEFORE=0x050000")
    endif()
    # PCTK_DEPRECATED_WARNINGS_SINCE controls the upper-bound of deprecation
    # warnings that are emitted. E.g. if it is set to 7.0 then all deprecations
    # during the 6.* lifetime will be warned about in PCTK builds.
    list(APPEND deprecations "PCTK_DEPRECATED_WARNINGS_SINCE=0x070000")
    set("${result}" "${deprecations}" PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_set_msvc_cplusplus_options target visibility)
    # For MSVC we need to explicitly pass -Zc:__cplusplus to get correct __cplusplus.
    # Check pctk_config_compile_test for more info.
    if(MSVC AND MSVC_VERSION GREATER_EQUAL 1913)
        set(flags "-Zc:__cplusplus" "-permissive-")
        target_compile_options("${target}" ${visibility} "$<$<COMPILE_LANGUAGE:CXX>:${flags}>")
    endif()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_set_language_standards_interface_compile_features target)
    # Regardless of which C++ standard is used to build PCTK itself, require C++17 when building
    # PCTK applications using CMake (because the PCTK header files use C++17 features).
    set(cpp_feature "cxx_std_17")
    target_compile_features("${target}" INTERFACE ${cpp_feature})
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_enable_utf8_sources target)
    set(utf8_flags "")
    if(MSVC)
        list(APPEND utf8_flags "-utf-8")
    endif()

    if(utf8_flags)
        # Allow opting out by specifying the PCTK_NO_UTF8_SOURCE target property.
        set(opt_out_condition "$<NOT:$<BOOL:$<TARGET_PROPERTY:PCTK_NO_UTF8_SOURCE>>>")
        # Only set the compiler option for C and C++.
        set(language_condition "$<COMPILE_LANGUAGE:C,CXX>")
        # Compose the full condition.
        set(genex_condition "$<AND:${opt_out_condition},${language_condition}>")
        set(utf8_flags "$<${genex_condition}:${utf8_flags}>")
        target_compile_options("${target}" INTERFACE "${utf8_flags}")
    endif()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_enable_unicode_defines)
    if(WIN32)
        set(no_unicode_condition "$<NOT:$<BOOL:$<TARGET_PROPERTY:PCTK_NO_UNICODE_DEFINES>>>")
        target_compile_definitions(platform INTERFACE "$<${no_unicode_condition}:UNICODE;_UNICODE>")
    endif()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Sets the exceptions flags for the given target according to exceptions_on
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_set_exceptions_flags target exceptions_on)
    set(_defs "")
    set(_flag "")
    if(exceptions_on)
        if(MSVC)
            set(_flag "/EHsc")
            if((MSVC_VERSION GREATER_EQUAL 1929) AND NOT CLANG)
                set(_flag ${_flag} "/d2FH4")
            endif()
        endif()
    else()
        set(_defs "PCTK_NO_EXCEPTIONS")
        if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
            set(_flag "/EHs-c-" "/wd4530" "/wd4577")
        elseif("${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU|AppleClang|InteLLLVM")
            set(_flag "-fno-exceptions")
        elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
            if(MSVC)
                set(_flag "/EHs-c-" "/wd4530" "/wd4577")
            else()
                set(_flag "-fno-exceptions")
            endif()
        endif()
    endif()

    target_compile_definitions("${target}" PRIVATE ${_defs})
    target_compile_options("${target}" PRIVATE ${_flag})
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
####TODO::del
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_add_linker_version_script target)
    pctk_parse_all_arguments(arg "pctk_internal_add_linker" "" "" "PRIVATE_HEADERS" ${ARGN})

    if(TEST_ld_version_script)
        set(contents "PCTK_${PROJECT_VERSION_MAJOR}_PRIVATE_API {\n    pctk_private_api_tag*;\n")
        foreach(ph ${arg_PRIVATE_HEADERS})
            string(APPEND contents "    @FILE:${ph}@\n")
        endforeach()
        string(APPEND contents "};\n")
        set(current "PCTK_${PROJECT_VERSION_MAJOR}")
        if(PCTK_NAMESPACE STREQUAL "")
            set(tag_symbol "pctk_version_tag")
        else()
            set(tag_symbol "pctk_version_tag_${PCTK_NAMESPACE}")
        endif()
        string(APPEND contents "${current} { *; };\n")

        foreach(minor_version RANGE ${PROJECT_VERSION_MINOR})
            set(previous "${current}")
            set(current "PCTK_${PROJECT_VERSION_MAJOR}.${minor_version}")
            if(minor_version EQUAL ${PROJECT_VERSION_MINOR})
                string(APPEND contents "${current} { ${tag_symbol}; } ${previous};\n")
            else()
                string(APPEND contents "${current} {} ${previous};\n")
            endif()
        endforeach()

        set(infile "${CMAKE_CURRENT_BINARY_DIR}/${target}.version.in")
        set(outfile "${CMAKE_CURRENT_BINARY_DIR}/${target}.version")

        file(GENERATE OUTPUT "${infile}" CONTENT "${contents}")

        pctk_ensure_perl()

        set(generator_command "${HOST_PERL}"
            "${PCTK_MKSPECS_DIR}/features/data/unix/findclasslist.pl"
            "<" "${infile}" ">" "${outfile}")
        set(generator_dependencies
            "${infile}"
            "${PCTK_MKSPECS_DIR}/features/data/unix/findclasslist.pl")

        add_custom_command(
            OUTPUT "${outfile}"
            COMMAND ${generator_command}
            DEPENDS ${generator_dependencies}
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            COMMENT "Generating version linker script for target ${target}"
            VERBATIM)
        add_custom_target(${target}_version_script DEPENDS ${outfile})
        add_dependencies(${target} ${target}_version_script)
        target_link_options(${target} PRIVATE "-Wl,--version-script,${outfile}")
    endif()
endfunction()


function(pctk_internal_add_link_flags_no_undefined target)
    if(NOT PCTK_BUILD_SHARED_LIBS)
        return()
    endif()
    if((GCC OR CLANG) AND NOT MSVC)
        if(CLANG AND PCTK_FEATURE_sanitizer)
            return()
        endif()
        set(previous_CMAKE_REQUIRED_LINK_OPTIONS ${CMAKE_REQUIRED_LINK_OPTIONS})

        set(CMAKE_REQUIRED_LINK_OPTIONS "-Wl,-undefined,error")
        check_cxx_source_compiles("int main() {}" HAVE_DASH_UNDEFINED_SYMBOLS)
        if(HAVE_DASH_UNDEFINED_SYMBOLS)
            set(no_undefined_flag "-Wl,-undefined,error")
        endif()

        set(CMAKE_REQUIRED_LINK_OPTIONS "-Wl,--no-undefined")
        check_cxx_source_compiles("int main() {}" HAVE_DASH_DASH_NO_UNDEFINED)
        if(HAVE_DASH_DASH_NO_UNDEFINED)
            set(no_undefined_flag "-Wl,--no-undefined")
        endif()

        set(CMAKE_REQUIRED_LINK_OPTIONS ${previous_CMAKE_REQUIRED_LINK_OPTIONS})

        if(NOT HAVE_DASH_UNDEFINED_SYMBOLS AND NOT HAVE_DASH_DASH_NO_UNDEFINED)
            message(FATAL_ERROR "platform linker doesn't support erroring upon encountering undefined symbols. Target:\"${target}\".")
        endif()
        target_link_options("${target}" PRIVATE "${no_undefined_flag}")
    endif()
endfunction()