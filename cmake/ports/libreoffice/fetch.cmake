# Looks for an archive of this exact build and unpacks it, so a build that has
# already happened somewhere does not happen again here.
#
# Silent when there is no match: a miss, an unreachable store and an offline
# machine all mean the same thing, which is build from source.

include("${CMAKE_CURRENT_LIST_DIR}/key.cmake")

function(libreoffice_fetch_prebuilt url ref port_dir key_inputs target out)
  set(${out} "" PARENT_SCOPE)

  # The key names a revision, so the ref has to be resolved before asking for it.
  set(commit "${CMAKE_BINARY_DIR}/_libreoffice/commit.json")

  file(
    DOWNLOAD "https://api.github.com/repos/LibreOffice/core/commits/${ref}" "${commit}"
    STATUS status
    TIMEOUT 30
  )

  list(GET status 0 code)

  if(NOT code EQUAL 0)
    message(NOTICE "libreoffice: cannot resolve ${ref}, building from source")

    return()
  endif()

  file(READ "${commit}" json)

  string(JSON revision ERROR_VARIABLE error GET "${json}" sha)

  if(error)
    message(NOTICE "libreoffice: cannot read the revision of ${ref}, building from source")

    return()
  endif()

  libreoffice_cache_key_from("${revision}" "${port_dir}" "${key_inputs}" key)

  set(archive "${CMAKE_BINARY_DIR}/_libreoffice/libreoffice-${target}-${key}.tar.xz")

  file(
    DOWNLOAD "${url}/libreoffice-${target}-${key}.tar.xz" "${archive}"
    STATUS status
    TIMEOUT 600
  )

  list(GET status 0 code)

  if(NOT code EQUAL 0)
    file(REMOVE "${archive}")

    message(NOTICE "libreoffice: no archive for ${target}-${key}, building from source")

    return()
  endif()

  set(prebuilt "${CMAKE_BINARY_DIR}/_libreoffice/${key}")

  file(MAKE_DIRECTORY "${prebuilt}")

  file(ARCHIVE_EXTRACT INPUT "${archive}" DESTINATION "${prebuilt}")

  if(NOT EXISTS "${prebuilt}/binary")
    message(FATAL_ERROR "The archive for ${target}-${key} is not a LibreOffice archive")
  endif()

  message(NOTICE "libreoffice: reusing ${target}-${key}")

  set(${out} "${prebuilt}" PARENT_SCOPE)
endfunction()
