

#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_android_apply_arch_suffix target)
    get_target_property(target_type ${target} TYPE)
    if(target_type STREQUAL "SHARED_LIBRARY" OR target_type STREQUAL "MODULE_LIBRARY")
        set_property(TARGET "${target}" PROPERTY SUFFIX "_${CMAKE_ANDROID_ARCH_ABI}.so")
    elseif(target_type STREQUAL "STATIC_LIBRARY")
        set_property(TARGET "${target}" PROPERTY SUFFIX "_${CMAKE_ANDROID_ARCH_ABI}.a")
    endif()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# The function configures external projects for ABIs that target packages need to build with.
# Each target adds build step to the external project that is linked to the
# pctk_internal_android_${abi}-${target}_build target in the primary ABI build tree.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_configure_android_multiabi_target target)
    # Functionality is only applicable for the primary ABI
    if(PCTK_IS_ANDROID_MULTI_ABI_EXTERNAL_PROJECT)
        return()
    endif()

    get_target_property(target_abis ${target} PCTK_ANDROID_ABIS)
    if(target_abis)
        # Use target-specific Qt for Android ABIs.
        set(android_abis ${target_abis})
    elseif(PCTK_ANDROID_BUILD_ALL_ABIS)
        # Use autodetected Qt for Android ABIs.
        set(android_abis ${PCTK_DEFAULT_ANDROID_ABIS})
    elseif(PCTK_ANDROID_ABIS)
        # Use project-wide Qt for Android ABIs.
        set(android_abis ${PCTK_ANDROID_ABIS})
    else()
        # User have an empty list of Qt for Android ABIs.
        message(FATAL_ERROR
            "The list of Android ABIs is empty, when building ${target}.\n"
            "You have the following options to select ABIs for a target:\n"
            " - Set the PCTK_ANDROID_ABIS variable before calling pctk6_add_executable\n"
            " - Set the ANDROID_ABIS property for ${target}\n"
            " - Set PCTK_ANDROID_BUILD_ALL_ABIS flag to try building with\n"
            "   the list of autodetected Qt for Android:\n ${PCTK_DEFAULT_ANDROID_ABIS}"
            )
    endif()

    get_cmake_property(is_multi_config GENERATOR_IS_MULTI_CONFIG)
    if(is_multi_config)
        list(JOIN CMAKE_CONFIGURATION_TYPES "$<SEMICOLON>" escaped_configuration_types)
        set(config_arg "-DCMAKE_CONFIGURATION_TYPES=${escaped_configuration_types}")
    else()
        set(config_arg "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")
    endif()

    unset(extra_cmake_args)

    # The flag is needed when building pctk standalone tests only to avoid building
    # pctk repo itself
    if(PCTK_BUILD_STANDALONE_TESTS)
        list(APPEND extra_cmake_args "-DPCTK_BUILD_STANDALONE_TESTS=ON")
    endif()

    if(NOT PCTK_ADDITIONAL_PACKAGES_PREFIX_PATH STREQUAL "")
        list(JOIN PCTK_ADDITIONAL_PACKAGES_PREFIX_PATH "$<SEMICOLON>" escaped_packages_prefix_path)
        list(APPEND extra_cmake_args
            "-DPCTK_ADDITIONAL_PACKAGES_PREFIX_PATH=${escaped_packages_prefix_path}")
    endif()

    if(NOT PCTK_ADDITIONAL_HOST_PACKAGES_PREFIX_PATH STREQUAL "")
        list(JOIN PCTK_ADDITIONAL_HOST_PACKAGES_PREFIX_PATH "$<SEMICOLON>"
            escaped_host_packages_prefix_path)
        list(APPEND extra_cmake_args
            "-DPCTK_ADDITIONAL_HOST_PACKAGES_PREFIX_PATH=${escaped_host_packages_prefix_path}")
    endif()

    if(ANDROID_SDK_ROOT)
        list(APPEND extra_cmake_args "-DANDROID_SDK_ROOT=${ANDROID_SDK_ROOT}")
    endif()

    # ANDROID_NDK_ROOT is invented by Qt and is what the pctk toolchain file expects
    if(ANDROID_NDK_ROOT)
        list(APPEND extra_cmake_args "-DANDROID_NDK_ROOT=${ANDROID_NDK_ROOT}")

        # ANDROID_NDK is passed by Qt Creator and is also present in the android toolchain file.
    elseif(ANDROID_NDK)
        list(APPEND extra_cmake_args "-DANDROID_NDK_ROOT=${ANDROID_NDK}")
    endif()

    if(DEFINED PCTK_NO_PACKAGE_VERSION_CHECK)
        list(APPEND extra_cmake_args "-DPCTK_NO_PACKAGE_VERSION_CHECK=${PCTK_NO_PACKAGE_VERSION_CHECK}")
    endif()

    if(DEFINED PCTK_HOST_PATH_CMAKE_DIR)
        list(APPEND extra_cmake_args "-DPCTK_HOST_PATH_CMAKE_DIR=${PCTK_HOST_PATH_CMAKE_DIR}")
    endif()

    if(CMAKE_MAKE_PROGRAM)
        list(APPEND extra_cmake_args "-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}")
    endif()

    if(CMAKE_C_COMPILER_LAUNCHER)
        list(JOIN CMAKE_C_COMPILER_LAUNCHER "$<SEMICOLON>"
            compiler_launcher)
        list(APPEND extra_cmake_args
            "-DCMAKE_C_COMPILER_LAUNCHER=${compiler_launcher}")
    endif()

    if(CMAKE_CXX_COMPILER_LAUNCHER)
        list(JOIN CMAKE_CXX_COMPILER_LAUNCHER "$<SEMICOLON>"
            compiler_launcher)
        list(APPEND extra_cmake_args
            "-DCMAKE_CXX_COMPILER_LAUNCHER=${compiler_launcher}")
    endif()

    unset(user_cmake_args)
    foreach(var IN LISTS PCTK_ANDROID_MULTI_ABI_FORWARD_VARS)
        string(REPLACE ";" "$<SEMICOLON>" var_value "${${var}}")
        list(APPEND user_cmake_args "-D${var}=${var_value}")
    endforeach()

    set(missing_pctk_abi_toolchains "")
    set(previous_copy_apk_dependencies_target ${target})
    # Create external projects for each android ABI except the main one.
    list(REMOVE_ITEM android_abis "${CMAKE_ANDROID_ARCH_ABI}")
    include(ExternalProject)
    foreach(abi IN ITEMS ${android_abis})
        if(NOT "${abi}" IN_LIST PCTK_DEFAULT_ANDROID_ABIS)
            list(APPEND missing_pctk_abi_toolchains ${abi})
            list(REMOVE_ITEM android_abis "${abi}")
            continue()
        endif()

        set(android_abi_build_dir "${CMAKE_BINARY_DIR}/android_abi_builds/${abi}")
        get_property(abi_external_projects GLOBAL
            PROPERTY _pctk_internal_abi_external_projects)
        if(NOT abi_external_projects
            OR NOT "pctk_internal_android_${abi}" IN_LIST abi_external_projects)
            _pctk_internal_get_android_abi_path(pctk_abi_path ${abi})
            set(pctk_abi_toolchain_path
                "${pctk_abi_path}/lib/cmake/${PCTK_CMAKE_EXPORT_NAMESPACE}/pctk.toolchain.cmake")
            ExternalProject_Add("pctk_internal_android_${abi}"
                SOURCE_DIR "${CMAKE_SOURCE_DIR}"
                BINARY_DIR "${android_abi_build_dir}"
                CONFIGURE_COMMAND
                "${CMAKE_COMMAND}"
                "-G${CMAKE_GENERATOR}"
                "-DCMAKE_TOOLCHAIN_FILE=${pctk_abi_toolchain_path}"
                "-DPCTK_HOST_PATH=${PCTK_HOST_PATH}"
                "-DPCTK_IS_ANDROID_MULTI_ABI_EXTERNAL_PROJECT=ON"
                "-DPCTK_INTERNAL_ANDROID_MULTI_ABI_BINARY_DIR=${CMAKE_BINARY_DIR}"
                "${config_arg}"
                "${extra_cmake_args}"
                "${user_cmake_args}"
                "-B" "${android_abi_build_dir}"
                "-S" "${CMAKE_SOURCE_DIR}"
                EXCLUDE_FROM_ALL TRUE
                BUILD_COMMAND "" # avoid top-level build of external project
                )
            set_property(GLOBAL APPEND PROPERTY
                _pctk_internal_abi_external_projects "pctk_internal_android_${abi}")
        endif()
        ExternalProject_Add_Step("pctk_internal_android_${abi}"
            "${target}_build"
            DEPENDEES configure
            # TODO: Remove this when the step will depend on DEPFILE generated by
            # androiddeploypctk for the ${target}.
            ALWAYS TRUE
            EXCLUDE_FROM_MAIN TRUE
            COMMAND "${CMAKE_COMMAND}"
            "--build" "${android_abi_build_dir}"
            "--config" "$<CONFIG>"
            "--target" "${target}"
            )
        ExternalProject_Add_StepTargets("pctk_internal_android_${abi}"
            "${target}_build")
        add_dependencies(${target} "pctk_internal_android_${abi}-${target}_build")

        ExternalProject_Add_Step("pctk_internal_android_${abi}"
            "${target}_copy_apk_dependencies"
            DEPENDEES "${target}_build"
            # TODO: Remove this when the step will depend on DEPFILE generated by
            # androiddeploypctk for the ${target}.
            ALWAYS TRUE
            EXCLUDE_FROM_MAIN TRUE
            COMMAND "${CMAKE_COMMAND}"
            "--build" "${android_abi_build_dir}"
            "--config" "$<CONFIG>"
            "--target" "pctk_internal_${target}_copy_apk_dependencies"
            )
        ExternalProject_Add_StepTargets("pctk_internal_android_${abi}"
            "${target}_copy_apk_dependencies")
        set(external_project_copy_target
            "pctk_internal_android_${abi}-${target}_copy_apk_dependencies")

        # Need to build dependency chain between the
        # pctk_internal_android_${abi}-${target}_copy_apk_dependencies targets for all ABI's, to
        # prevent parallel execution of androiddeploypctk processes. We cannot use Ninja job pools
        # here because it's not possible to define job pool for the step target in ExternalProject.
        # All tricks with interlayer targets don't work, because we only can bind interlayer target
        # to the job pool, but its dependencies can still be built in parallel.
        add_dependencies(${previous_copy_apk_dependencies_target}
            "${external_project_copy_target}")
        set(previous_copy_apk_dependencies_target "${external_project_copy_target}")
    endforeach()

    if(missing_pctk_abi_toolchains)
        list(JOIN missing_pctk_abi_toolchains ", " missing_pctk_abi_toolchains_string)
        message(FATAL_ERROR "Cannot find toolchain files for the manually specified Android"
            " ABIs: ${missing_pctk_abi_toolchains_string}"
            "\nNote that you also may manually specify the path to the required Qt for"
            " Android ABI using PCTK_PATH_ANDROID_ABI_<abi> CMake variable.\n")
    endif()

    list(JOIN android_abis ", " android_abis_string)
    if(android_abis_string)
        set(android_abis_string "${CMAKE_ANDROID_ARCH_ABI} (default), ${android_abis_string}")
    else()
        set(android_abis_string "${CMAKE_ANDROID_ARCH_ABI} (default)")
    endif()
    if(NOT PCTK_NO_ANDROID_ABI_STATUS_MESSAGE)
        message(STATUS "Configuring '${target}' for the following Android ABIs:"
            " ${android_abis_string}")
    endif()
    set_target_properties(${target} PROPERTIES _pctk_android_abis "${android_abis}")
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Generate the deployment settings json file for a cmake target.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_android_generate_deployment_settings target)
    # Information extracted from mkspecs/features/android/android_deployment_settings.prf
    if(NOT TARGET ${target})
        message(FATAL_ERROR "${target} is not a cmake target")
    endif()

    # When parsing JSON file format backslashes and follow up symbols are regarded as special
    # characters. This puts Windows path format into a trouble.
    # _pctk_internal_android_format_deployment_paths converts sensitive paths to the CMake format
    # that is supported by JSON as well. The function should be called as many times as
    # pctk6_android_generate_deployment_settings, because users may change properties that contain
    # paths in between the calls.
    _pctk_internal_android_format_deployment_paths(${target})

    # Avoid calling the function body twice because of 'file(GENERATE'.
    get_target_property(is_called ${target} _pctk_is_android_generate_deployment_settings_called)
    if(is_called)
        return()
    endif()
    set_target_properties(${target} PROPERTIES
        _pctk_is_android_generate_deployment_settings_called TRUE
        )

    get_target_property(target_type ${target} TYPE)

    if(NOT "${target_type}" STREQUAL "MODULE_LIBRARY")
        message(SEND_ERROR "PCTK_ANDROID_GENERATE_DEPLOYMENT_SETTINGS only works on Module targets")
        return()
    endif()

    get_target_property(target_source_dir ${target} SOURCE_DIR)
    get_target_property(target_binary_dir ${target} BINARY_DIR)
    get_target_property(target_output_name ${target} OUTPUT_NAME)
    if(NOT target_output_name)
        set(target_output_name ${target})
    endif()

    # QtCreator requires the file name of deployment settings has no config related suffixes
    # to run androiddeploypctk correctly. If we use multi-config generator for the first config
    # in a list avoid adding any configuration-specific suffixes.
    get_cmake_property(is_multi_config GENERATOR_IS_MULTI_CONFIG)
    if(is_multi_config)
        list(GET CMAKE_CONFIGURATION_TYPES 0 first_config_type)
        set(config_suffix "$<$<NOT:$<CONFIG:${first_config_type}>>:-$<CONFIG>>")
    endif()
    set(deploy_file
        "${target_binary_dir}/android-${target_output_name}-deployment-settings${config_suffix}.json")

    set(file_contents "{\n")
    # content begin
    string(APPEND file_contents
        "   \"description\": \"This file is generated by cmake to be read by androiddeploypctk and should not be modified by hand.\",\n")

    # Host Qt Android install path
    if(NOT PCTK_BUILDING_PCTK OR PCTK_STANDALONE_TEST_PATH)
        set(pctk_path "${PCTK_INSTALL_PREFIX}")
        set(android_plugin_dir_path "${pctk_path}/${PCTK6_INSTALL_PLUGINS}/platforms")
        set(glob_expression "${android_plugin_dir_path}/*pctkforandroid*${CMAKE_ANDROID_ARCH_ABI}.so")
        file(GLOB plugin_dir_files LIST_DIRECTORIES FALSE "${glob_expression}")
        if(NOT plugin_dir_files)
            message(SEND_ERROR
                "Detected Qt installation does not contain pctkforandroid_${CMAKE_ANDROID_ARCH_ABI}.so in the following dir:\n"
                "${android_plugin_dir_path}\n"
                "This is most likely due to the installation not being a Qt for Android build. "
                "Please recheck your build configuration.")
            return()
        else()
            list(GET plugin_dir_files 0 android_platform_plugin_path)
            message(STATUS "Found android platform plugin at: ${android_platform_plugin_path}")
        endif()
    endif()

    set(abi_records "")
    get_target_property(pctk_android_abis ${target} _pctk_android_abis)
    if(NOT pctk_android_abis)
        set(pctk_android_abis "")
    endif()
    foreach(abi IN LISTS pctk_android_abis)
        _pctk_internal_get_android_abi_path(pctk_abi_path ${abi})
        file(TO_CMAKE_PATH "${pctk_abi_path}" pctk_android_install_dir_native)
        list(APPEND abi_records "\"${abi}\": \"${pctk_android_install_dir_native}\"")
    endforeach()

    # Required to build unit tests in developer build
    if(PCTK_BUILD_INTERNALS_RELOCATABLE_INSTALL_PREFIX)
        set(pctk_android_install_dir "${PCTK_BUILD_INTERNALS_RELOCATABLE_INSTALL_PREFIX}")
    else()
        set(pctk_android_install_dir "${PCTK_INSTALL_PREFIX}")
    endif()
    file(TO_CMAKE_PATH "${pctk_android_install_dir}" pctk_android_install_dir_native)
    list(APPEND abi_records "\"${CMAKE_ANDROID_ARCH_ABI}\": \"${pctk_android_install_dir_native}\"")

    list(JOIN abi_records "," pctk_android_install_dir_records)
    set(pctk_android_install_dir_records "{${pctk_android_install_dir_records}}")

    string(APPEND file_contents
        "   \"pctk\": ${pctk_android_install_dir_records},\n")

    # Android SDK path
    file(TO_CMAKE_PATH "${ANDROID_SDK_ROOT}" android_sdk_root_native)
    string(APPEND file_contents
        "   \"sdk\": \"${android_sdk_root_native}\",\n")

    # Android SDK Build Tools Revision
    _pctk_internal_android_get_sdk_build_tools_revision(android_sdk_build_tools)
    set(android_sdk_build_tools_genex "")
    string(APPEND android_sdk_build_tools_genex
        "$<IF:$<BOOL:$<TARGET_PROPERTY:${target},PCTK_ANDROID_SDK_BUILD_TOOLS_REVISION>>,"
        "$<TARGET_PROPERTY:${target},PCTK_ANDROID_SDK_BUILD_TOOLS_REVISION>,"
        "${android_sdk_build_tools}"
        ">"
        )
    string(APPEND file_contents
        "   \"sdkBuildToolsRevision\": \"${android_sdk_build_tools_genex}\",\n")

    # Android NDK
    file(TO_CMAKE_PATH "${CMAKE_ANDROID_NDK}" android_ndk_root_native)
    string(APPEND file_contents
        "   \"ndk\": \"${android_ndk_root_native}\",\n")

    # Setup LLVM toolchain
    string(APPEND file_contents
        "   \"toolchain-prefix\": \"llvm\",\n")
    string(APPEND file_contents
        "   \"tool-prefix\": \"llvm\",\n")
    string(APPEND file_contents
        "   \"useLLVM\": true,\n")

    # NDK Toolchain Version
    string(APPEND file_contents
        "   \"toolchain-version\": \"${CMAKE_ANDROID_NDK_TOOLCHAIN_VERSION}\",\n")

    # NDK Host
    string(APPEND file_contents
        "   \"ndk-host\": \"${ANDROID_NDK_HOST_SYSTEM_NAME}\",\n")

    set(architecture_record_list "")
    foreach(abi IN LISTS pctk_android_abis CMAKE_ANDROID_ARCH_ABI)
        if(abi STREQUAL "x86")
            set(arch_value "i686-linux-android")
        elseif(abi STREQUAL "x86_64")
            set(arch_value "x86_64-linux-android")
        elseif(abi STREQUAL "arm64-v8a")
            set(arch_value "aarch64-linux-android")
        elseif(abi)
            set(arch_value "arm-linux-androideabi")
        endif()
        list(APPEND architecture_record_list "\"${abi}\":\"${arch_value}\"")
    endforeach()

    list(JOIN architecture_record_list "," architecture_records)
    # Architecture
    string(APPEND file_contents
        "   \"architectures\": { ${architecture_records} },\n")

    # deployment dependencies
    _pctk_internal_add_android_deployment_multi_value_property(file_contents "dependencies"
        ${target} "PCTK_ANDROID_DEPLOYMENT_DEPENDENCIES")

    # Extra plugins
    _pctk_internal_add_android_deployment_multi_value_property(file_contents "android-extra-plugins"
        ${target} "_pctk_android_native_extra_plugins")

    # Extra libs
    _pctk_internal_add_android_deployment_multi_value_property(file_contents "android-extra-libs"
        ${target} "_pctk_android_native_extra_libs")

    # Alternative path to Qt libraries on target device
    _pctk_internal_add_android_deployment_property(file_contents "android-system-libs-prefix"
        ${target} "PCTK_ANDROID_SYSTEM_LIBS_PREFIX")

    # package source dir
    _pctk_internal_add_android_deployment_property(file_contents "android-package-source-directory"
        ${target} "_pctk_android_native_package_source_dir")

    # version code
    _pctk_internal_add_android_deployment_property(file_contents "android-version-code"
        ${target} "PCTK_ANDROID_VERSION_CODE")

    # version name
    _pctk_internal_add_android_deployment_property(file_contents "android-version-name"
        ${target} "PCTK_ANDROID_VERSION_NAME")

    # minimum SDK version
    _pctk_internal_add_android_deployment_property(file_contents "android-min-sdk-version"
        ${target} "PCTK_ANDROID_MIN_SDK_VERSION")

    # target SDK version
    _pctk_internal_add_android_deployment_property(file_contents "android-target-sdk-version"
        ${target} "PCTK_ANDROID_TARGET_SDK_VERSION")

    # should Qt shared libs be excluded from deployment
    _pctk_internal_add_android_deployment_property(file_contents "android-no-deploy-pctk-libs"
        ${target} "PCTK_ANDROID_NO_DEPLOY_PCTK_LIBS")

    # App binary
    string(APPEND file_contents
        "   \"application-binary\": \"${target_output_name}\",\n")

    # App command-line arguments
    if(PCTK_ANDROID_APPLICATION_ARGUMENTS)
        string(APPEND file_contents
            "   \"android-application-arguments\": \"${PCTK_ANDROID_APPLICATION_ARGUMENTS}\",\n")
    endif()

    if(COMMAND _pctk_internal_generate_android_qml_deployment_settings)
        _pctk_internal_generate_android_qml_deployment_settings(file_contents ${target})
    else()
        string(APPEND file_contents
            "   \"qml-skip-import-scanning\": true,\n")
    endif()

    # Override rcc binary path
    _pctk_internal_add_tool_to_android_deployment_settings(file_contents rcc "rcc-binary" "${target}")

    # Extra prefix paths
    foreach(prefix IN LISTS CMAKE_FIND_ROOT_PATH)
        if(NOT "${prefix}" STREQUAL "${pctk_android_install_dir_native}"
            AND NOT "${prefix}" STREQUAL "${android_ndk_root_native}")
            file(TO_CMAKE_PATH "${prefix}" prefix)
            list(APPEND extra_prefix_list "\"${prefix}\"")
        endif()
    endforeach()
    string(REPLACE ";" "," extra_prefix_list "${extra_prefix_list}")
    string(APPEND file_contents
        "   \"extraPrefixDirs\" : [ ${extra_prefix_list} ],\n")

    # Create an empty target for the cases when we need to generate deployment setting but
    # pctk_finalize_project is never called.
    if(NOT TARGET _pctk_internal_apk_dependencies AND NOT PCTK_NO_COLLECT_BUILD_TREE_APK_DEPS)
        add_custom_target(_pctk_internal_apk_dependencies)
    endif()

    # Extra library paths that could be used as a dependency lookup path by androiddeploypctk.
    #
    # Unlike 'extraPrefixDirs', the 'extraLibraryDirs' key doesn't expect the 'lib' subfolder
    # when looking for dependencies.
    # TODO: add a public target property accessible from user space
    _pctk_internal_add_android_deployment_list_property(file_contents "extraLibraryDirs"
        ${target} "_pctk_android_extra_library_dirs"
        _pctk_internal_apk_dependencies "_pctk_android_extra_library_dirs"
        )

    if(PCTK_FEATURE_zstd)
        set(is_zstd_enabled "true")
    else()
        set(is_zstd_enabled "false")
    endif()
    string(APPEND file_contents
        "   \"zstdCompression\": ${is_zstd_enabled},\n")

    # Last item in json file

    # base location of stdlibc++, will be suffixed by androiddeploy pctk
    # Sysroot is set by Android toolchain file and is composed of ANDROID_TOOLCHAIN_ROOT.
    set(android_ndk_stdlib_base_path "${CMAKE_SYSROOT}/usr/lib/")
    string(APPEND file_contents
        "   \"stdcpp-path\": \"${android_ndk_stdlib_base_path}\"\n")

    # content end
    string(APPEND file_contents "}\n")

    file(GENERATE OUTPUT ${deploy_file} CONTENT ${file_contents})

    set_target_properties(${target}
        PROPERTIES
        PCTK_ANDROID_DEPLOYMENT_SETTINGS_FILE ${deploy_file}
        )
