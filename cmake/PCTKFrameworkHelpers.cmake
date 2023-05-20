
function(pctk_finalize_framework_headers_copy target)
    get_target_property(target_type ${target} TYPE)
    if(${target_type} STREQUAL "INTERFACE_LIBRARY")
        return()
    endif()
    get_target_property(is_fw ${target} FRAMEWORK)
    if(NOT "${is_fw}")
        return()
    endif()
    get_target_property(headers ${target} PCTK_COPIED_FRAMEWORK_HEADERS)
    if(headers)
        # Hack to create the "Headers" symlink in the framework:
        # Create a fake header file and copy it into the framework by marking it as PUBLIC_HEADER.
        # CMake now takes care of creating the symlink.
        set(fake_header ${target}_fake_header.h)
        pctk_internal_get_main_cmake_configuration(main_config)
        file(GENERATE OUTPUT ${fake_header} CONTENT "// ignore this file\n"
            CONDITION "$<CONFIG:${main_config}>")
        string(PREPEND fake_header "${CMAKE_CURRENT_BINARY_DIR}/")
        target_sources(${target} PRIVATE ${fake_header})
        set_source_files_properties(${fake_header} PROPERTIES GENERATED ON)
        set_property(TARGET ${target} APPEND PROPERTY PUBLIC_HEADER ${fake_header})

        # Add a target, e.g. Core_framework_headers, that triggers the header copy.
        add_custom_target(${target}_framework_headers DEPENDS ${headers})
        add_dependencies(${target} ${target}_framework_headers)
    endif()
endfunction()