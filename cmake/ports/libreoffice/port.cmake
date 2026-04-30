include_guard(GLOBAL)

set(args)

set(build_platform ${CMAKE_HOST_SYSTEM_NAME})

string(TOLOWER "${build_platform}" build_platform)

set(build_arch ${CMAKE_HOST_SYSTEM_PROCESSOR})

string(TOLOWER "${build_arch}" build_arch)

if(CMAKE_SYSTEM_NAME)
  set(host_platform ${CMAKE_SYSTEM_NAME})
else()
  set(host_platform ${build_platform})
endif()

string(TOLOWER "${host_platform}" host_platform)

if(APPLE AND CMAKE_OSX_ARCHITECTURES)
  set(host_arch ${CMAKE_OSX_ARCHITECTURES})
elseif(MSVC AND CMAKE_GENERATOR_PLATFORM)
  set(host_arch ${CMAKE_GENERATOR_PLATFORM})
elseif(ANDROID AND CMAKE_ANDROID_ARCH_ABI)
  set(host_arch ${CMAKE_ANDROID_ARCH_ABI})
elseif(CMAKE_SYSTEM_PROCESSOR)
  set(host_arch ${CMAKE_SYSTEM_PROCESSOR})
else()
  set(host_arch ${build_arch})
endif()

string(TOLOWER "${host_arch}" host_arch)

foreach(prefix build host)
  set(platform ${${prefix}_platform})
  set(arch ${${prefix}_arch})

  if(platform MATCHES "darwin|ios")
    set(platform "apple-${platform}")
  else()
    message(FATAL_ERROR "Unsupported platform '${platform}'")
  endif()

  if(arch MATCHES "arm64|aarch64")
    set(arch "aarch64")
  elseif(arch MATCHES "armv7-a|armeabi-v7a")
    set(arch "arm")
  elseif(arch MATCHES "x64|x86_64|amd64")
    set(arch "x86_64")
  elseif(arch MATCHES "x86|i386|i486|i586|i686")
    set(arch "x86_32")
  else()
    message(FATAL_ERROR "Unsupported architecture '${arch}'")
  endif()

  set(${prefix}_platform ${platform})
  set(${prefix}_arch ${arch})
endforeach()

list(APPEND args
  --build=${build_arch}-${build_platform}
  --host=${host_arch}-${host_platform}
)

if(CMAKE_BUILD_TYPE MATCHES "Debug")
  list(APPEND args --enable-debug)
elseif(CMAKE_BUILD_TYPE MATCHES "RelWithDebInfo")
  list(APPEND args --enable-symbols)
endif()

list(APPEND args
  --enable-lok-always-active
  --enable-release-build

  --with-lang=en-US
  --with-theme=colibre
  --with-vendor=Collabora

  --disable-avmedia
  --disable-coinmp
  --disable-extensions
  --disable-ldap
  --disable-libcmis
  --disable-librelogo
  --disable-lpsolve
  --disable-odk
  --disable-opencl
  --disable-poppler
  --disable-python
  --disable-sal-log
  --disable-scripting
  --disable-symbols
  --disable-xmlhelp
  --disable-zxing

  --without-junit
  --without-myspell-dicts
  --without-webdav
)

if(APPLE)
  list(APPEND args
    --enable-bogus-pkg-config

    --disable-avahi
    --disable-compiler-plugins
    --disable-cups
    --disable-dconf
    --disable-firebird-sdbc
    --disable-gstreamer-1-0
    --disable-kf5
    --disable-online-update
    --disable-openssl

    --without-export-validation
    --without-helppack-integration
    --without-java
  )

  if(IOS)
    list(APPEND args
      --with-docrepair-fonts

      --disable-breakpad
    )

    if(CMAKE_OSX_SYSROOT MATCHES "iPhoneSimulator")
      list(APPEND args --enable-ios-simulator)
    endif()
  else()
    list(APPEND args
      --enable-cairo-rgba
      --enable-gui
      --enable-hardening-flags
      --enable-headless
      --enable-macosx-sandbox
      --enable-mergelibs
      --enable-mpl-subset

      --with-buildconfig-recorded
      --with-fonts
      --with-galleries=no
      --with-linker-hash-style=both
      --with-system-zlib

      --disable-community-flavor
      --disable-database-connectivity
      --disable-dbus
      --disable-epm
      --disable-evolution2
      --disable-ext-nlpsolver
      --disable-ext-wiki-publisher
      --disable-gio
      --disable-gtk3
      --disable-lotuswordpro
      --disable-postgresql-sdbc
      --disable-qt5
      --disable-randr
      --disable-report-builder
      --disable-scripting-beanshell
      --disable-scripting-javascript
      --disable-sdremote
      --disable-sdremote-bluetooth
      --disable-skia

      --without-help
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
    )
  endif()

  list(APPEND args MAKE=gmake)
endif()

