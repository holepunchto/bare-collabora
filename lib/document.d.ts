export default interface CollaboraDocument {
  /**
   * Saves the document to `url` in the given `format`. If `format` is omitted, it is inferred from
   * the extension of `url`. `options` is a comma-separated string of filter options forwarded to
   * Collabora; see the Collabora documentation for the filters available for a given format.
   * @param url - The destination path or `file:` URL to write to.
   * @param format - The output format; when omitted, it is inferred from the extension of `url`.
   * @param options - A comma-separated string of filter options forwarded to Collabora. See the
   * Collabora documentation for the filters available for a given format.
   * @throws The document cannot be saved.
   */
  saveAs(url: string, format?: string, options?: string): boolean
}

export default class CollaboraDocument {
  constructor(url: string)
}
