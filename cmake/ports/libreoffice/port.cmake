include_guard(GLOBAL)

set(
  LIBREOFFICE_BUNDLE_PATH
  "${CMAKE_BINARY_DIR}/_bundles/libreoffice-core.bundle"
  CACHE
  PATH
  "Path to a pre-downloaded LibreOffice core.bundle"
)

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
  elseif(platform MATCHES "linux")
    set(platform "gnu-${platform}")
  elseif(platform MATCHES "android")
    set(platform "linux-${platform}")
  else()
    message(FATAL_ERROR "Unsupported platform '${platform}'")
  endif()

  if(arch MATCHES "arm64|aarch64")
    set(arch "aarch64")
  elseif(arch MATCHES "armv7-a|armeabi-v7a")
    set(arch "armv7a")

    if(platform MATCHES "android")
      set(platform "${platform}eabi")
    endif()
  elseif(arch MATCHES "x64|x86_64|amd64")
    set(arch "x86_64")
  elseif(arch MATCHES "x86|i386|i486|i586|i686")
    set(arch "i686")
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

if(CMAKE_HOST_SYSTEM_NAME MATCHES "Darwin")
  list(APPEND args MAKE=gmake)
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
endif()

if(LINUX)
  list(APPEND args
    --enable-cairo-rgba
    --enable-epm
    --enable-extension-integration
    --enable-hardening-flags
    --enable-mergelibs
    --enable-mpl-subset
    --enable-noto-font

    --with-buildconfig-recorded
    --with-docrepair-fonts
    --with-external-dict-dir=/usr/share/hunspell
    --with-external-hyph-dir=/usr/share/hyphen
    --with-external-thes-dir=/usr/share/mythes
    --with-fonts
    --with-galleries=no
    --with-linker-hash-style=both
    --with-system-dicts
    --with-system-zlib

    --disable-community-flavor
    --disable-dbus
    --disable-dconf
    --disable-evolution2
    --disable-ext-nlpsolver
    --disable-ext-wiki-publisher
    --disable-firebird-sdbc
    --disable-gio
    --disable-gstreamer-1-0
    --disable-gtk3
    --disable-gui
    --disable-kf5
    --disable-lotuswordpro
    --disable-mariadb-sdbc
    --disable-online-update
    --disable-postgresql-sdbc
    --disable-qt5
    --disable-randr
    --disable-report-builder
    --disable-scripting-beanshell
    --disable-scripting-javascript
    --disable-sdremote
    --disable-sdremote-bluetooth

    --without-gssapi
    --without-help
    --without-java
    --without-krb5
    --without-package-format
    --without-system-cairo
    --without-system-curl
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

if(ANDROID)
  string(REGEX REPLACE "^(android-)?([0-9]+).*$" "\\2" android_api_level "${ANDROID_PLATFORM}")

  list(APPEND args
    --enable-android-lok
    --enable-pdfimport

    --with-android-api-level=${android_api_level}
    --with-android-ndk=${ANDROID_NDK}
    --with-android-sdk=${ANDROID_HOME}
    --with-android-package-name=com.collabora.libreoffice
    --with-docrepair-fonts

    --disable-ccache
    --disable-community-flavor
    --disable-cups
    --disable-largefile
    --disable-nss
    --disable-scripting-beanshell
    --disable-scripting-javascript

    --without-export-validation
    --without-helppack-integration
  )
endif()

set(bundle_url "https://git-bundles.libreoffice.org/core.bundle")

set(bundle_path "${LIBREOFFICE_BUNDLE_PATH}")

if(NOT EXISTS "${bundle_path}")
  file(DOWNLOAD "${bundle_url}" "${bundle_path}" STATUS bundle_status)

  list(GET bundle_status 0 bundle_code)

  if(NOT bundle_code EQUAL 0)
    list(GET bundle_status 1 bundle_error)

    file(REMOVE "${bundle_path}")

    message(FATAL_ERROR "Failed to download LibreOffice git bundle: ${bundle_error}")
  endif()
endif()

declare_port(
  "git:${bundle_path}#distro/collabora/co-25.04"
  libreoffice
  AUTOTOOLS
  ENTRYPOINT <SOURCE_DIR>/autogen.sh
  ARGS ${args}
  PATCHES
    patches/001-uno-ini-env-override.patch
    patches/002-forward-cross-compiling-state.patch
    patches/003-skip-install.patch
    patches/004-allow-ios-simulator-on-arm64.patch
    patches/005-curl-ios-disable-pipe2.patch
    patches/006-install-ios-static-libs.patch
    patches/007-ios-icu-data-from-env.patch
    patches/008-unzip-restore-permissions.patch
    patches/009-build-side-lib-ext.patch
    patches/010-argon2-android-kernel-name.patch
    patches/011-argon2-use-make-ar.patch
    patches/012-pixman-android-with-pic.patch
    patches/013-install-android-static-libs.patch
    patches/014-lo-all-static-libs-android-nss.patch
    patches/015-libxml2-android-with-pic.patch
    patches/016-libxslt-android-with-pic.patch
    patches/017-android-app-data-dir-fallback.patch
    patches/018-osl-dladdr-without-dlapi.patch
    patches/019-android-null-assetmgr-noent.patch
    patches/020-resmgr-app-data-dir-fallback.patch
    patches/021-android-null-javavm-guards.patch
    patches/022-fontconfig-data-all-platforms.patch
    patches/023-android-makefile-shared-no-nss.patch
    patches/024-native-code-graphic-export.patch
)

add_library(libreoffice INTERFACE)

add_dependencies(libreoffice ${libreoffice})

target_include_directories(
  libreoffice
  INTERFACE
    "${libreoffice_SOURCE_DIR}/include"
    "${libreoffice_BINARY_DIR}/config_host"
    "${libreoffice_BINARY_DIR}"
)

if(IOS OR ANDROID)
  target_compile_definitions(
    libreoffice
    INTERFACE
      DISABLE_DYNLOADING
  )

  set(native_code_h "${libreoffice_BINARY_DIR}/native-code.h")

  set(native_code_py "${libreoffice_SOURCE_DIR}/solenv/bin/native-code.py")

  set(native_code_cmake "${CMAKE_CURRENT_LIST_DIR}/native-code.cmake")

  add_custom_command(
    OUTPUT "${native_code_h}"
    COMMAND
      "${CMAKE_COMMAND}"
      "-DSOURCE_DIR=${libreoffice_SOURCE_DIR}"
      "-DOUTPUT=${native_code_h}"
      -P "${native_code_cmake}"
    DEPENDS ${libreoffice}
    VERBATIM
  )

  add_custom_target(libreoffice_native_code DEPENDS "${native_code_h}")

  add_dependencies(libreoffice libreoffice_native_code)
endif()

if(APPLE)
  target_link_libraries(
    libreoffice
    INTERFACE
      "-framework Foundation"
  )

  if(IOS)
    target_link_libraries(
      libreoffice
      INTERFACE
        "-framework UIKit"
    )
  else()
    target_link_libraries(
      libreoffice
      INTERFACE
        "-framework AppKit"
    )
  endif()
endif()

if(ANDROID)
  target_link_libraries(
    libreoffice
    INTERFACE
      android
      log
      z
  )
endif()

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
      libabw-0.1.a
      libacclo.a
      libafdko.a
      libaffine_uno_uno.a
      libanalysislo.a
      libanimcorelo.a
      libargon2.a
      libavmedialo.a
      libbasegfxlo.a
      libbiblo.a
      libbinaryurplo.a
      libboost_date_time.a
      libboost_filesystem.a
      libboost_iostreams.a
      libboost_locale.a
      libboost_system.a
      libbootstraplo.a
      libbox2d.a
      libcached1.a
      libcalclo.a
      libcanvasfactorylo.a
      libcanvastoolslo.a
      libcdr-0.1.a
      libcertdb.a
      libcerthi.a
      libchartcontrollerlo.a
      libchartcorelo.a
      libcomphelper.a
      libconfigmgrlo.a
      libcppcanvaslo.a
      libcppunit.a
      libcryptohi.a
      libctllo.a
      libcuilo.a
      libcurl.a
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
      libepubgen-0.1.a
      libevtattlo.a
      libexpat.a
      libexttextcat-2.0.a
      libfilelo.a
      libfilterconfiglo.a
      libfindsofficepath.a
      libflashlo.a
      libflatlo.a
      libforlo.a
      libforuilo.a
      libfrmlo.a
      libfsstoragelo.a
      libfwklo.a
      libgcc3_uno.a
      libgraphicfilterlo.a
      libgraphite.a
      libguesslanglo.a
      libharfbuzz.a
      libhunspell-1.7.a
      libhwplo.a
      libhyphen.a
      libhyphenlo.a
      libi18nlangtag.a
      libi18npoollo.a
      libi18nsearchlo.a
      libi18nutil.a
      libicglo.a
      libicudata.a
      libicui18n.a
      libicuio.a
      libicuuc.a
      libintrospectionlo.a
      libinvocadaptlo.a
      libinvocationlo.a
      libiolo.a
      liblangtag.a
      libLanguageToollo.a
      liblcms2.a
      liblibjpeg-turbo.a
      liblibpng.a
      liblnglo.a
      liblnthlo.a
      liblocalebe1lo.a
      liblocaledata_en.a
      liblocaledata_es.a
      liblocaledata_euro.a
      liblocaledata_others.a
      liblog_uno_uno.a
      libMacOSXSpelllo.a
      libmd4c.a
      libmsfilterlo.a
      libmspub-0.1.a
      libmswordlo.a
      libmtfrendererlo.a
      libmwaw-0.3.a
      libmysql_jdbclo.a
      libmythes-1.2.a
      libnamingservicelo.a
      libnspr4.a
      libnss.a
      libnss_ckfw_builtins.a
      libnss_freebl.a
      libnss_freebl_deprecated.a
      libnssb.a
      libnssckfw.a
      libnssdev.a
      libnsspki.a
      libnssutil.a
      libnumbertext-1.0.a
      libnumbertextlo.a
      libodfflatxmllo.a
      libodfgen-0.1.a
      liboffacclo.a
      libooopathutils.a
      libooxlo.a
      liborcus-0.18.a
      liborcus-mso-0.18.a
      liborcus-parser-0.18.a
      libpackage2.a
      libpasswordcontainerlo.a
      libpcrlo.a
      libpdffilterlo.a
      libpdfimportlo.a
      libpdfiumlo.a
      libpk11wrap.a
      libpkcs7.a
      libpkcs12.a
      libpkixcertsel.a
      libpkixchecker.a
      libpkixcrlsel.a
      libpkixmodule.a
      libpkixparams.a
      libpkixpki.a
      libpkixresults.a
      libpkixstore.a
      libpkixsystem.a
      libpkixtop.a
      libpkixutil.a
      libplc4.a
      libplds4.a
      libprecompiled_system.a
      libPresentationMinimizerlo.a
      libpricinglo.a
      libproxyfaclo.a
      libraptor2.a
      librasqal.a
      librdf.a
      libreflectionlo.a
      libreglo.a
      librevenge-0.0.a
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
      libsharpyuv.a
      libsimplecanvaslo.a
      libslideshowlo.a
      libsmdlo.a
      libsmime.a
      libsmlo.a
      libsofficeapp.a
      libsoftokn.a
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
      libtiff.a
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
      libulingu.a
      libuno_cppu.a
      libuno_cppuhelpergcc3.a
      libuno_purpenvhelpergcc3.a
      libuno_sal.a
      libuno_salhelpergcc3.a
      libunoidllo.a
      libunordflo.a
      libunoxmllo.a
      libunsafe_uno_uno.a
      libUseUnixWrappers.a
      libutllo.a
      libuuilo.a
      libuuresolverlo.a
      libvclcanvaslo.a
      libvcllo.a
      libvisio-0.1.a
      libwebp.a
      libwpd-0.10.a
      libwpftcalclo.a
      libwpftdrawlo.a
      libwpftimpresslo.a
      libwpftwriterlo.a
      libwpg-0.3.a
      libwps-0.4.a
      libwriterlo.a
      libwriterperfectlo.a
      libxml2.a
      libxmlfalo.a
      libxmlfdlo.a
      libxmlreaderlo.a
      libxmlscriptlo.a
      libxmlsec1-nss.a
      libxmlsec1.a
      libxmlsecurity.a
      libxoflo.a
      libxolo.a
      libxsec_xmlsec.a
      libxslt.a
      libxsltdlglo.a
      libxsltfilterlo.a
      libxstor.a
      libzxcvbn-c.a
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

if(LINUX)
  set(content_base instdir)

  set(library_base ${content_base}/program)

  set(asset_base ${content_base}/)

  list(APPEND shared
    libcairo-lo.so.2
    libcurl.so.4
    libexslt.so.0
    libfontconfig-lo.so.1.15.0
    libgcc3_uno.so
    libi18nlangtag.so
    libicudata.so.75
    libicui18n.so.75
    libicuuc.so.75
    liblangtag-lo.so.1
    liblcms2.so.2
    liblocaledata_en.so
    libmergedlo.so
    libnspr4.so
    libnss3.so
    libnssutil3.so
    libpdfiumlo.so
    libpixman-1.so.0
    libplc4.so
    libplds4.so
    libraptor2-lo.so.0
    librasqal-lo.so.3
    librdf-lo.so.0
    libreglo.so
    libsmime3.so
    libstorelo.so
    libuno_cppu.so.3
    libuno_cppuhelpergcc3.so.3
    libuno_sal.so.3
    libuno_salhelpergcc3.so.3
    libunoidllo.so
    libxml2.so.16
    libxmlreaderlo.so
    libxslt.so.1
  )

  list(APPEND modules
    libLanguageToollo.so
    libPresentationMinimizerlo.so
    libabplo.so
    libacclo.so
    libaffine_uno_uno.so
    libanalysislo.so
    libanimcorelo.so
    libbasegfxlo.so
    libbiblo.so
    libbinaryurplo.so
    libbootstraplo.so
    libcached1.so
    libcairocanvaslo.so
    libcalclo.so
    libcmdmaillo.so
    libcomphelper.so
    libcuilo.so
    libdatelo.so
    libdbahsqllo.so
    libdbalo.so
    libdbaselo.so
    libdbaxmllo.so
    libdbplo.so
    libdbpool2.so
    libdbulo.so
    libdeploymentgui.so
    libetonyek-0.1-lo.so.1
    libfilelo.so
    libflashlo.so
    libflatlo.so
    libfreebl3.so
    libfreeblpriv3.so
    libgraphicfilterlo.so
    libhwplo.so
    libintrospectionlo.so
    libinvocadaptlo.so
    libinvocationlo.so
    libiolo.so
    liblocaledata_es.so
    liblocaledata_euro.so
    liblocaledata_others.so
    liblog_uno_uno.so
    libloglo.so
    libmigrationoo2lo.so
    libmigrationoo3lo.so
    libmozbootstraplo.so
    libmswordlo.so
    libmwaw-0.3-lo.so.3
    libmysql_jdbclo.so
    libnamingservicelo.so
    libnssckbi.so
    libnssdbm3.so
    libodbclo.so
    libodfgen-0.1-lo.so.1
    liborcus-0.18.so.0
    liborcus-parser-0.18.so.0
    libpcrlo.so
    libpdffilterlo.so
    libpdfimportlo.so
    libpricinglo.so
    libproxyfaclo.so
    libreflectionlo.so
    librevenge-0.0-lo.so.0
    librptlo.so
    librptuilo.so
    librptxmllo.so
    libsal_textenclo.so
    libsaxlo.so
    libscdlo.so
    libscfiltlo.so
    libsclo.so
    libscnlo.so
    libscuilo.so
    libsdbc2.so
    libsdbtlo.so
    libsddlo.so
    libsdlo.so
    libsduilo.so
    libslideshowlo.so
    libsmdlo.so
    libsmlo.so
    libsoftokn3.so
    libsolverlo.so
    libsqlite3.so
    libssl3.so
    libstaroffice-0.0-lo.so.0
    libstocserviceslo.so
    libstoragefdlo.so
    libsvgfilterlo.so
    libsw_writerfilterlo.so
    libswdlo.so
    libswlo.so
    libswuilo.so
    libt602filterlo.so
    libtextconversiondlgslo.so
    libtllo.so
    libucbhelper.so
    libucppkg1.so
    libuno_purpenvhelpergcc3.so.3
    libunopkgapp.so
    libunsafe_uno_uno.so
    libuuresolverlo.so
    libwpd-0.10-lo.so.10
    libwpftcalclo.so
    libwpftdrawlo.so
    libwpftimpresslo.so
    libwpftwriterlo.so
    libwpg-0.3-lo.so.3
    libwps-0.4-lo.so.4
    libwriterlo.so
    libwriterperfectlo.so
    libxmlsecurity.so
  )
endif()

if(ANDROID)
  set(content_base instdir)

  set(library_base ${content_base}/program)

  set(asset_base ${content_base}/)

  list(APPEND static
    libCbc.a
    libCbcSolver.a
    libCgl.a
    libClp.a
    libClpSolver.a
    libCoinMP.a
    libCoinUtils.a
    libLanguageToollo.a
    libOsi.a
    libOsiClp.a
    libPresentationMinimizerlo.a
    libUseUnixWrappers.a
    libabw-0.1.a
    libacclo.a
    libafdko.a
    libaffine_uno_uno.a
    libanalysislo.a
    libanimcorelo.a
    libargon2.a
    libavmedialo.a
    libbasegfxlo.a
    libbiblo.a
    libbinaryurplo.a
    libboost_date_time.a
    libboost_filesystem.a
    libboost_iostreams.a
    libboost_locale.a
    libboost_system.a
    libbootstraplo.a
    libbox2d.a
    libcached1.a
    libcairo.a
    libcalclo.a
    libcanvasfactorylo.a
    libcanvastoolslo.a
    libcdr-0.1.a
    libcdr-internal.a
    libchartcontrollerlo.a
    libchartcorelo.a
    libcomphelper.a
    libconfigmgrlo.a
    libcppcanvaslo.a
    libcrypto.a
    libctllo.a
    libcuilo.a
    libcurl.a
    libcurlu.a
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
    libepubgen-0.1.a
    libepubgen_internal.a
    libevtattlo.a
    libexpat.a
    libexttextcat-2.0.a
    libfilelo.a
    libfilterconfiglo.a
    libfindsofficepath.a
    libflashlo.a
    libflatlo.a
    libfontconfig.a
    libforlo.a
    libforuilo.a
    libfreetype.a
    libfrmlo.a
    libfsstoragelo.a
    libfwklo.a
    libgcc3_uno.a
    libgraphicfilterlo.a
    libgraphite.a
    libguesslanglo.a
    libharfbuzz.a
    libhunspell-1.7.a
    libhwplo.a
    libhyphen.a
    libhyphenlo.a
    libi18nlangtag.a
    libi18npoollo.a
    libi18nsearchlo.a
    libi18nutil.a
    libicglo.a
    libicudata.a
    libicui18n.a
    libicuio.a
    libicuuc.a
    libintrospectionlo.a
    libinvocadaptlo.a
    libinvocationlo.a
    libiolo.a
    liblangtag.a
    liblcms2.a
    liblibjpeg-turbo.a
    liblibpng.a
    liblnglo.a
    liblnthlo.a
    liblo-bootstrap.a
    liblocalebe1lo.a
    liblocaledata_en.a
    liblocaledata_es.a
    liblocaledata_euro.a
    liblocaledata_others.a
    liblog_uno_uno.a
    libloglo.a
    libmd4c.a
    libmsfilterlo.a
    libmspub-0.1.a
    libmswordlo.a
    libmtfrendererlo.a
    libmwaw-0.3.a
    libmysql_jdbclo.a
    libmythes-1.2.a
    libnamingservicelo.a
    libnumbertext-1.0.a
    libnumbertextlo.a
    libodfflatxmllo.a
    libodfgen-0.1.a
    liboffacclo.a
    libooopathutils.a
    libooxlo.a
    liborcus-0.18.a
    liborcus-mso-0.18.a
    liborcus-parser-0.18.a
    libpackage2.a
    libpasswordcontainerlo.a
    libpcrlo.a
    libpdffilterlo.a
    libpdfimportlo.a
    libpdfiumlo.a
    libpixman-1.a
    libprecompiled_system.a
    libpricinglo.a
    libproxyfaclo.a
    libraptor2.a
    librasqal.a
    librdf.a
    libreflectionlo.a
    libreglo.a
    librevenge-0.0.a
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
    libsharpyuv.a
    libsharpyuv_neon.a
    libsharpyuv_sse2.a
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
    libssl.a
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
    libtiff.a
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
    libulingu.a
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
    libvisio-0.1.a
    libvisio-internal.a
    libwebp.a
    libwpd-0.10.a
    libwpftcalclo.a
    libwpftdrawlo.a
    libwpftimpresslo.a
    libwpftwriterlo.a
    libwpg-0.3.a
    libwps-0.4.a
    libwriterlo.a
    libwriterperfectlo.a
    libxml2.a
    libxmlfalo.a
    libxmlfdlo.a
    libxmlreaderlo.a
    libxmlscriptlo.a
    libxmlsec1.a
    libxmlsecurity.a
    libxoflo.a
    libxolo.a
    libxsec_xmlsec.a
    libxslt.a
    libxsltdlglo.a
    libxsltfilterlo.a
    libxstor.a
    libzxcvbn-c.a
  )
endif()

set(libraries "${libreoffice_BINARY_DIR}/${library_base}")

set(assets "${libreoffice_BINARY_DIR}/${asset_base}")

set(stamp "${libreoffice_STAMP_DIR}/${libreoffice}-relink")

set(byproducts)

foreach(library IN LISTS static shared modules)
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
