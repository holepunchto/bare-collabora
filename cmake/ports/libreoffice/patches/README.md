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
