#include <assert.h>
#include <bare.h>
#include <js.h>

#include <LibreOfficeKit/LibreOfficeKit.h>

extern "C" LibreOfficeKit *
libreofficekit_hook(const char *install_path);

static js_value_t *
bare_collabora_exports(js_env_t *env, js_value_t *exports) {
  printf("libreofficekit_hook=%p\n", libreofficekit_hook);

  return exports;
}

BARE_MODULE(bare_collabora, bare_collabora_exports)
