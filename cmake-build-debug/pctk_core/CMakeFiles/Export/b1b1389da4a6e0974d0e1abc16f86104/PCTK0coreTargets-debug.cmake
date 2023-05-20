#----------------------------------------------------------------
# Generated CMake target import file for configuration "Debug".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "PCTK0::core" for configuration "Debug"
set_property(TARGET PCTK0::core APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(PCTK0::core PROPERTIES
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/lib/libPCTK0core_debug.0.1.1.dylib"
  IMPORTED_SONAME_DEBUG "@rpath/libPCTK0core_debug.0.dylib"
  )

list(APPEND _cmake_import_check_targets PCTK0::core )
list(APPEND _cmake_import_check_files_for_PCTK0::core "${_IMPORT_PREFIX}/lib/libPCTK0core_debug.0.1.1.dylib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
