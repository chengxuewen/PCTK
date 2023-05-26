
#-----------------------------------------------------------------------------------------------------------------------
# WARNING must keep in sync with wasm-emscripten/qmake.conf!
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_setup_wasm_target_properties wasmTarget)

    target_link_options("${wasmTarget}" INTERFACE
        "SHELL:-s ERROR_ON_UNDEFINED_SYMBOLS=1"
        "SHELL:-s MAX_WEBGL_VERSION=2"
        "SHELL:-s FETCH=1"
        "SHELL:-s WASM_BIGINT=1")

    target_link_libraries("${wasmTarget}" INTERFACE embind)

    # Enable MODULARIZE and set EXPORT_NAME, which makes it possible to
    # create application instances using a global constructor function,
    # e.g. let app_instance = await createPCTKAppInstance().
    # (as opposed to MODULARIZE=0, where Emscripten creates a global app
    # instance object at Javascript eval time)
    target_link_options("${wasmTarget}" INTERFACE
        "SHELL:-s MODULARIZE=1"
        "SHELL:-s EXPORT_NAME=createPCTKAppInstance")

    #simd
    if(PCTK_FEATURE_sse2)
        target_compile_options("${wasmTarget}" INTERFACE -O2 -msimd128 -msse -msse2)
    endif()

    set(disable_exceptions_catching 1)
    if(PCTK_FEATURE_exceptions)
        set(disable_exceptions_catching 0)
    endif()
    target_link_options("${wasmTarget}" INTERFACE "SHELL:-s DISABLE_EXCEPTION_CATCHING=${disable_exceptions_catching}")

    if(PCTK_FEATURE_THREAD)
        target_compile_options("${wasmTarget}" INTERFACE "SHELL:-pthread")
        target_link_options("${wasmTarget}" INTERFACE "SHELL:-pthread")
    else()
        target_link_options("${wasmTarget}" INTERFACE "SHELL:-s ALLOW_MEMORY_GROWTH=1")
    endif()

    # debug add_compile_options
    if("PCTK_WASM_SOURCE_MAP=1" IN_LIST PCTK_QMAKE_DEVICE_OPTIONS)
        set(WASM_SOURCE_MAP_BASE "http://localhost:8000/")

        if(DEFINED PCTK_WASM_SOURCE_MAP_BASE)
            set(WASM_SOURCE_MAP_BASE "${PCTK_WASM_SOURCE_MAP_BASE}")
        endif()

        # Pass --source-map-base on the linker line. This informs the
        # browser where to find the source files when debugging.
        # -g4 to make source maps for debugging
        target_link_options("${wasmTarget}" INTERFACE "-gsource-map" "--source-map-base" "${WASM_SOURCE_MAP_BASE}")

    endif()

    # a few good defaults to make console more verbose while debugging
    target_link_options("${wasmTarget}" INTERFACE $<$<CONFIG:Debug>:
        "SHELL:-s DEMANGLE_SUPPORT=1"
        "SHELL:-s GL_DEBUG=1"
        --profiling-funcs>)

    # target_link_options("${wasmTarget}" INTERFACE "SHELL:-s LIBRARY_DEBUG=1") # print out library calls, verbose
    # target_link_options("${wasmTarget}" INTERFACE "SHELL:-s SYSCALL_DEBUG=1") # print out sys calls, verbose
    # target_link_options("${wasmTarget}" INTERFACE "SHELL:-s FS_LOG=1") # print out filesystem ops, verbose
    # target_link_options("${wasmTarget}" INTERFACE "SHELL:-s SOCKET_DEBUG") # print out socket,network data transfer

    if("PCTK_EMSCRIPTEN_ASYNCIFY=1" IN_LIST PCTK_QMAKE_DEVICE_OPTIONS)

        # Emscripten recommends building with optimizations when using asyncify
        # in order to reduce wasm file size, and may also generate broken wasm
        # (with "wasm validation error: too many locals" type errors) if optimizations
        # are omitted. Enable optimizations also for debug builds.
        set(PCTK_CFLAGS_OPTIMIZE_DEBUG "-Os" CACHE STRING INTERNAL FORCE)
        set(PCTK_FEATURE_optimize_debug ON CACHE BOOL INTERNAL FORCE)

        target_link_options("${wasmTarget}" INTERFACE "SHELL:-s ASYNCIFY" "-Os")
        target_compile_definitions("${wasmTarget}" INTERFACE PCTK_HAVE_EMSCRIPTEN_ASYNCIFY)
    endif()

    #  Set ASYNCIFY_IMPORTS unconditionally in order to support enabling asyncify at link time.
    target_link_options("${wasmTarget}" INTERFACE "SHELL:-sASYNCIFY_IMPORTS=pctk_asyncify_suspend_js,pctk_asyncify_resume_js")

