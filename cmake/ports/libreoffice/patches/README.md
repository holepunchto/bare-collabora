# LibreOffice patches

Patches applied on top of upstream LibreOffice when building it as a library bundle for the `bare-collabora` addon. Each patch is designed to be embedder-agnostic and additive (preserve upstream behavior as the fallback), with the longer-term goal of being upstreamable.

## Cross-cutting

### 001 - `uno-ini-env-override`

Honor `URE_UNO_INI_URI` (and `URE_BOOTSTRAP`) from the process environment when bootstrapping UNO. Lets an embedder relocate `unorc` / `fundamentalrc` outside the install dir without having to drop a file at the hardcoded install-relative path. Falls back to the existing platform-specific paths when unset.

### 002 - `forward-cross-compiling-state`

Pass `cross_compiling=yes` to bundled `./configure` invocations when LO itself is cross-compiling. Without this, some external projects (e.g. those using autoconf) fail their own host/build detection and try to run target binaries on the build host.

### 003 - `skip-install`

Drop the non-MACOSX `install` / `install-strip` targets from the top-level `Makefile.in`. The bundle is consumed via the `instdir/` tree directly; the upstream install target assumes a desktop layout we don't need and trips on missing pieces in a static / cross-built configuration.

### 008 - `unzip-restore-permissions`

After `UnpackedTarball` extraction, `chmod -R u+rwX,go+rX` the tree. Some upstream tarballs ship files without owner-write, which breaks subsequent patch / rebuild cycles when `gbuild` tries to overwrite them.

### 009 - `build-side-lib-ext`

Set `gb_Library_PLAINEXT_FOR_BUILD = .dylib` when `OS_FOR_BUILD == MACOSX`. Upstream hardcodes `.so` for build-side libraries, which breaks cross builds hosted on macOS (the build-machine linker produces `.dylib`).

### 022 - `fontconfig-data-all-platforms`

Build `ExternalPackage_fontconfig_data` on Android, iOS, and Linux too - not just Emscripten and macOS. Embedders on every supported platform need the fontconfig data shipped alongside the static bundle.

### 027 - `conf-for-build-skip-system-libs`

Extend the `CONF-FOR-BUILD` opt-out from system `libxml`, `fontconfig`, `freetype`, and `zlib` to also fire when `_os` is `Android` or `iOS`, not just `Emscripten`. The build-side configure was probing the host's `pkg-config` for `fontconfig >= 2.12.0` (and the others) even when the actual target was a self-contained cross-build that ships these libs internally; on a clean Ubuntu runner without `libfontconfig-dev` the probe fails. The `--with-main-module` defaulting stays Emscripten-only.

## iOS

### 004 - `allow-ios-simulator`

Allow `enable_ios_simulator=yes` on both `arm64` and `x86_64` hosts so the simulator builds on Apple Silicon and Intel Macs. Upstream `configure.ac` only canonicalises `aarch64` for iOS and bakes `arm64` into `HOST_PLATFORM`, `host_cpu_for_clang`, `CPUNAME`, `RTL_ARCH`, and `PLATFORMID`; this patch adds the matching `x86_64` branches.

### 005 - `curl-ios-disable-pipe2`

Force `ac_cv_func_pipe2=no` when configuring bundled curl for iOS. `pipe2` is not part of the public iOS API surface and the autoconf probe succeeds at compile time but fails at link.

### 006 - `install-ios-static-libs`

Extend `ios/CustomTarget_iOS_setup.mk` to mirror every `.a` enumerated by `bin/lo-all-static-libs` into `instdir/<LIBO_LIB_FOLDER>/`, synthesize archives for NSS subtrees that only emit loose `.o` files, and stage `ICU.dat` next to the other program-level resources. Lets downstream consumers link from one location.

### 007 - `ios-icu-data-from-env`

On iOS, accept `LIBREOFFICE_ICU_DATA` as a path override for `ICU.dat`. Falls back to the existing `[bundlePath]/ICU.dat` lookup when unset. Useful when the embedder ships ICU data inside a framework resource directory instead of the main app bundle.

### 025 - `nasm-ios-mach-o`

Add `ios*` to the host-OS case that selects the NASM object format. Without this, an iOS x86_64 simulator host falls through to the `ELF ?` default and `NAFLAGS` ends up `-felf -DELF -DPIC`; the assembler then can't see NASM macros like `collect_args` in libjpeg-turbo's SIMD sources. iOS targets the same Mach-O / Mach-O64 formats as macOS, so this is just extending the existing branch.

