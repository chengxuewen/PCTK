# Additional target information for pctk0
if(NOT DEFINED PCTK_DEFAULT_IMPORT_CONFIGURATION)
    set(PCTK_DEFAULT_IMPORT_CONFIGURATION DEBUG)
endif()
__pctk_internal_promote_target_to_global_checked(pctk0::core)
get_target_property(_pctk_imported_location_default pctk0::core IMPORTED_LOCATION_${PCTK_DEFAULT_IMPORT_CONFIGURATION})
get_target_property(_pctk_imported_soname_default pctk0::core IMPORTED_SONAME_${PCTK_DEFAULT_IMPORT_CONFIGURATION})

# Default configuration
if(_pctk_imported_location_default)
    set_property(TARGET pctk0::core PROPERTY IMPORTED_LOCATION "${_pctk_imported_location_default}")
endif()
if(_pctk_imported_soname_default)
    set_property(TARGET pctk0::core PROPERTY IMPORTED_SONAME "${_pctk_imported_soname_default}")
endif()
__pctk_internal_promote_target_to_global_checked(pctk0::corePrivate)

unset(_pctk_imported_location)
unset(_pctk_imported_location_default)
unset(_pctk_imported_soname)
unset(_pctk_imported_soname_default)
unset(_pctk_imported_configs)
