# Derives a name for a built LibreOffice from everything that changes it. Two
# builds sharing a key must be interchangeable, so anything the key misses is a
# stale archive silently linked in.
#
# Deliberately excluded: this port's own recipe. `port.cmake` decides what the
# arguments are, and those arguments are hashed - hashing its text as well would
# invalidate every archive whenever the file is edited for reasons that leave the
# output identical.

# Reads the revision from a checked-out tree, which is what packing has to hand.
function(libreoffice_cache_key source_dir port_dir key_inputs out)
  execute_process(
    COMMAND git -C "${source_dir}" rev-parse HEAD
    OUTPUT_VARIABLE revision
    OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE result
  )

  if(NOT result EQUAL 0)
    message(FATAL_ERROR "Cannot read the revision of ${source_dir}")
  endif()

  libreoffice_cache_key_from("${revision}" "${port_dir}" "${key_inputs}" key)

  set(${out} "${key}" PARENT_SCOPE)
endfunction()

# Takes the revision, which is all configure time can know before fetching.
function(libreoffice_cache_key_from revision port_dir key_inputs out)
  set(parts "")

  string(APPEND parts "revision=${revision}\n")

  # The patches change the source; relink rewrites the binaries; the codegen and
  # python wrapper feed the build. Prose and packaging scripts do not.
  set(inputs "")

  file(GLOB_RECURSE patches "${port_dir}/patches/*.patch")

  list(APPEND inputs
    ${patches}
    "${port_dir}/relink.js"
    "${port_dir}/native-code.cmake"
    "${port_dir}/python3w.sh"
  )

  list(SORT inputs)

  foreach(input IN LISTS inputs)
    if(EXISTS "${input}")
      file(SHA256 "${input}" digest)

      cmake_path(RELATIVE_PATH input BASE_DIRECTORY "${port_dir}" OUTPUT_VARIABLE name)

      string(APPEND parts "${name}=${digest}\n")
    endif()
  endforeach()

  file(READ "${key_inputs}" configured)

  string(APPEND parts "${configured}")

  string(SHA256 key "${parts}")

  string(SUBSTRING "${key}" 0 16 key)

  set(${out} "${key}" PARENT_SCOPE)
endfunction()
