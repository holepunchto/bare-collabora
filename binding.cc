#include <assert.h>
#include <bare.h>
#include <js.h>

#include <LibreOfficeKit/LibreOfficeKit.h>

extern "C" LibreOfficeKit *
libreofficekit_hook(const char *install_path);

static js_value_t *
bare_collabora_exports(js_env_t *env, js_value_t *exports) {
  libreofficekit_hook(nullptr);

  return exports;
}

BARE_MODULE(bare_collabora, bare_collabora_exports)
