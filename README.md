# bare-collabora

Collabora bindings for Bare.

```
npm i bare-collabora
```

## Usage

```js
const { Document } = require('bare-collabora')

const document = new Document('/path/to/sample.md')

document.saveAs('/path/to/sample.pdf')
```

## API

#### `const document = new Document(url)`

Loads the document at `url`. The `url` is a local file path or a `file:` URL pointing to a document in any format supported by Collabora. Throws if the document cannot be opened.

#### `document.saveAs(url[, format[, options]])`

Saves `document` to `url` in the given `format`. If `format` is omitted, it is inferred from the extension of `url`. `options` is a comma-separated string of filter options forwarded to Collabora; see the Collabora documentation for the filters available for a given format. Throws if the document cannot be saved.

## License

Apache-2.0