endfunction()

#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_wasm_add_finalizers target)
    pctk_add_list_file_finalizer(_pctk_internal_add_wasm_extra_exported_methods ${target})
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Copy in PCTK HTML/JS launch files for apps.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_wasm_add_target_helpers target)

    _pctk_test_emscripten_version()
    get_target_property(targetType "${target}" TYPE)
    if("${targetType}" STREQUAL "EXECUTABLE")

        if(PCTK_INSTALL_PREFIX)
            set(WASM_BUILD_DIR "${PCTK_INSTALL_PREFIX}")
        elseif(PCTK_BUILD_DIR)
            set(WASM_BUILD_DIR "${PCTK_BUILD_DIR}")
        endif()

        get_target_property(output_name ${target} OUTPUT_NAME)
        if(output_name)
            set(_target_output_name "${output_name}")
        else()
            set(_target_output_name "${target}")
        endif()

        set(APPNAME ${_target_output_name})

        get_target_property(target_output_directory ${target} RUNTIME_OUTPUT_DIRECTORY)

        if(target_output_directory)
            set(_target_directory "${target_output_directory}")
        else()
            set(_target_directory "${CMAKE_CURRENT_BINARY_DIR}")
        endif()

        configure_file("${WASM_BUILD_DIR}/plugins/platforms/wasm_shell.html"
            "${_target_directory}/${_target_output_name}.html")
        configure_file("${WASM_BUILD_DIR}/plugins/platforms/pctkloader.js"
            ${_target_directory}/pctkloader.js COPYONLY)
        configure_file("${WASM_BUILD_DIR}/plugins/platforms/pctklogo.svg"
            ${_target_directory}/pctklogo.svg COPYONLY)

        if(PCTK_FEATURE_THREAD)
            set(POOL_SIZE 4)
            get_target_property(_tmp_poolSize "${target}" PCTK_WASM_PTHREAD_POOL_SIZE)
            if(_tmp_poolSize)
                set(POOL_SIZE ${_tmp_poolSize})
            elseif(DEFINED PCTK_WASM_PTHREAD_POOL_SIZE)
                set(POOL_SIZE ${PCTK_WASM_PTHREAD_POOL_SIZE})
            endif()
            target_link_options("${target}" PRIVATE "SHELL:-s PTHREAD_POOL_SIZE=${POOL_SIZE}")
            message(DEBUG "Setting PTHREAD_POOL_SIZE to ${POOL_SIZE} for ${target}")
        endif()

        # Hardcode wasm memory size.
        get_target_property(_tmp_initialMemory "${target}" PCTK_WASM_INITIAL_MEMORY)
        if(_tmp_initialMemory)
            set(PCTK_WASM_INITIAL_MEMORY "${_tmp_initialMemory}")
        elseif(NOT DEFINED PCTK_WASM_INITIAL_MEMORY)
            if(PCTK_FEATURE_THREAD)
                # Pthreads and ALLOW_MEMORY_GROWTH can cause javascript wasm memory access to
                # be slow and having to update HEAP* views. Instead, we specify the memory size
                # at build time. Further, browsers limit the maximum initial memory size to 1GB.
                # https://github.com/WebAssembly/design/issues/1271
                set(PCTK_WASM_INITIAL_MEMORY "1GB")
            else()
                # emscripten default is 16MB, we need slightly more sometimes
                set(PCTK_WASM_INITIAL_MEMORY "50MB")
            endif()
        endif()

        if(DEFINED PCTK_WASM_INITIAL_MEMORY)
            # PCTK_WASM_INITIAL_MEMORY must be a multiple of 65536
            target_link_options("${target}"
                PRIVATE "SHELL:-s INITIAL_MEMORY=${PCTK_WASM_INITIAL_MEMORY}")
            message(DEBUG "-- Setting INITIAL_MEMORY to ${PCTK_WASM_INITIAL_MEMORY} for ${target}")
        endif()

    endif()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
