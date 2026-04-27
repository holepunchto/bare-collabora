const binding = require('../binding')

module.exports = class CollaboraDocument {
  constructor(url) {
    this._handle = binding.documentOpen(url)
  }

  saveAs(url, format, options) {
    return binding.documentSaveAs(this._handle, url, format, options)
  }

  [Symbol.for('bare.inspect')]() {
    return {
      __proto__: { constructor: CollaboraDocument }
    }
  }
}
