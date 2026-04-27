#include <assert.h>
#include <bare.h>
#include <js.h>
#include <uv.h>

#include <LibreOfficeKit/LibreOfficeKit.h>

extern "C" LibreOfficeKit *
libreofficekit_hook(const char *install_path);

static uv_once_t bare_collabora__init_guard = UV_ONCE_INIT;

static LibreOfficeKit *bare_collabora__kit = nullptr;

static void
bare_collabora__on_init(void) {
  bare_collabora__kit = libreofficekit_hook(nullptr);
}

static js_value_t *
bare_collabora_exports(js_env_t *env, js_value_t *exports) {
  uv_once(&bare_collabora__init_guard, bare_collabora__on_init);

  return exports;
}

BARE_MODULE(bare_collabora, bare_collabora_exports)
