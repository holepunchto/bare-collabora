include_guard(GLOBAL)

set(args)

if(APPLE)
  list(APPEND args
    --enable-bogus-pkg-config
    --enable-cairo-rgba
    --enable-gui
    --enable-hardening-flags
    --enable-headless
    --enable-lok-always-active
    --enable-macosx-sandbox
    --enable-mergelibs
    --enable-mpl-subset
    --enable-release-build

    --with-buildconfig-recorded
    --with-fonts
    --with-galleries=no
    --with-lang=en-US
    --with-linker-hash-style=both
    --with-system-zlib
    --with-theme=colibre
    --with-vendor=Collabora

    --disable-avahi
    --disable-avmedia
    --disable-coinmp
    --disable-community-flavor
    --disable-compiler-plugins
    --disable-cups
    --disable-database-connectivity
    --disable-dbus
    --disable-dconf
    --disable-epm
    --disable-evolution2
    --disable-ext-nlpsolver
    --disable-ext-wiki-publisher
    --disable-extensions
    --disable-firebird-sdbc
    --disable-gio
    --disable-gstreamer-1-0
    --disable-gtk3
    --disable-kf5
    --disable-ldap
    --disable-libcmis
    --disable-librelogo
    --disable-lotuswordpro
    --disable-lpsolve
    --disable-odk
    --disable-online-update
    --disable-opencl
    --disable-openssl
    --disable-poppler
    --disable-postgresql-sdbc
    --disable-python
    --disable-qt5
    --disable-randr
    --disable-report-builder
    --disable-sal-log
    --disable-scripting
    --disable-scripting-beanshell
    --disable-scripting-javascript
    --disable-sdremote
    --disable-sdremote-bluetooth
    --disable-skia
    --disable-symbols
    --disable-xmlhelp
    --disable-zxing

    --without-export-validation
    --without-help
    --without-helppack-integration
    --without-java
    --without-junit
    --without-myspell-dicts
    --without-package-format
    --without-system-cairo
    --without-system-curl
    --without-system-dicts
    --without-system-expat
    --without-system-fontconfig
    --without-system-freetype
    --without-system-graphite
    --without-system-harfbuzz
    --without-system-icu
    --without-system-jars
    --without-system-jpeg
    --without-system-libpng
    --without-system-libxml
    --without-system-nss
    --without-system-openssl
    --without-system-postgresql
    --without-templates
    --without-webdav
  )
endif()

if(CMAKE_BUILD_TYPE MATCHES "Debug")
  list(APPEND args --enable-debug)
elseif(CMAKE_BUILD_TYPE MATCHES "RelWithDebInfo")
  list(APPEND args --enable-symbols)
endif()

if(APPLE)
  list(APPEND args MAKE=gmake)
endif()

