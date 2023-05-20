function(pctk_internal_collect_direct_target_dependencies target targets_out_var)
    __pctk_internal_walk_libs("${target}" "${targets_out_var}" _rcc_objects
        "pctk_direct_targets_dict" "direct_targets")
    set("${targets_out_var}" "${${targets_out_var}}" PARENT_SCOPE)
endfunction()

macro(pctk_internal_set_pkg_config_cpp_flags var options flag)
    set(tmpopts "${options}")
    list(FILTER tmpopts EXCLUDE REGEX "\\$<BUILD_INTERFACE:[^,>]+>")
    list(FILTER tmpopts EXCLUDE REGEX "\\$<TARGET_PROPERTY:[^,>]+>")
    list(TRANSFORM tmpopts REPLACE "\\$<\\$<LINK_LANGUAGE:[^,>]+>:([^,>]+)>" "\\1")
    list(TRANSFORM tmpopts REPLACE "\\$<INSTALL_INTERFACE:([^,>]+)>" "\\1")
    list(TRANSFORM tmpopts REPLACE ">" "$<ANGLE-R>")
    list(TRANSFORM tmpopts REPLACE "," "$<COMMA>")
    set(${var} "$<$<BOOL:${tmpopts}>:${flag}$<JOIN:$<REMOVE_DUPLICATES:${tmpopts}>, ${flag}>>")
    unset(tmpopts)
endmacro()

