const test = require('brittle')
const path = require('bare-path')
const { Document } = require('.')

test('markdown to pdf', async (t) => {
  const tmp = await t.tmp()

  const markdown = new Document(require.resolve('./test/fixtures/sample.md'))

  markdown.saveAs(path.join(tmp, 'sample.pdf'))

  t.pass()
})