declare_port(
  "github:LibreOffice/core#distro/collabora/co-25.04"
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

# Shared library dependencies that consumers link directly as part of the build.
set(shared)

# Shared library dependencies that consumers open dynamically using dlopen() and
# equivalents.
set(modules)

if(APPLE)
  set(content_base instdir/CollaboraOffice.app/Contents)

  set(library_base ${content_base}/Frameworks)

  set(asset_base ${content_base}/Resources)

  list(APPEND shared
    libcairo.2.dylib
    libcurl.4.dylib
    libepoxy.dylib
    libexslt.0.dylib
    libfontconfig.1.dylib
    libgcc3_uno.dylib
    libi18nlangtag.dylib
    libicudata.dylib.75
    libicui18n.dylib.75
    libicuuc.dylib.75
    liblangtag.1.dylib
    liblcms2.2.dylib
    liblocaledata_en.dylib
    libmacbe1lo.dylib
    libmergedlo.dylib
    libnspr4.dylib
    libnss3.dylib
    libnssutil3.dylib
    libpdfiumlo.dylib
    libpixman-1.0.dylib
    libplc4.dylib
    libplds4.dylib
    libraptor2-lo.0.dylib
    librasqal-lo.3.dylib
    librdf-lo.0.dylib
    libreglo.dylib
    libsmime3.dylib
    libstorelo.dylib
    libuno_cppu.dylib.3
    libuno_cppuhelpergcc3.dylib.3
    libuno_sal.dylib.3
    libuno_salhelpergcc3.dylib.3
    libunoidllo.dylib
    libxml2.16.dylib
    libxmlreaderlo.dylib
    libxslt.1.dylib
  )

  list(APPEND modules
    libLanguageToollo.dylib
    libPresentationMinimizerlo.dylib
    libabplo.dylib
    libacclo.dylib
    libaffine_uno_uno.dylib
    libanalysislo.dylib
    libanimcorelo.dylib
    libbasegfxlo.dylib
    libbiblo.dylib
    libbinaryurplo.dylib
    libbootstraplo.dylib
    libcached1.dylib
    libcairocanvaslo.dylib
    libcmdmaillo.dylib
    libcomphelper.dylib
    libcuilo.dylib
    libdatelo.dylib
    libdeploymentgui.dylib
    libetonyek-0.1.1.dylib
    libflashlo.dylib
    libfps_aqualo.dylib
    libfreebl3.dylib
    libgraphicfilterlo.dylib
    libhwplo.dylib
    libintrospectionlo.dylib
    libinvocadaptlo.dylib
    libinvocationlo.dylib
    libiolo.dylib
    liblocaledata_es.dylib
    liblocaledata_euro.dylib
    liblocaledata_others.dylib
    liblog_uno_uno.dylib
    libloglo.dylib
    libmigrationoo2lo.dylib
    libmigrationoo3lo.dylib
    libmswordlo.dylib
    libmwaw-0.3.3.dylib
    libnamingservicelo.dylib
    libnssckbi.dylib
    libnssdbm3.dylib
    libodfgen-0.1.1.dylib
    liborcus-0.18.0.dylib
    liborcus-parser-0.18.0.dylib
    libpdffilterlo.dylib
    libpdfimportlo.dylib
    libpricinglo.dylib
    libproxyfaclo.dylib
    libreflectionlo.dylib
    librevenge-0.0.0.dylib
    libsal_textenclo.dylib
    libsaxlo.dylib
    libscdlo.dylib
    libscfiltlo.dylib
    libsclo.dylib
    libscnlo.dylib
    libscuilo.dylib
    libsddlo.dylib
    libsdlo.dylib
    libsduilo.dylib
    libslideshowlo.dylib
    libsmdlo.dylib
    libsmlo.dylib
    libsoftokn3.dylib
    libsolverlo.dylib
    libssl3.dylib
    libstaroffice-0.0.0.dylib
    libstocserviceslo.dylib
    libstoragefdlo.dylib
    libsvgfilterlo.dylib
    libsw_writerfilterlo.dylib
    libswdlo.dylib
    libswlo.dylib
    libswuilo.dylib
    libt602filterlo.dylib
    libtextconversiondlgslo.dylib
    libtllo.dylib
    libucbhelper.dylib
    libucppkg1.dylib
    libuno_purpenvhelpergcc3.dylib.3
    libunopkgapp.dylib
    libunsafe_uno_uno.dylib
    libuuresolverlo.dylib
    libvclplug_osxlo.dylib
    libwpd-0.10.10.dylib
    libwpftcalclo.dylib
    libwpftdrawlo.dylib
    libwpftimpresslo.dylib
    libwpftwriterlo.dylib
    libwpg-0.3.3.dylib
    libwps-0.4.4.dylib
    libwriterperfectlo.dylib
    libxmlsecurity.dylib
  )
endif()

set(libraries "${libreoffice_BINARY_DIR}/${library_base}")

set(assets "${libreoffice_BINARY_DIR}/${asset_base}")

set(stamp "${libreoffice_STAMP_DIR}/${libreoffice}-relink")

set(byproducts)

foreach(library IN LISTS shared modules)
  list(APPEND byproducts "${libraries}/${library}")
endforeach()

set(relink "${CMAKE_CURRENT_LIST_DIR}/relink.js")

add_custom_command(
  OUTPUT "${stamp}"
  DEPENDS ${relink} ${libreoffice}
  BYPRODUCTS ${byproducts}
  COMMAND node ${relink} ${byproducts}
  COMMAND "${CMAKE_COMMAND}" -E touch "${stamp}"
  VERBATIM
)

add_custom_target(libreoffice_relink DEPENDS "${stamp}" ${byproducts})

add_dependencies(libreoffice libreoffice_relink)

set(dependencies)

foreach(library IN LISTS shared modules)
  string(REGEX REPLACE "^lib|\\..*$" "" target "${library}")

  if(${library} IN_LIST shared)
    add_library(${target} SHARED IMPORTED GLOBAL)

    target_link_libraries(libreoffice INTERFACE ${target})
  else()
    add_library(${target} MODULE IMPORTED GLOBAL)
  endif()

  add_dependencies(${target} ${libreoffice} libreoffice_relink)

  set_target_properties(
    ${target}
    PROPERTIES
    IMPORTED_LOCATION "${libraries}/${library}"
  )

  list(APPEND dependencies ${target})
endforeach()

set_target_properties(
  libreoffice
  PROPERTIES
  COLLABORA_RUNTIME_DEPENDENCIES "${dependencies}"
  COLLABORA_ASSETS_DIR "${assets}"
)
