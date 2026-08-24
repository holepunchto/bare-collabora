# Stages the two trees a consumer reads - see LIBREOFFICE_PREBUILT in port.cmake -
# and archives them, so a build can be reused instead of repeated.
#
# LIBRARIES is a file listing one absolute library path per line, the same shape
# relink.js takes, so the list stays in one place.

include("${CMAKE_CURRENT_LIST_DIR}/key.cmake")

libreoffice_cache_key("${SOURCE_DIR}" "${CMAKE_CURRENT_LIST_DIR}" "${KEY_INPUTS}" key)

set(OUTPUT "${ARCHIVE_DIR}/libreoffice-${ARCHIVE_TARGET}-${key}.tar.xz")

file(READ "${LIBRARIES}" libraries_content)

string(REGEX REPLACE "\r?\n" ";" libraries "${libraries_content}")

list(FILTER libraries EXCLUDE REGEX "^$")

set(staging "${OUTPUT}.staging")

file(REMOVE_RECURSE "${staging}")

file(MAKE_DIRECTORY "${staging}/binary/${LIBRARY_BASE}")

foreach(library IN LISTS libraries)
  if(EXISTS "${library}")
    file(COPY "${library}" DESTINATION "${staging}/binary/${LIBRARY_BASE}")
  else()
    message(FATAL_ERROR "Cannot pack a build that is missing ${library}")
  endif()
endforeach()

file(COPY "${ASSETS}/" DESTINATION "${staging}/binary/${ASSET_BASE}")

file(COPY "${SOURCE_DIR}/include/" DESTINATION "${staging}/source/include")

if(EXISTS "${BINARY_DIR}/config_host")
  file(COPY "${BINARY_DIR}/config_host/" DESTINATION "${staging}/binary/config_host")
endif()

# native-code.py generates a header the iOS and Android builds compile against,
# so it travels with the archive rather than the source tree it came from.
if(EXISTS "${SOURCE_DIR}/solenv/bin/native-code.py")
  file(COPY "${SOURCE_DIR}/solenv/bin/native-code.py" DESTINATION "${staging}/source/solenv/bin")
endif()

file(ARCHIVE_CREATE
  OUTPUT "${OUTPUT}"
  PATHS "${staging}/binary" "${staging}/source"
  FORMAT gnutar
  COMPRESSION XZ
  WORKING_DIRECTORY "${staging}"
)

file(REMOVE_RECURSE "${staging}")

message(STATUS "packed ${OUTPUT}")
