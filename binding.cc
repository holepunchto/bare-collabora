#include <optional>
#include <string>

#include <assert.h>
#include <bare.h>
#include <js.h>
#include <jstl.h>
#include <uv.h>

#include <LibreOfficeKit/LibreOfficeKit.hxx>

#if defined(DISABLE_DYNLOADING)
extern "C" {
#include <native-code.h>
}
#endif

#if defined(_WIN32)
#include <delayimp.h>
#include <string.h>
#include <windows.h>
#endif

using namespace lok;

extern "C" LibreOfficeKit *
libreofficekit_hook(const char *install_path);

static Office *bare_collabora__kit = nullptr;

static uv_mutex_t bare_collabora__lock;

static uv_once_t bare_collabora__init_guard = UV_ONCE_INIT;

struct bare_collabora_document_t {
  Document *handle;

  explicit bare_collabora_document_t(Document *handle) : handle(handle) {}

  bare_collabora_document_t(bare_collabora_document_t &&) = delete;

  bare_collabora_document_t &
  operator=(bare_collabora_document_t &&) = delete;

  bare_collabora_document_t(const bare_collabora_document_t &) = delete;

  bare_collabora_document_t &
  operator=(const bare_collabora_document_t &) = delete;

  ~bare_collabora_document_t() {
    delete handle;
  }
};

#if defined(_WIN32)

// PE has no rpath, so a delay-loaded library and its dependencies are looked up by name in the
// process search order — which a packaged app narrows to paths that are never ours. Loading from
// this directory with LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR covers both.
static std::wstring
bare_collabora__library_directory(void) {
  HMODULE self;

  if (!GetModuleHandleExW(
        GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
        reinterpret_cast<LPCWSTR>(&bare_collabora__library_directory),
        &self
      )) return {};

  std::wstring path(MAX_PATH, L'\0');

  for (;;) {
    DWORD len = GetModuleFileNameW(self, path.data(), static_cast<DWORD>(path.size()));

    if (len == 0) return {};

    if (len < path.size()) {
      path.resize(len);
      break;
    }

    path.resize(path.size() * 2);
  }

  // <name>.bare sits next to <name>/, where the libraries are installed
  size_t extension = path.rfind(L'.');

  if (extension == std::wstring::npos) return {};

  path.resize(extension);

  return path;
}

static FARPROC WINAPI
bare_collabora__on_delay_load(unsigned event, PDelayLoadInfo info) noexcept {
  if (event != dliNotePreLoadLibrary) return nullptr;

  static const std::wstring directory = bare_collabora__library_directory();

  if (directory.empty()) return nullptr;

  std::wstring library(directory);
  library += L'\\';
  library.append(info->szDll, info->szDll + strlen(info->szDll));

  return reinterpret_cast<FARPROC>(LoadLibraryExW(
    library.c_str(),
    nullptr,
    LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR | LOAD_LIBRARY_SEARCH_DEFAULT_DIRS
  ));
}

extern "C" const PfnDliHook __pfnDliNotifyHook2 = bare_collabora__on_delay_load;

#endif

static void
bare_collabora__on_init(void) {
  int err;

  bare_collabora__kit = new Office(libreofficekit_hook(nullptr));

  err = uv_mutex_init(&bare_collabora__lock);
  assert(err == 0);
}

static void
bare_collabora__on_document_teardown(bare_collabora_document_t *document) {
  delete document->handle;

  document->handle = nullptr;
}

static void
bare_collabora__on_document_finalize(js_env_t *env, bare_collabora_document_t *wrapper) {
  int err;

  err = js_remove_teardown_callback<bare_collabora__on_document_teardown>(env, wrapper);
  assert(err == 0);

  delete wrapper;
}

static js_external_t<bare_collabora_document_t>
bare_collabora_document_open(
  js_env_t *env,
  js_receiver_t,
  std::string url
) {
  int err;

  uv_mutex_lock(&bare_collabora__lock);

  auto handle = bare_collabora__kit->documentLoad(url.c_str());

  if (!handle) {
    auto message = bare_collabora__kit->getError();

    err = js_throw_error(env, nullptr, message ? message : "documentLoad() failed");
    assert(err == 0);

    if (message) bare_collabora__kit->freeError(message);

    uv_mutex_unlock(&bare_collabora__lock);

    throw js_pending_exception;
  }

  uv_mutex_unlock(&bare_collabora__lock);

  auto document = new bare_collabora_document_t(handle);

  js_external_t<bare_collabora_document_t> result;
  err = js_create_external<bare_collabora__on_document_finalize>(env, document, result);
  assert(err == 0);

  err = js_add_teardown_callback<bare_collabora__on_document_teardown>(env, document);
  assert(err == 0);

  return result;
}

static void
bare_collabora_document_save_as(
  js_env_t *env,
  js_receiver_t,
  bare_collabora_document_t *document,
  std::string url,
  std::optional<std::string> format,
  std::optional<std::string> options
) {
  int err;

  uv_mutex_lock(&bare_collabora__lock);

  auto ok = document->handle->saveAs(
    url.c_str(),
    format.has_value() ? format->c_str() : nullptr,
    options.has_value() ? options->c_str() : nullptr
  );

  if (!ok) {
    auto message = bare_collabora__kit->getError();

    err = js_throw_error(env, nullptr, message ? message : "saveAs() failed");
    assert(err == 0);

    if (message) bare_collabora__kit->freeError(message);

    uv_mutex_unlock(&bare_collabora__lock);

    throw js_pending_exception;
  }

  uv_mutex_unlock(&bare_collabora__lock);
}

static js_value_t *
bare_collabora_exports(js_env_t *env, js_value_t *exports) {
  int err;

  uv_once(&bare_collabora__init_guard, bare_collabora__on_init);

#define V(name, fn) \
  err = js_set_property<fn>(env, exports, name); \
  assert(err == 0);

  V("documentOpen", bare_collabora_document_open);
  V("documentSaveAs", bare_collabora_document_save_as);
#undef V

  return exports;
}

BARE_MODULE(bare_collabora, bare_collabora_exports)