### 026 - `nss-ios-use-64`

In `external/nss/ExternalProject_nss.mk`, include `iOS` in the OS filter that passes `USE_64=1 CPU_ARCH=x86_64` to NSS when `CPUNAME=X86_64`. Without `USE_64`, NSS picks the 32-bit code path in `lib/freebl/drbg.c` and `PR_STATIC_ASSERT(sizeof(size_t) <= 4)` fails the compile on a 64-bit iOS simulator host. The `AARCH64` branch on the next line is already OS-agnostic so iOS arm64 isn't affected.

## Android

### 010 - `argon2-android-kernel-name`

Pass `KERNEL_NAME=Linux` to argon2's Makefile when building for Android. Argon2's makefile keys library extensions / link flags off `KERNEL_NAME` from `uname -s`, which returns `Linux` on Android but is unreachable when cross-compiling.

### 011 - `argon2-use-make-ar`

Add a new bundled argon2 patch making its Makefile honor `$(AR)` instead of hardcoding `ar`. Required so the Android NDK's `llvm-ar` is used instead of the build-host `ar`, which produces archives the target linker rejects.

### 012 - `pixman-android-with-pic`

Pass `--with-pic` to bundled pixman's `configure` on Android. Pixman's static archive is linked into a `.so` further down the pipeline; without `-fPIC` the relocations are not valid in a shared object on aarch64.

### 013 - `install-android-static-libs`

Mirror image of patch 006 for Android: after `AllModulesButInstsetNative`, copy every static archive emitted by `bin/lo-all-static-libs` into `instdir/<LIBO_LIB_FOLDER>/` and stage `ICU.dat`. First-wins on basename collisions preserves the upstream link-order semantics.

### 014 - `lo-all-static-libs-android-nss`

Gate the `libxmlsec1-nss.a` reference in `bin/lo-all-static-libs` (Android branch) on `$ENABLE_NSS == TRUE`. When LO is configured `--disable-nss`, xmlsec doesn't build the NSS backend, so the unconditional reference breaks the enumeration. The gate is harmless when NSS is enabled.

### 015 - `libxml2-android-with-pic`

Same rationale as patch 012, for bundled libxml2 on Android.

### 016 - `libxslt-android-with-pic`

Same rationale as patch 012, for bundled libxslt on Android.

### 017 - `android-app-data-dir-fallback`

