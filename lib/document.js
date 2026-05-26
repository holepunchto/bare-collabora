const { pathToFileURL } = require('bare-url')
const binding = require('../binding')

module.exports = class CollaboraDocument {
  constructor(url) {
    this._handle = binding.documentOpen(toFileURL(url))
  }

  saveAs(url, format, options) {
    binding.documentSaveAs(this._handle, toFileURL(url), format, options)
  }

  [Symbol.for('bare.inspect')]() {
    return {
      __proto__: { constructor: CollaboraDocument }
    }
  }
}

function toFileURL(path) {
  let url

  if (startsWithWindowsDriveLetter(path)) {
    url = null
  } else {
    url = URL.parse(path)
  }

  if (url === null) url = pathToFileURL(path)

  return url
}

// https://infra.spec.whatwg.org/#ascii-upper-alpha
function isASCIIUpperAlpha(c) {
  return c >= 0x41 && c <= 0x5a
}

// https://infra.spec.whatwg.org/#ascii-lower-alpha
function isASCIILowerAlpha(c) {
  return c >= 0x61 && c <= 0x7a
}

// https://infra.spec.whatwg.org/#ascii-alpha
function isASCIIAlpha(c) {
  return isASCIIUpperAlpha(c) || isASCIILowerAlpha(c)
}

// https://url.spec.whatwg.org/#windows-drive-letter
function isWindowsDriveLetter(input) {
  return (
    input.length >= 2 &&
    isASCIIAlpha(input.charCodeAt(0)) &&
    (input.charCodeAt(1) === 0x3a || input.charCodeAt(1) === 0x7c)
  )
}

// https://url.spec.whatwg.org/#start-with-a-windows-drive-letter
function startsWithWindowsDriveLetter(input) {
  return (
    input.length >= 2 &&
    isWindowsDriveLetter(input) &&
    (input.length === 2 ||
      input.charCodeAt(2) === 0x2f ||
      input.charCodeAt(2) === 0x5c ||
      input.charCodeAt(2) === 0x3f ||
      input.charCodeAt(2) === 0x23)
  )
}