# Assuming EMSDK == /path/emsdk
#
# Then we expect /path/emsdk/.emscripten file to contain the following line
#   EMSCRIPTEN_ROOT = emsdk_path + '/upstream/emscripten'
#
# then we set out_var to '/upstream/emscripten', so it's not a full path
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_get_emroot_path_suffix_from_emsdk_env out_var)
    # Query EMSCRIPTEN_ROOT path.
    file(READ "$ENV{EMSDK}/.emscripten" ver)
    string(REGEX MATCH "EMSCRIPTEN_ROOT.*$" EMROOT "${ver}")
    string(REGEX MATCH "'([^' ]*)'" EMROOT2 "${EMROOT}")
    string(REPLACE "'" "" EMROOT_PATH "${EMROOT2}")

    set(${out_var} "${EMROOT_PATH}" PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_get_emcc_recommended_version out_var)
    # This version of PCTK needs this version of emscripten.
    set(PCTK_EMCC_RECOMMENDED_VERSION "3.1.14")
    set(${out_var} "${PCTK_EMCC_RECOMMENDED_VERSION}" PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_query_emsdk_version emroot_path is_fatal out_var)
    # get emscripten version
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
        set(EXECUTE_COMMANDPATH "$ENV{EMSDK}/${emroot_path}/emcc.bat")
    else()
        set(EXECUTE_COMMANDPATH "$ENV{EMSDK}/${emroot_path}/emcc")
    endif()

    file(TO_NATIVE_PATH "${EXECUTE_COMMANDPATH}" EXECUTE_COMMAND)
    execute_process(COMMAND ${EXECUTE_COMMAND} --version
        OUTPUT_VARIABLE emOutput
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE emrun_error
        RESULT_VARIABLE result)
    message(DEBUG "emcc --version output: ${emOutput}")

    if(NOT emOutput)
        if(is_fatal)
            message(FATAL_ERROR
                "Couldn't determine Emscripten version from running ${EXECUTE_COMMAND} --version. "
                "Error: ${emrun_error}")
        endif()
        set(${out_var} "" PARENT_SCOPE)
    else()
        string(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+" CMAKE_EMSDK_REGEX_VERSION "${emOutput}")
        set(${out_var} "${CMAKE_EMSDK_REGEX_VERSION}" PARENT_SCOPE)
    endif()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_get_build_emsdk_version out_var)
    if(PCTK_INSTALL_PREFIX)
        set(WASM_BUILD_DIR "${PCTK_INSTALL_PREFIX}")
    elseif(PCTK_BUILD_DIR)
        set(WASM_BUILD_DIR "${PCTK_BUILD_DIR}")
    endif()
    if(EXISTS "${WASM_BUILD_DIR}/src/corelib/global/qconfig.h")
        file(READ "${WASM_BUILD_DIR}/src/corelib/global/qconfig.h" ver)
    else()
        file(READ "${WASM_BUILD_DIR}/include/PCTKCore/qconfig.h" ver)
    endif()
    string(REGEX MATCH "#define PCTK_EMCC_VERSION.\"[0-9]+\\.[0-9]+\\.[0-9]+\"" emOutput ${ver})
    string(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+" build_emcc_version "${emOutput}")
    set(${out_var} "${build_emcc_version}" PARENT_SCOPE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_test_emscripten_version)
    pctk_internal_get_emcc_recommended_version(_recommended_emver)
    pctk_internal_get_emroot_path_suffix_from_emsdk_env(emroot_path)
    pctk_internal_query_emsdk_version("${emroot_path}" TRUE current_emsdk_ver)
    pctk_internal_get_build_emsdk_version(pctk_build_emcc_version)

    if(NOT "${pctk_build_emcc_version}" STREQUAL "${current_emsdk_ver}")
        message("PCTK Wasm built with Emscripten version: ${pctk_build_emcc_version}")
        message("You are using Emscripten version: ${current_emsdk_ver}")
        message("The recommended version of Emscripten for this PCTK is: ${_recommended_emver}")
        message("This may not work correctly")
    endif()
endfunction()


