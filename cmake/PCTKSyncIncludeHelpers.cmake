

#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_sync_headers target)
    pctk_internal_detect_headers(${CMAKE_CURRENT_SOURCE_DIR} "include" public_headers)
    foreach(header ${public_headers})
        #            message(header=${header})
        pctk_compute_injection_forwarding_header("${target}"
            SOURCE "${header}"
            OUT_VAR injections)
        list(APPEND injection_headers ${injections})
    endforeach()
    pctk_internal_detect_headers(${CMAKE_CURRENT_SOURCE_DIR} "include/private" private_headers)
    foreach(header ${private_headers})
        #            message(header=${header})
        pctk_compute_injection_forwarding_header("${target}"
            SOURCE "${header}" PRIVATE
            OUT_VAR injections)
        list(APPEND injection_headers ${injections})
    endforeach()
    set(library_headers_public ${public_headers} PARENT_SCOPE)
    set(library_headers_private ${private_headers} PARENT_SCOPE)
    set(library_headers_injections ${injection_headers} PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_detect_headers base_dir sub_dir headers)
    file(GLOB header_files "${base_dir}/${sub_dir}/*.h")
    foreach(file ${header_files})
        file(READ ${file} file_content)
        if("${file_content}" STREQUAL "")
            message(WARNING "${file} cannot be empty，must contain the real include path")
        endif()
        string(REPLACE "#include" "" rel_file ${file_content})
        string(STRIP ${rel_file} rel_file)
        string(REGEX REPLACE "\"" "" rel_file ${rel_file})
        file(REAL_PATH ${rel_file} abs_file BASE_DIRECTORY "${base_dir}/${sub_dir}")
        if(NOT EXISTS "${abs_file}")
            message(WARNING "${file} file contains a path ${rel_file} does not exist")
        else()
            file(RELATIVE_PATH rel_file ${CMAKE_CURRENT_SOURCE_DIR} ${abs_file})
            list(APPEND detected_headers ${rel_file})
            #            message(rel_file=${rel_file})
            #            message(abs_file=${abs_file})
        endif()
    endforeach()
    set("${headers}" ${detected_headers} PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_install_injections target build_dir install_dir)
    set(injections ${ARGN})
    pctk_internal_library_info(module ${target})
    get_target_property(target_type ${target} TYPE)
    if(target_type STREQUAL "INTERFACE_LIBRARY")
        set(is_framework FALSE)
    else()
        get_target_property(is_framework ${target} FRAMEWORK)
    endif()
    # examples:
    #  SYNCPCTK.INJECTIONS = src/corelib/global/qconfig.h:qconfig.h:PCTKConfig src/corelib/global/qconfig_p.h:5.12.0/PCTKCore/private/qconfig_p.h
    #  SYNCPCTK.INJECTIONS = src/gui/vulkan/qvulkanfunctions.h:^qvulkanfunctions.h:QVulkanFunctions:QVulkanDeviceFunctions src/gui/vulkan/qvulkanfunctions_p.h:^5.12.0/PCTKGui/private/qvulkanfunctions_p.h
    # The are 3 parts to the assignment, divded by colons ':'.
    # The first part contains a path to a generated file in a build folder.
    # The second part contains the file name that the forwarding header should have, which points
    # to the file in the first part.
    # The third part contains multiple UpperCaseFileNames that should be forwarding headers to the
    # header specified in the second part.
    separate_arguments(injections UNIX_COMMAND "${injections}")
    foreach(injection ${injections})
        string(REPLACE ":" ";" injection ${injection})
        # Part 1.
        list(GET injection 0 file)
        # Part 2.
        list(GET injection 1 destination)
        string(REGEX REPLACE "^\\^" "" destination "${destination}")
        list(REMOVE_AT injection 0 1)
        # Part 3.
        set(fwd_hdrs ${injection})
        get_filename_component(destinationdir ${destination} DIRECTORY)
        get_filename_component(destinationname ${destination} NAME)
        get_filename_component(original_file_name ${file} NAME)

        # This describes a concrete example for easier comprehension:
        # A file 'pctkCoreConfig.h' is generated by pctk_internal_feature_write_file into
        # ${pctkdeclarative_build_dir}/src/{library_include_name}/pctkCoreConfig.h (part 1).
        #
        # Generate a lower case forwarding header (part 2) 'pctkCoreConfig.h' at the following location:
        # ${some_prefix}/include/${library_include_name}/pctkCoreConfig.h.
        #
        # Inside this file, we #include the originally generated file,
        # ${pctkdeclarative_build_dir}/src/{library_include_name}/pctkCoreConfig.h.
        #
        # ${some_prefix}'s value depends on the build type.
        # If doing a prefix build, it should point to ${current_repo_build_dir} which is ${pctkdeclarative_build_dir}.
        # If doing a non-prefix build, it should point to ${pctkbase_build_dir}.
        #
        # In the code below, ${some_prefix} == ${build_dir}.
        set(lower_case_forwarding_header_path "${build_dir}/include/${library_include_name}")
        if(destinationdir)
            string(APPEND lower_case_forwarding_header_path "/${destinationdir}")
        endif()
        set(current_repo_build_dir "${PROJECT_BINARY_DIR}")

        file(RELATIVE_PATH relpath
            "${lower_case_forwarding_header_path}"
            "${current_repo_build_dir}/${file}")
        set(main_contents "#include \"${relpath}\"")

        pctk_configure_file(OUTPUT "${lower_case_forwarding_header_path}/${original_file_name}" CONTENT "${main_contents}")

        if(is_framework)
            if(file MATCHES "_p\\.h$")
                set(header_type PRIVATE)
            else()
                set(header_type PUBLIC)
            endif()
            pctk_copy_framework_headers(${target} ${header_type} ${current_repo_build_dir}/${file})
        else()
            # Copy the actual injected (generated) header file (not the just created forwarding one)
            # to its install location when doing a prefix build. In an non-prefix build, the pctk_install
            # will be a no-op.
            pctk_path_join(install_destination
                ${install_dir} ${INSTALL_INCLUDEDIR}
                ${library_include_name} ${destinationdir})
            pctk_install(FILES ${current_repo_build_dir}/${file}
                DESTINATION ${install_destination}
                RENAME ${destinationname} OPTIONAL)
        endif()

        # Generate UpperCaseNamed forwarding headers (part 3).
        foreach(fwd_hdr ${fwd_hdrs})
            set(upper_case_forwarding_header_path "include/${library_include_name}")
            if(destinationdir)
                string(APPEND upper_case_forwarding_header_path "/${destinationdir}")
            endif()

            # Generate upper case forwarding header like QVulkanFunctions or PCTKConfig.
            pctk_configure_file(OUTPUT "${build_dir}/${upper_case_forwarding_header_path}/${fwd_hdr}"
                CONTENT "#include \"${destinationname}\"\n")

            if(is_framework)
                # Copy the forwarding header to the framework's Headers directory.
                pctk_copy_framework_headers(${target} PUBLIC
                    "${build_dir}/${upper_case_forwarding_header_path}/${fwd_hdr}")
            else()
                # Install the forwarding header.
                pctk_path_join(install_destination "${install_dir}" "${INSTALL_INCLUDEDIR}"
                    ${library_include_name})
                pctk_install(FILES "${build_dir}/${upper_case_forwarding_header_path}/${fwd_hdr}"
                    DESTINATION ${install_destination} OPTIONAL)
            endif()
        endforeach()
    endforeach()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_compute_injection_forwarding_header target)
    pctk_parse_all_arguments(arg "pctk_compute_injection_forwarding_header"
        "PRIVATE" "SOURCE;OUT_VAR" "" ${ARGN})
    pctk_internal_library_info(module "${target}")
    get_filename_component(file_name "${arg_SOURCE}" NAME)

    set(source_absolute_path "${CMAKE_CURRENT_BINARY_DIR}/${arg_SOURCE}")
    file(RELATIVE_PATH relpath "${PROJECT_BINARY_DIR}" "${source_absolute_path}")

    if(arg_PRIVATE)
        set(fwd "${PROJECT_VERSION}/${library_include_name}/private/${file_name}")
    else()
        set(fwd "${file_name}")
    endif()

    string(APPEND ${arg_OUT_VAR} " ${relpath}:${fwd}")
    set(${arg_OUT_VAR} ${${arg_OUT_VAR}} PARENT_SCOPE)
endfunction()

