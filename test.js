const test = require('brittle')
const { Document } = require('.')

test('markdown to pdf', (t) => {
  const markdown = new Document(require.resolve('./test/fixtures/sample.md'))

  console.log(markdown)
})