endfunction()


# Add custom target to package the APK
function(pctk_android_add_apk_target target)
    # Avoid calling pctk6_android_add_apk_target twice
    get_property(apk_targets GLOBAL PROPERTY _pctk_apk_targets)
    if("${target}" IN_LIST apk_targets)
        return()
    endif()

    get_target_property(deployment_file ${target} PCTK_ANDROID_DEPLOYMENT_SETTINGS_FILE)
    if(NOT deployment_file)
        message(FATAL_ERROR "Target ${target} is not a valid android executable target\n")
    endif()
    # Use genex to get path to the deployment settings, the above check only to confirm that
    # pctk6_android_add_apk_target is called on an android executable target.
    set(deployment_file "$<TARGET_PROPERTY:${target},PCTK_ANDROID_DEPLOYMENT_SETTINGS_FILE>")

    # Make global apk and aab targets depend on the current apk target.
    if(TARGET aab)
        add_dependencies(aab ${target}_make_aab)
    endif()
    if(TARGET apk)
        add_dependencies(apk ${target}_make_apk)
        _pctk_internal_create_global_apk_all_target_if_needed()
    endif()

    set(deployment_tool "${PCTK_HOST_PATH}/${PCTK6_HOST_INFO_BINDIR}/androiddeploypctk")
    # No need to use genex for the BINARY_DIR since it's read-only.
    get_target_property(target_binary_dir ${target} BINARY_DIR)
    set(apk_final_dir "${target_binary_dir}/android-build")
    set(apk_file_name "${target}.apk")
    set(dep_file_name "${target}.d")
    set(apk_final_file_path "${apk_final_dir}/${apk_file_name}")
    set(dep_file_path "${apk_final_dir}/${dep_file_name}")
    set(target_file_copy_relative_path
        "libs/${CMAKE_ANDROID_ARCH_ABI}/$<TARGET_FILE_NAME:${target}>")

    set(extra_deps "")

    # Plugins still might be added after creating the deployment targets.
    if(NOT TARGET pctk_internal_plugins)
        add_custom_target(pctk_internal_plugins)
    endif()
    # Before running androiddeploypctk, we need to make sure all plugins are built.
    list(APPEND extra_deps pctk_internal_plugins)

    # This target is used by Qt Creator's Android support and by the ${target}_make_apk target
    # in case DEPFILEs are not supported.
    # Also the target is used to copy the library that belongs to ${target} when building multi-abi
    # apk to the abi-specific directory.
    _pctk_internal_copy_file_if_different_command(copy_command
        "$<TARGET_FILE:${target}>"
        "${apk_final_dir}/${target_file_copy_relative_path}"
        )
    add_custom_target(${target}_prepare_apk_dir ALL
        DEPENDS ${target} ${extra_deps}
        COMMAND ${copy_command}
        COMMENT "Copying ${target} binary to apk folder"
        )

    set(sign_apk "")
    if(PCTK_ANDROID_SIGN_APK)
        set(sign_apk "--sign")
    endif()
    set(sign_aab "")
    if(PCTK_ANDROID_SIGN_AAB)
        set(sign_aab "--sign")
    endif()

    set(extra_args "")
    if(PCTK_INTERNAL_NO_ANDROID_RCC_BUNDLE_CLEANUP)
        list(APPEND extra_args "--no-rcc-bundle-cleanup")
    endif()
    if(PCTK_ENABLE_VERBOSE_DEPLOYMENT)
        list(APPEND extra_args "--verbose")
    endif()

    _pctk_internal_check_depfile_support(has_depfile_support)

    if(has_depfile_support)
        cmake_policy(PUSH)
        if(POLICY CMP0116)
            # Without explicitly setting this policy to NEW, we get a warning
            # even though we ensure there's actually no problem here.
            # See https://gitlab.kitware.com/cmake/cmake/-/issues/21959
            cmake_policy(SET CMP0116 NEW)
            set(relative_to_dir ${CMAKE_CURRENT_BINARY_DIR})
        else()
            set(relative_to_dir ${CMAKE_BINARY_DIR})
        endif()

        # Add custom command that creates the apk and triggers rebuild if files listed in
        # ${dep_file_path} are changed.
        add_custom_command(OUTPUT "${apk_final_file_path}"
            COMMAND ${CMAKE_COMMAND}
            -E copy "$<TARGET_FILE:${target}>"
            "${apk_final_dir}/${target_file_copy_relative_path}"
            COMMAND "${deployment_tool}"
            --input "${deployment_file}"
            --output "${apk_final_dir}"
            --apk "${apk_final_file_path}"
            --depfile "${dep_file_path}"
            --builddir "${relative_to_dir}"
            ${extra_args}
            ${sign_apk}
            COMMENT "Creating APK for ${target}"
            DEPENDS "${target}" "${deployment_file}" ${extra_deps}
            DEPFILE "${dep_file_path}"
            VERBATIM
            )
        cmake_policy(POP)

        # Create a ${target}_make_apk target to trigger the apk build.
        add_custom_target(${target}_make_apk DEPENDS "${apk_final_file_path}")
    else()
        add_custom_target(${target}_make_apk
            DEPENDS ${target}_prepare_apk_dir
            COMMAND ${deployment_tool}
            --input ${deployment_file}
            --output ${apk_final_dir}
            --apk ${apk_final_file_path}
            ${extra_args}
            ${sign_apk}
            COMMENT "Creating APK for ${target}"
            VERBATIM
            )
    endif()

    # Add target triggering AAB creation. Since the _make_aab target is not added to the ALL
    # set, we may avoid dependency check for it and admit that the target is "always out
    # of date".
    add_custom_target(${target}_make_aab
        DEPENDS ${target}_prepare_apk_dir
        COMMAND ${deployment_tool}
        --input ${deployment_file}
        --output ${apk_final_dir}
        --apk ${apk_final_file_path}
        --aab
        ${sign_aab}
        ${extra_args}
        COMMENT "Creating AAB for ${target}"
        )

    if(PCTK_IS_ANDROID_MULTI_ABI_EXTERNAL_PROJECT)
        # When building per-ABI external projects we only need to copy ABI-specific libraries and
        # resources to the "main" ABI android build folder.

        if("${PCTK_INTERNAL_ANDROID_MULTI_ABI_BINARY_DIR}" STREQUAL "")
            message(FATAL_ERROR "PCTK_INTERNAL_ANDROID_MULTI_ABI_BINARY_DIR is not set when building"
                " ABI specific external project. This should not happen and might mean an issue"
                " in PCTK. Please report a bug with CMake traces attached.")
        endif()
        # Assume that external project mirrors build structure of the top-level ABI project and
        # replace the build root when specifying the output directory of androiddeploypctk.
        file(RELATIVE_PATH androiddeploypctk_output_path "${CMAKE_BINARY_DIR}" "${apk_final_dir}")
        set(androiddeploypctk_output_path
            "${PCTK_INTERNAL_ANDROID_MULTI_ABI_BINARY_DIR}/${androiddeploypctk_output_path}")
        _pctk_internal_copy_file_if_different_command(copy_command
            "$<TARGET_FILE:${target}>"
            "${androiddeploypctk_output_path}/${target_file_copy_relative_path}"
            )
        if(has_depfile_support)
            set(deploy_android_deps_dir "${apk_final_dir}/${target}_deploy_android")
            set(timestamp_file "${deploy_android_deps_dir}/timestamp")
            set(dep_file "${deploy_android_deps_dir}/${target}.d")
            add_custom_command(OUTPUT "${timestamp_file}"
                DEPENDS ${target} ${extra_deps}
                COMMAND ${CMAKE_COMMAND} -E make_directory "${deploy_android_deps_dir}"
                COMMAND ${CMAKE_COMMAND} -E touch "${timestamp_file}"
                COMMAND ${copy_command}
                COMMAND ${deployment_tool}
                --input ${deployment_file}
                --output ${androiddeploypctk_output_path}
                --copy-dependencies-only
                ${extra_args}
                --depfile "${dep_file}"
                --builddir "${CMAKE_BINARY_DIR}"
                COMMENT "Resolving ${CMAKE_ANDROID_ARCH_ABI} dependencies for the ${target} APK"
                DEPFILE "${dep_file}"
                VERBATIM
                )
            add_custom_target(pctk_internal_${target}_copy_apk_dependencies
                DEPENDS "${timestamp_file}")
        else()
            add_custom_target(pctk_internal_${target}_copy_apk_dependencies
                DEPENDS ${target} ${extra_deps}
                COMMAND ${copy_command}
                COMMAND ${deployment_tool}
                --input ${deployment_file}
                --output ${androiddeploypctk_output_path}
                --copy-dependencies-only
                ${extra_args}
                COMMENT "Resolving ${CMAKE_ANDROID_ARCH_ABI} dependencies for the ${target} APK"
                )
        endif()
    endif()

    set_property(GLOBAL APPEND PROPERTY _pctk_apk_targets ${target})
    _pctk_internal_collect_apk_dependencies_defer()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# The wrapper function that contains routines that need to be called to produce a valid Android package for the
# executable 'target'. The function is added to the finalizer list of the Core module and is executed implicitly when
# configuring user projects.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_android_executable_finalizer target)
    pctk_internal_configure_android_multiabi_target("${target}")
    pctk_android_generate_deployment_settings("${target}")
    pctk_android_add_apk_target("${target}")
endfunction()
