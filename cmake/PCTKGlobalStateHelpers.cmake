

#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_clear_pctk_repo_known_modules)
    set(PCTK_REPO_KNOWN_LIBRARIES "" CACHE INTERNAL "Known current repo PCTK libraries" FORCE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_add_repo_known_library)
    set(PCTK_REPO_KNOWN_LIBRARIES ${PCTK_REPO_KNOWN_LIBRARIES} ${ARGN}
        CACHE INTERNAL "Known current repo PCTK libraries" FORCE)
endfunction()


#-----------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
function(pctk_internal_get_repo_known_libraries out_var)
    set("${out_var}" "${PCTK_REPO_KNOWN_LIBRARIES}" PARENT_SCOPE)
endfunction()