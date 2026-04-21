include_guard(GLOBAL)

set(args
  --enable-release-build
  --enable-hardening-flags
  --enable-headless

  --disable-extensions
  --disable-odk
  --disable-python

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
  PATCHES
    patches/001-uno-ini-env-override.patch
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
    libbasegfxlo.dylib
    libcairo-lo.2.dylib
    libcanvastoolslo.dylib
    libchart2apilo.dylib
    libclewlo.dylib
    libcomphelper.dylib
    libconfigmgrlo.dylib
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
    libgcc3_uno.dylib
    libgpg-error.0.dylib
    libgpgme.11.dylib
    libgpgmepp.6.dylib
    libi18nlangtag.dylib
    libi18npoollo.dylib
    libi18nutil.dylib
    libicudata.dylib.78
    libicui18n.dylib.78
    libicuuc.dylib.78
    liblangtag.1.dylib
    liblcms2.2.dylib
    liblnglo.dylib
    liblocalebe1lo.dylib
    liblocaledata_en.dylib
    libmacbe1lo.dylib
    libnspr4.dylib
    libnss3.dylib
    libnssutil3.dylib
    libopencllo.dylib
    libpdfiumlo.dylib
    libpixman-1.0.dylib
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
    libstocserviceslo.dylib
    libstorelo.dylib
    libsvllo.dylib
    libsvtlo.dylib
    libsvxcorelo.dylib
    libsvxlo.dylib
    libtklo.dylib
    libtllo.dylib
    libucb1.dylib
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

  set(byproducts)
  set(commands)

  foreach(library IN LISTS libraries)
    set(path "${libreoffice_BINARY_DIR}/${library_base}/${library}")

    set(args install_name_tool -id "@rpath/${library}")

    foreach(other IN LISTS libraries)
      list(APPEND args -change "@rpath/${other}" "@loader_path/${other}")
    endforeach()

    list(APPEND byproducts "${path}")
    list(APPEND args "${path}")
    list(APPEND commands COMMAND ${args})
  endforeach()

  add_custom_command(
    OUTPUT "${stamp}"
    DEPENDS ${libreoffice}
    BYPRODUCTS ${byproducts}
    ${commands}
    COMMAND "${CMAKE_COMMAND}" -E touch "${stamp}"
    VERBATIM
  )

  add_custom_target(libreoffice_install_names DEPENDS "${stamp}" ${byproducts})

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
