include_guard(GLOBAL)

set(args
  --enable-release-build
  --enable-hardening-flags

  --enable-extensions=no
  --enable-odk=no
  --enable-python=no

  --without-lang
  --without-java
)

if(CMAKE_BUILD_TYPE MATCHES "Debug")
  list(APPEND args --enable-debug)
elseif(CMAKE_BUILD_TYPE MATCHES "RelWithDebInfo")
  list(APPEND args --enable-symbols)
endif()

if(APPLE)
  list(APPEND args MAKE=gmake --enable-bogus-pkg-config)
endif()

declare_port(
  "github:LibreOffice/core#libreoffice-26.2.3.1"
  libreoffice
  AUTOTOOLS
  ARGS ${args}
)

add_library(libreoffice INTERFACE)

add_dependencies(libreoffice ${libreoffice})

target_include_directories(
  libreoffice
  INTERFACE "${libreoffice_SOURCE_DIR}/include"
)

if(APPLE)
  set(library_base instdir/LibreOffice.app/Contents/Frameworks)

  set(libraries
    libassuan.9.dylib
    libavmedialo.dylib
    libbasctllo.dylib
    libbasegfxlo.dylib
    libcanvastoolslo.dylib
    libchart2apilo.dylib
    libclewlo.dylib
    libcomphelper.dylib
    libcppcanvaslo.dylib
    libcurl.4.dylib
    libdbtoolslo.dylib
    libdeploymentmisclo.dylib
    libdocmodello.dylib
    libdrawinglayercorelo.dylib
    libdrawinglayerlo.dylib
    libeditenglo.dylib
    libepoxy.dylib
    libfwklo.dylib
    libgpg-error.0.dylib
    libgpgme.11.dylib
    libgpgmepp.6.dylib
    libi18nlangtag.dylib
    libi18nutil.dylib
    libicudata.dylib.78
    libicui18n.dylib.78
    libicuuc.dylib.78
    liblangtag.1.dylib
    liblcms2.2.dylib
    liblnglo.dylib
    libnspr4.dylib
    libnss3.dylib
    libnssutil3.dylib
    libopencllo.dylib
    libpdfiumlo.dylib
    libplc4.dylib
    libplds4.dylib
    libreglo.dylib
    libsaxlo.dylib
    libsblo.dylib
    libsfxlo.dylib
    libskialo.dylib
    libsmime3.dylib
    libsofficeapp.dylib
    libsotlo.dylib
    libstorelo.dylib
    libsvllo.dylib
    libsvtlo.dylib
    libsvxcorelo.dylib
    libsvxlo.dylib
    libtklo.dylib
    libtllo.dylib
    libucbhelper.dylib
    libuno_cppu.dylib.3
    libuno_cppuhelpergcc3.dylib.3
    libuno_sal.dylib.3
    libuno_salhelpergcc3.dylib.3
    libunoidllo.dylib
    libutllo.dylib
    libvcllo.dylib
    libxmlreaderlo.dylib
    libxmlscriptlo.dylib
    libxolo.dylib
  )
endif()

if(APPLE)
  set(stamp "${libreoffice_STAMP_DIR}/${libreoffice}-install-names")

  set(commands)

  foreach(library IN LISTS libraries)
    list(APPEND commands COMMAND install_name_tool -id "@rpath/${library}" "${libreoffice_BINARY_DIR}/${library_base}/${library}")
  endforeach()

  add_custom_command(
    OUTPUT "${stamp}"
    DEPENDS ${libreoffice}
    ${commands}
    COMMAND "${CMAKE_COMMAND}" -E touch "${stamp}"
    VERBATIM
  )

  add_custom_target(libreoffice_install_names DEPENDS "${stamp}")

  add_dependencies(libreoffice libreoffice_install_names)
endif()

foreach(library IN LISTS libraries)
  string(REGEX REPLACE "^lib|\\..*$" "" target "${library}")

  add_library(${target} SHARED IMPORTED GLOBAL)

  add_dependencies(${target} ${libreoffice})

  if(APPLE)
    add_dependencies(${target} libreoffice_install_names)
  endif()

  set_target_properties(
    ${target}
    PROPERTIES
    IMPORTED_LOCATION "${libreoffice_BINARY_DIR}/${library_base}/${library}"
  )

  target_link_libraries(libreoffice INTERFACE ${target})
endforeach()
