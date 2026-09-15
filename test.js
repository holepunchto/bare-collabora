const test = require('brittle')
const path = require('bare-path')
const { Document } = require('.')

test('markdown to pdf', async (t) => {
  const tmp = await t.tmp()

  const markdown = new Document(require.asset('./test/fixtures/sample.md'))

  markdown.saveAs(path.join(tmp, 'sample.pdf'))

  t.pass()
})

test('drawing to pdf', async (t) => {
  const tmp = await t.tmp()

  const drawing = new Document(require.asset('./test/fixtures/sample.fodg'))

  drawing.saveAs(path.join(tmp, 'sample.pdf'))

  t.pass()
})

test('drawing to png', async (t) => {
  const tmp = await t.tmp()

  const drawing = new Document(require.asset('./test/fixtures/sample.fodg'))

  drawing.saveAs(path.join(tmp, 'sample.png'))

  t.pass()
})

test('drawing to svg', async (t) => {
  const tmp = await t.tmp()

  const drawing = new Document(require.asset('./test/fixtures/sample.fodg'))

  drawing.saveAs(path.join(tmp, 'sample.svg'))

  t.pass()
})

test('spreadsheet to pdf', async (t) => {
  const tmp = await t.tmp()

  const spreadsheet = new Document(require.asset('./test/fixtures/sample.fods'))

  spreadsheet.saveAs(path.join(tmp, 'sample.pdf'))

  t.pass()
})

test('presentation to pdf', async (t) => {
  const tmp = await t.tmp()

  const presentation = new Document(require.asset('./test/fixtures/sample.fodp'))

  presentation.saveAs(path.join(tmp, 'sample.pdf'))

  t.pass()
})