In `lo_initialize`, when `lo_get_app_data_dir()` returns `NULL` (embedder doesn't use the APK Java bootstrap), fall back to resolving `aAppPath` from the loaded module's URL instead of dereferencing `NULL` through `OUString::fromUtf8`.

### 018 - `osl-dladdr-without-dlapi`

Keep `getModulePathFromAddress()` functional even when `HAVE_UNIX_DLAPI` is 0 (Android sets this because the dynamic-loading API is restricted). `dladdr()` on already-loaded modules still works on Android and is needed by `osl_getModuleURLFromAddress` for embedders that ship LO as static archives inside their own `.so`.

### 019 - `android-null-assetmgr-noent`

In `sal/osl/unx/file.cxx::openFilePath`, treat `lo_get_native_assetmgr() == NULL` as a missing-file condition rather than calling `AAssetManager_open` with a `NULL` manager (which dereferences it). Required for embedders that don't bootstrap LO through the Java/APK wrapper.

### 020 - `resmgr-app-data-dir-fallback`

Mirror of patch 017 for `unotools/source/i18n/resmgr.cxx`: when `lo_get_app_data_dir()` is `NULL`, fall back to the `$BRAND_BASE_DIR`-based path resolution instead of constructing an `OString` from a `NULL` pointer.

### 021 - `android-null-javavm-guards`

Guard every `lo_get_javavm()->Attach/DetachCurrentThread(...)` call in `sal/osl/unx/thread.cxx` and `vcl/android/androidinst.cxx` with a `NULL` check. Embedders that don't bootstrap LO through Java leave `lo_get_javavm()` returning `NULL`; the unguarded calls would crash on every sal thread start and on `AndroidSalInstance` construction.

### 023 - `android-makefile-shared-no-nss`

In `android/Bootstrap/Makefile.shared`, gate the `NSSLIBS` definition and the `$(SODEST)/nss-libraries` link dependency on `ENABLE_NSS == TRUE`. Required to make `--disable-nss` actually link on Android (default-on upstream unconditionally references NSS shared libraries).

### 024 - `native-code-graphic-export`

Add `filter_GraphicExportFilter_get_implementation` to `solenv/bin/native-code.py::core_constructor_list`. Without this entry, `cppuhelper::shlib` can't construct the UNO component backing the PNG / JPEG export filters under `DISABLE_DYNLOADING`, so `Document::saveAs` for any graphic format silently fails with `ERRCODE_IO_CANTWRITE`.

## Windows (MSYS2 + MSVC)

The Windows build uses MSYS2 as a POSIX shell layer over MSVC toolchains. Several patches fix impedance mismatches between MSYS2's path conventions (`/c/…`) and the Windows-style paths (`C:/…`) that autoconf and LO's build system produce.

A `python3w.sh` wrapper is installed alongside the patches and set as `PYTHON_FOR_BUILD`. It converts any `C:/…`-style argument to a POSIX path via `cygpath -u` before forwarding to `/usr/bin/python3`, because MSYS2's Python binary does not perform automatic path translation for script arguments.

### 028 - `msys2-use-cygpath`

In `solenv/gbuild/Helper.mk`, use `cygpath -u` instead of `wslpath -u` to populate the `SRCDIR_WSL` / `BUILDDIR_WSL` / … variables when running under MSYS2 (i.e. `MSYSTEM` is set but `WSL_DISTRO_NAME` is not). Upstream only handled the actual WSL case; this makes `gb_Helper_wsl_path` functional in a plain MSYS2 environment.

### 029 - `fix-include-symlink`

Before `AC_CONFIG_LINKS([include:include])` in `configure.ac`, remove the `include/` directory if it already exists as a real directory rather than a symlink. On Windows, git may check out the symlink target as a plain directory; autoconf's `AC_CONFIG_LINKS` then fails because it can't replace a directory with a symlink.

### 030 - `quote-gnupatch`

Quote `$(GNUPATCH)` in the `UnpackedTarball` patch-application loop in `solenv/gbuild/UnpackedTarball.mk`. On Windows, `GNUPATCH` resolves to a path containing spaces (e.g. `C:/Program Files/Git/usr/bin/patch.exe`); without quoting the shell splits it and the command is not found.

### 031 - `msys2-makefile-use-cygpath`

In `Makefile.in`, use `cygpath -u` to convert `SRCDIR` to a POSIX path when regenerating `config_host.mk` under MSYS2 (non-WSL). Upstream only handled WSL via `wslpath`; without this, `make` passes a Windows-style `SRCDIR` into the makefile infrastructure where MSYS2 expects a POSIX path.

### 033 - `openssl-msys2-perl-fallback`

In `external/openssl/ExternalProject_openssl.mk`, when `MSYSTEM` is set but `STRAWBERRY_PERL` is empty, fall back to the `PERL` detected by configure (MSYS2's own `perl.exe`) instead of expanding to an empty string. Upstream assumes that `MSYSTEM` implies a WSL environment where Strawberry Perl is required; under a native MSYS2 build without Strawberry Perl installed, the empty expansion drops the interpreter and leaves `Configure` as a bare (unfound) command.

### 032 - `icu-wnt-disable-extras`

Pass `--disable-extras` unconditionally to ICU's `./configure` on WNT. The `extra/uconv` subdirectory tries to generate a man page via `config.status` during the build, which fails in the MSYS2/MSVC environment. LibreOffice does not use any ICU extras, so skipping them is safe. Previously `--disable-extras` was only applied for cross-compiled WNT builds.

### 034 - `atl-paths-windows-format`

In `configure.ac`, replace `win_short_path_for_make` with `cygpath -sm` for `ATL_LIB` and `ATL_INCLUDE`. Under MSYS2, `win_short_path_for_make` falls through to its `else` branch which calls `cygpath -u`, producing POSIX-style paths (`/c/...`). MSVC (`cl.exe`) receives those as `-I/c/...` and cannot resolve them; the result is `atlbase.h: No such file or directory` even when ATL is installed. `cygpath -sm` always produces short Windows mixed-style paths (`C:/...`) which MSVC understands.

### 035 - `install-ooo-implibs`

In `solenv/gbuild/platform/com_MSC_class.mk`, add `gb_Library__install_ilib` and call it from `gb_Library_Library_platform` for OOO-layer libraries. This copies each library's import `.lib` alongside its `.dll` in `instdir/program/`, making the `instdir/` tree self-contained for embedders. `RTVERLIBS` and `UNOVERLIBS` are unaffected — their import libraries already land in `instdir/sdk/lib/` via `gb_Library_get_ilib_target`.