# Create a PCTK*.pc file intended for pkg-config consumption.
function(pctk_internal_generate_pkg_config_file module)
    # TODO: PkgConfig is supported under MSVC with pkgconf (github.com/pkgconf/pkgconf)
    if((NOT UNIX OR PCTK_FEATURE_framework)
        AND NOT MINGW OR CMAKE_VERSION VERSION_LESS "3.20" OR ANDROID)
        return()
    endif()
    if(NOT BUILD_SHARED_LIBS)
        return()
    endif()

    set(pkgconfig_file "${PCTK_CMAKE_EXPORT_NAMESPACE}${module}")
    set(pkgconfig_name "${PCTK_CMAKE_EXPORT_NAMESPACE} ${module}")
    set(pkgconfig_description "PCTK ${module} module")
    set(target "${PCTK_CMAKE_EXPORT_NAMESPACE}::${module}")
    set(is_interface_library "$<STREQUAL:$<TARGET_PROPERTY:${target},TYPE>,INTERFACE_LIBRARY>")
    # The flags macro expanded this variables so it's better to set them at
    # their corresponding PkgConfig string.
    set(includedir "\${includedir}")
    set(mkspecsdir "\${mkspecsdir}")

    get_target_property(is_internal_module ${target} _pctk_is_internal_module)
    if(is_internal_module)
        return()
    endif()

    message(INSTALL_INCLUDEDIR=${INSTALL_INCLUDEDIR})
    get_target_property(loose_link_options ${target} INTERFACE_LINK_OPTIONS)
    get_target_property(loose_compile_defs ${target} INTERFACE_COMPILE_DEFINITIONS)
    get_target_property(loose_include_dirs ${target} INTERFACE_INCLUDE_DIRECTORIES)
    list(TRANSFORM loose_include_dirs REPLACE "${INSTALL_INCLUDEDIR}" "\${includedir}")
    list(TRANSFORM loose_include_dirs REPLACE "${INSTALL_MKSPECSDIR}" "\${mkspecsdir}")

    pctk_internal_set_pkg_config_cpp_flags(link_options "${loose_link_options}" "")
    pctk_internal_set_pkg_config_cpp_flags(compile_defs "${loose_compile_defs}" -D)
    pctk_internal_set_pkg_config_cpp_flags(include_dirs "${loose_include_dirs}" -I)
    if("${include_dirs}" MATCHES "\\${mkspecsdir}")
        set(contains_mkspecs TRUE)
    endif()

    # TODO: Handle macOS framework builds
    pctk_internal_collect_direct_target_dependencies(${target} loose_target_requires)
    foreach(dep IN LISTS loose_target_requires)
        if(dep MATCHES "^pctk::")
            string(REGEX REPLACE "PCTK" "${PCTK_CMAKE_EXPORT_NAMESPACE}" dep ${dep})
        else()
            # TODO: Figure out a way to get non-PCTK requirements PkgConfig files.
            continue()
        endif()
        if(NOT TARGET ${dep})
            continue()
        endif()
        get_target_property(is_internal_module ${dep} _pctk_is_internal_module)
        if(is_internal_module OR dep MATCHES ".*platform_.*internal")
            continue()
        endif()
        get_target_property(type ${dep} TYPE)
        if(type STREQUAL "INTERFACE_LIBRARY")
            if(dep MATCHES "(.*)Private")
                set(dep "${CMAKE_MATCH_1}")
            endif()
            get_target_property(type ${dep} TYPE)
        endif()
        string(REGEX REPLACE "::" "" req ${dep})
        if(type STREQUAL "STATIC_LIBRARY")
            list(APPEND target_libs -l${req})
        else()
            list(APPEND target_requires ${req})
        endif()
    endforeach()
    string(APPEND link_options " $<JOIN:$<REMOVE_DUPLICATES:${target_libs}>, >")

    pctk_path_join(path_suffix "${INSTALL_LIBDIR}" pkgconfig)
    pctk_path_join(build_dir "${PCTK_BUILD_DIR}" "${path_suffix}")
    pctk_path_join(install_dir "${PCTK_INSTALL_DIR}" "${path_suffix}")

    set(step_prefix "preliminary_pc_for_${pkgconfig_file}")
    pctk_path_join(template_pc "${PCTK_CMAKE_DIR}" PkgConfigLibrary.pc.in)
    pctk_path_join(pc_step1_path "${build_dir}" ${step_prefix}_step1.pc)
    pctk_path_join(pc_step2_path "${build_dir}" ${step_prefix}_$<CONFIG>_step2.pc)

    configure_file("${template_pc}" "${pc_step1_path}" @ONLY)

    file(GENERATE OUTPUT "${pc_step2_path}" INPUT "${pc_step1_path}")

    if(PCTK_GENERATOR_IS_MULTI_CONFIG)
        set(configs ${CMAKE_CONFIGURATION_TYPES})
        set(rels ${configs})
        list(FILTER rels INCLUDE REGEX "(Release|RelWithDebInfo|MinSizeRel)")
        if(rels)
            list(GET rels 0 release)
        endif()
    else()
        set(configs ${CMAKE_BUILD_TYPE})
        set(release ${configs})
    endif()

    foreach(config ${configs})
        if(config STREQUAL "Debug" AND CMAKE_DEBUG_POSTFIX)
            set(postfix ${CMAKE_DEBUG_POSTFIX})
        elseif(NOT config STREQUAL release)
            string(TOLOWER "_${config}" postfix)
        else()
            set(postfix "")
        endif()

        set(extra_args "")
        if(NOT postfix STREQUAL "")
            list(APPEND extra_args "-DPOSTFIX=${postfix}")
        endif()

        pctk_path_join(pc_step2_path "${build_dir}" ${step_prefix}_${config}_step2.pc)
        pctk_path_join(final_pc_path "${build_dir}" ${pkgconfig_file} ${postfix}.pc)

        add_custom_command(
            OUTPUT "${final_pc_path}"
            DEPENDS "${pc_step2_path}"
            "${PCTK_CMAKE_DIR}/PCTKFinishPkgConfigFile.cmake"
            COMMAND ${CMAKE_COMMAND}
            "-DIN_FILE=${pc_step2_path}"
            "-DOUT_FILE=${final_pc_path}"
            ${extra_args}
            -P "${PCTK_CMAKE_DIR}/PCTKFinishPkgConfigFile.cmake"
            VERBATIM
            COMMENT "Generating pc file for target ${target}")

        # This is inspired by https://gitlab.kitware.com/cmake/cmake/-/issues/20842
        target_sources(${module} PRIVATE "${final_pc_path}")

        pctk_install(FILES "${final_pc_path}" DESTINATION "${install_dir}")
    endforeach()
endfunction()