declare_port(
  "github:LibreOffice/core#distro/collabora/co-25.04"
  libreoffice
  AUTOTOOLS
  ARGS ${args}
  PATCHES
    patches/001-uno-ini-env-override.patch
    patches/002-configure-out-of-tree.patch
    patches/003-forward-cross-compiling-state.patch
    patches/004-skip-install-on-ios.patch
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

# Shared library dependencies that consumers link directly as part of the build.
set(static)

if(APPLE)
  if(IOS)
    set(content_base instdir)

    set(library_base ${content_base}/program)

    set(asset_base ${content_base}/)

    list(APPEND static
      libacclo.a
      libaffine_uno_uno.a
      libanalysislo.a
      libanimcorelo.a
      libavmedialo.a
      libbasegfxlo.a
      libbiblo.a
      libbinaryurplo.a
      libbootstraplo.a
      libcached1.a
      libcalclo.a
      libcanvasfactorylo.a
      libcanvastoolslo.a
      libchartcontrollerlo.a
      libchartcorelo.a
      libcomphelper.a
      libconfigmgrlo.a
      libcppcanvaslo.a
      libctllo.a
      libcuilo.a
      libdatelo.a
      libdbahsqllo.a
      libdbalo.a
      libdbaselo.a
      libdbaxmllo.a
      libdbplo.a
      libdbpool2.a
      libdbtoolslo.a
      libdbulo.a
      libdeployment.a
      libdeploymentgui.a
      libdeploymentmisclo.a
      libdesktopbe1lo.a
      libdocmodello.a
      libdrawinglayercorelo.a
      libdrawinglayerlo.a
      libeditenglo.a
      libembobj.a
      libemboleobj.a
      libemfiolo.a
      libepoxy.a
      libevtattlo.a
      libfilelo.a
      libfilterconfiglo.a
      libflashlo.a
      libflatlo.a
      libforlo.a
      libforuilo.a
      libfrmlo.a
      libfsstoragelo.a
      libfwklo.a
      libgcc3_uno.a
      libgraphicfilterlo.a
      libguesslanglo.a
      libhwplo.a
      libhyphenlo.a
      libi18nlangtag.a
      libi18npoollo.a
      libi18nsearchlo.a
      libi18nutil.a
      libicglo.a
      libintrospectionlo.a
      libinvocadaptlo.a
      libinvocationlo.a
      libiolo.a
      libLanguageToollo.a
      liblnglo.a
      liblnthlo.a
      liblocalebe1lo.a
      liblocaledata_en.a
      liblocaledata_es.a
      liblocaledata_euro.a
      liblocaledata_others.a
      liblog_uno_uno.a
      libMacOSXSpelllo.a
      libmsfilterlo.a
      libmswordlo.a
      libmtfrendererlo.a
      libmysql_jdbclo.a
      libnamingservicelo.a
      libnumbertextlo.a
      libodfflatxmllo.a
      liboffacclo.a
      libooxlo.a
      libpackage2.a
      libpasswordcontainerlo.a
      libpcrlo.a
      libpdffilterlo.a
      libpdfimportlo.a
      libpdfiumlo.a
      libPresentationMinimizerlo.a
      libpricinglo.a
      libproxyfaclo.a
      libreflectionlo.a
      libreglo.a
      librptlo.a
      librptuilo.a
      librptxmllo.a
      libsaxlo.a
      libsblo.a
      libscdlo.a
      libscfiltlo.a
      libsclo.a
      libscuilo.a
      libsdbc2.a
      libsdbtlo.a
      libsddlo.a
      libsdlo.a
      libsduilo.a
      libsfxlo.a
      libsimplecanvaslo.a
      libslideshowlo.a
      libsmdlo.a
      libsmlo.a
      libsofficeapp.a
      libsolverlo.a
      libsotlo.a
      libspelllo.a
      libspllo.a
      libsrtrs1.a
      libstocserviceslo.a
      libstoragefdlo.a
      libstorelo.a
      libsvgfilterlo.a
      libsvgiolo.a
      libsvllo.a
      libsvtlo.a
      libsvxcorelo.a
      libsvxlo.a
      libsw_writerfilterlo.a
      libswdlo.a
      libswlo.a
      libswuilo.a
      libt602filterlo.a
      libtextconversiondlgslo.a
      libtextfdlo.a
      libtklo.a
      libtllo.a
      libucb1.a
      libucbhelper.a
      libucpexpand1lo.a
      libucpextlo.a
      libucpfile1.a
      libucphier1.a
      libucpimagelo.a
      libucppkg1.a
      libucptdoc1lo.a
      libuno_cppu.a
      libuno_cppuhelpergcc3.a
      libuno_purpenvhelpergcc3.a
      libuno_sal.a
      libuno_salhelpergcc3.a
      libunoidllo.a
      libunordflo.a
      libunoxmllo.a
      libunsafe_uno_uno.a
      libutllo.a
      libuuilo.a
      libuuresolverlo.a
      libvclcanvaslo.a
      libvcllo.a
      libwpftcalclo.a
      libwpftdrawlo.a
      libwpftimpresslo.a
      libwpftwriterlo.a
      libwriterlo.a
      libwriterperfectlo.a
      libxmlfalo.a
      libxmlfdlo.a
      libxmlreaderlo.a
      libxmlscriptlo.a
      libxmlsecurity.a
      libxoflo.a
      libxolo.a
      libxsec_xmlsec.a
      libxsltdlglo.a
      libxsltfilterlo.a
      libxstor.a
    )
  else()
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

foreach(library IN LISTS shared modules static)
  string(REGEX REPLACE "^lib|\\..*$" "" target "${library}")

  if(${library} IN_LIST static)
    add_library(${target} STATIC IMPORTED GLOBAL)

    target_link_libraries(libreoffice INTERFACE ${target})
  else()
    if(${library} IN_LIST shared)
      add_library(${target} SHARED IMPORTED GLOBAL)

      target_link_libraries(libreoffice INTERFACE ${target})
    else()
      add_library(${target} MODULE IMPORTED GLOBAL)
    endif()

    list(APPEND dependencies ${target})
  endif()

  add_dependencies(${target} ${libreoffice} libreoffice_relink)

  set_target_properties(
    ${target}
    PROPERTIES
    IMPORTED_LOCATION "${libraries}/${library}"
  )
endforeach()

set_target_properties(
  libreoffice
  PROPERTIES
  COLLABORA_RUNTIME_DEPENDENCIES "${dependencies}"
  COLLABORA_ASSETS_DIR "${assets}"
)
