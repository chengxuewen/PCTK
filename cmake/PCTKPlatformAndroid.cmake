
# Returns test execution arguments for Android targets
function(pctk_internal_android_test_arguments target out_test_runner out_test_arguments)
    set(${out_test_runner} "${PCTK_HOST_PATH}/${PCTK${PROJECT_VERSION_MAJOR}_HOST_INFO_BINDIR}/androidtestrunner" PARENT_SCOPE)
    set(deployment_tool "${PCTK_HOST_PATH}/${PCTK${PROJECT_VERSION_MAJOR}_HOST_INFO_BINDIR}/androiddeploypctk")

    get_target_property(deployment_file ${target} PCTK_ANDROID_DEPLOYMENT_SETTINGS_FILE)
    if(NOT deployment_file)
        message(FATAL_ERROR "Target ${target} is not a valid android executable target\n")
    endif()

    set(target_binary_dir "$<TARGET_PROPERTY:${target},BINARY_DIR>")
    set(apk_dir "${target_binary_dir}/android-build")

    set(${out_test_arguments}
        "--path" "${apk_dir}"
        "--adb" "${ANDROID_SDK_ROOT}/platform-tools/adb"
        "--skip-install-root"
        "--make" "${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target ${target}_make_apk"
        "--apk" "${apk_dir}/${target}.apk"
        "--verbose"
        PARENT_SCOPE
        )
endfunction()