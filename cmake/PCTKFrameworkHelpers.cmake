

#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
macro(pctk_find_apple_system_frameworks)
    if(APPLE)
        pctk_internal_find_apple_system_framework(FWAppKit AppKit)
        pctk_internal_find_apple_system_framework(FWAssetsLibrary AssetsLibrary)
        pctk_internal_find_apple_system_framework(FWAudioToolbox AudioToolbox)
        pctk_internal_find_apple_system_framework(FWApplicationServices ApplicationServices)
        pctk_internal_find_apple_system_framework(FWCarbon Carbon)
        pctk_internal_find_apple_system_framework(FWCoreFoundation CoreFoundation)
        pctk_internal_find_apple_system_framework(FWCoreServices CoreServices)
        pctk_internal_find_apple_system_framework(FWCoreGraphics CoreGraphics)
        pctk_internal_find_apple_system_framework(FWCoreText CoreText)
        pctk_internal_find_apple_system_framework(FWCoreVideo CoreVideo)
        pctk_internal_find_apple_system_framework(FWCryptoTokenKit CryptoTokenKit)
        pctk_internal_find_apple_system_framework(FWDiskArbitration DiskArbitration)
        pctk_internal_find_apple_system_framework(FWFoundation Foundation)
        pctk_internal_find_apple_system_framework(FWIOBluetooth IOBluetooth)
        pctk_internal_find_apple_system_framework(FWIOKit IOKit)
        pctk_internal_find_apple_system_framework(FWIOSurface IOSurface)
        pctk_internal_find_apple_system_framework(FWImageIO ImageIO)
        pctk_internal_find_apple_system_framework(FWMetal Metal)
        pctk_internal_find_apple_system_framework(FWMobileCoreServices MobileCoreServices)
        pctk_internal_find_apple_system_framework(FWQuartzCore QuartzCore)
        pctk_internal_find_apple_system_framework(FWSecurity Security)
        pctk_internal_find_apple_system_framework(FWSystemConfiguration SystemConfiguration)
        pctk_internal_find_apple_system_framework(FWUIKit UIKit)
        pctk_internal_find_apple_system_framework(FWCoreLocation CoreLocation)
        pctk_internal_find_apple_system_framework(FWCoreMotion CoreMotion)
        pctk_internal_find_apple_system_framework(FWWatchKit WatchKit)
        pctk_internal_find_apple_system_framework(FWGameController GameController)
        pctk_internal_find_apple_system_framework(FWCoreBluetooth CoreBluetooth)
    endif()
endmacro()


#-----------------------------------------------------------------------------------------------------------------------
# Given framework_name == 'IOKit', sets non-cache variable 'FWIOKit' to '-framework IOKit' in the calling directory
# scope if the framework is found, or 'IOKit-NOTFOUND'.
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_find_apple_system_framework out_var framework_name)
    # To avoid creating many FindFoo.cmake files for each apple system framework, populate each  FWFoo variable with
    # '-framework Foo' instead of an absolute path to the framework. This makes  the generated CMake target files
    # relocatable, so that Xcode SDK absolute paths are not hardcoded, like with Xcode11.app on the CI.
    # We might revisit this later.
    set(cache_var_name "${out_var}Internal")

    find_library(${cache_var_name} "${framework_name}")

    if(${cache_var_name} AND ${cache_var_name} MATCHES ".framework$")
        set(${out_var} "-framework ${framework_name}" PARENT_SCOPE)
    else()
        set(${out_var} "${out_var}-NOTFOUND" PARENT_SCOPE)
    endif()
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
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


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
# Collects the framework related information and paths from the target properties.
# Output variables:
#    <out_var>_name framework base name, e.g. 'PCTKCore'.
#    <out_var>_dir framework base directory, e.g. 'PCTKCore.framework'.
#    <out_var>_version framework version, e.g. 'A', 'B' etc.
#    <out_var>_bundle_version framework bundle version, same as the PROJECT_VERSION, e.g. '6.0.0'.
#    <out_var>_header_dir top-level header directory, e.g. 'PCTKCore.framework/Headers'.
#    <out_var>_versioned_header_dir header directory for specific framework version,
#        e.g. 'PCTKCore.framework/Versions/A/Headers'
#    <out_var>_private_header_dir header directory for the specific framework version and
#       framework bundle version e.g. 'PCTKCore.framework/Versions/A/Headers/1.1.1'
#    <out_var>_private_library_header_dir private header directory for the specific framework
#       version, framework bundle version and tailing library name, e.g.
#       'PCTKCore.framework/Versions/A/Headers/1.1.1/Core'
function(pctk_internal_get_framework_info out_var target)
    get_target_property(${out_var}_version ${target} FRAMEWORK_VERSION)
    get_target_property(${out_var}_bundle_version ${target} MACOSX_FRAMEWORK_BUNDLE_VERSION)

    # The library name might be different of the actual target name
    # and we want to use the PCTK'fied library name as a framework identifier.
    get_target_property(library_interface_name ${target} _pctk_library_interface_name)
    if(library_interface_name)
        pctk_internal_target_add_fied(library ${library_interface_name})
    else()
        pctk_internal_target_add_fied(library ${target})
    endif()

    set(${out_var}_name "${library}")
    set(${out_var}_dir "${${out_var}_name}.framework")
    set(${out_var}_header_dir "${${out_var}_dir}/Headers")
    set(${out_var}_versioned_header_dir "${${out_var}_dir}/Versions/${${out_var}_version}/Headers")
    set(${out_var}_private_header_dir "${${out_var}_header_dir}/${${out_var}_bundle_version}")
    set(${out_var}_private_library_header_dir "${${out_var}_private_header_dir}/${library}")

    set(${out_var}_name "${${out_var}_name}" PARENT_SCOPE)
    set(${out_var}_dir "${${out_var}_dir}" PARENT_SCOPE)
    set(${out_var}_header_dir "${${out_var}_header_dir}" PARENT_SCOPE)
    set(${out_var}_version "${${out_var}_version}" PARENT_SCOPE)
    set(${out_var}_bundle_version "${${out_var}_bundle_version}" PARENT_SCOPE)
    set(${out_var}_versioned_header_dir "${${out_var}_versioned_header_dir}" PARENT_SCOPE)
    set(${out_var}_private_header_dir "${${out_var}_private_header_dir}" PARENT_SCOPE)
    set(${out_var}_private_library_header_dir "${${out_var}_private_library_header_dir}" PARENT_SCOPE)
endfunction()


