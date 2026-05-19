const env = require('bare-env')
const os = require('bare-os')
const path = require('bare-path')
const { pathToFileURL } = require('bare-url')
const assets = require.asset('#assets')

const cache = path.join(os.tmpdir(), 'bare-collabora')

env.URE_BOOTSTRAP = pathToFileURL(path.join(assets, 'program', 'fundamentalrc')).href
env.URE_UNO_INI_URI = pathToFileURL(path.join(assets, 'program', 'unorc')).href
env.LIBREOFFICE_ICU_DATA = path.join(assets, 'program', 'ICU.dat')
env.BRAND_BASE_DIR = pathToFileURL(assets).href
env.UserInstallation = pathToFileURL(cache).href
env.TMPDIR = os.tmpdir()
env.FONTCONFIG_FILE = path.join(assets, 'share', 'fontconfig', 'fonts.conf')
env.XDG_DATA_DIRS = path.join(assets, 'share')
env.XDG_CACHE_HOME = cache

module.exports = require.addon()
