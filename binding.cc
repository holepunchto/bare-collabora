#include <optional>
#include <string>

#include <assert.h>
#include <bare.h>
#include <js.h>
#include <jstl.h>
#include <uv.h>

#include <LibreOfficeKit/LibreOfficeKit.hxx>

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

  bare_collabora_document_t &operator=(bare_collabora_document_t &&) = delete;

  bare_collabora_document_t(const bare_collabora_document_t &) = delete;

  bare_collabora_document_t &operator=(const bare_collabora_document_t &) = delete;

  ~bare_collabora_document_t() {
    delete handle;
  }
};

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

  auto document = new bare_collabora_document_t(bare_collabora__kit->documentLoad(url.c_str()));

  uv_mutex_unlock(&bare_collabora__lock);

  js_external_t<bare_collabora_document_t> result;
  err = js_create_external<bare_collabora__on_document_finalize>(env, document, result);
  assert(err == 0);

  err = js_add_teardown_callback<bare_collabora__on_document_teardown>(env, document);
  assert(err == 0);

  return result;
}

static bool
bare_collabora_document_save_as(
  js_env_t *,
  js_receiver_t,
  bare_collabora_document_t *document,
  std::string url,
  std::optional<std::string> format,
  std::optional<std::string> options
) {
  return document->handle->saveAs(
    url.c_str(),
    format.has_value() ? format->c_str() : nullptr,
    options.has_value() ? options->c_str() : nullptr
  );
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
