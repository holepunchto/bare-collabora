const env = require('bare-env')
const path = require('bare-path')
const { pathToFileURL } = require('bare-url')
const assets = require.asset('#assets')

const base = require.addon.resolve().replace(/\.bare$/, '')

switch (Bare.platform) {
  case 'darwin':
    env.URE_BOOTSTRAP = pathToFileURL(path.join(assets, 'Resources', 'fundamentalrc')).href
    env.URE_UNO_INI_URI = pathToFileURL(path.join(assets, 'Resources', 'ure', 'etc', 'unorc')).href
    env.URE_INTERNAL_LIB_DIR = env.LO_LIB_DIR = pathToFileURL(base).href
    break
}

module.exports = require.addon()
