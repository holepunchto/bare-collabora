const env = require('bare-env')
const path = require('bare-path')
const { pathToFileURL } = require('bare-url')
const assets = require.asset('#assets')

const base = require.addon.resolve().replace(/\.bare$/, '')

env.PATH = base + path.delimiter + env.PATH
env.URE_BOOTSTRAP = pathToFileURL(path.join(assets, 'program', 'fundamental.ini')).href
env.URE_UNO_INI_URI = pathToFileURL(path.join(assets, 'program', 'uno.ini')).href
env.URE_INTERNAL_LIB_DIR = env.LO_LIB_DIR = pathToFileURL(base).href

module.exports = require.addon()
