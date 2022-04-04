---
title: "Markdown to Confluence"
version: "0.0.2"
toc: "true"
---
# Markdown to Confluence Example

## Modules & Classes

1. Confluence.Client (confluence-client.rb)
   - Connects to the Confluence API (tested with Confluence Cloud) using Faraday
   - Methods:
     - Add a new page `create_page(params)` or `create(params)`
     - Update a page `update_page(id,params)`
     - Add an attachment `add_attachment(id,file_uri,mime_type)`
     - Add/Update an attachment `update_attachment(page_id,file_uri,mime_type=nil)`
     - Add attachments from an array `auto_attach(page_id,attachments[])`
     - Get attachment metadata `get_attachment_meta(id,filename)`
     - Get page metadata by ID `get_by_id(id)`
     - Get page metadata by paramaters `get_by_params(params)` or `get(params)`
     - Delete page or attachment `delete(id,version = nil)`
     - Set MIME type (for common mime-types only) `set_mime(file_uri)`
1. Confluence.Convert (md2confluence.rb)
   - Methods:
     - Process a markdown file `process_file(process_file)`


## Not Supported

- Lists in tables
- Carriage return in tables
  - You can use two backslashes (Confluence markup) '\\' in the markdown, it ain't pretty but it works)
- Language definition inside code blocks

## Front Matter

At the start of the document you can define the following metadata, none of the fields are required (this document only uses three of them).

This allows you to set the Confluence `space`, `parent` page, document `title`, and whether or not a table of contents (`toc`) will be included for each markdown file.

Note: `version` is defined in the frontmatter, this isn't used for Confluence versioning, if defined it will show at the top of the Confluence document in a panel. This is included for displaying a document version in policy controlled environments.

Example:

```
---
space: "COMPANY"
parent: "Procedures"
title: "Writing Procedures Procedure"
version: "1.0.1"
toc: "true"
---

# Your markdown here
```

--- 

# History

## 0.0.1

- Initial release, basic conversion and confluence uploading

## 0.0.2

### Fixed

- Regex for picking up relative links that require attachments were also picking up anchor links and some Jekyll specific code
- Curly braces {} were causing Confluence to reject the page if it didn't match a macro, fixed with 'supported macros' list
- `<br>` and `<br/>` were not converted to confluence new-lines
- Moved example content out of this readme
- URL's with parameters (/watch/?v=alskdfj) were failing
- Elements like Hash (#) inside code blocks were converted 
- Inline code that uses three backticks \`\`\` were not converting properly

### New

- Added larger test corpus, using Jekyll styled markdown
- Example for converting a directory structure into Confluence pages, matching the hierarchy of the directory
  - Also, an example for deleting the pages that get created
- Feature for 'supported macros', you can add additional macros in /lib/md2confluence/supported-macros.config
  - Any curly braces that don't match supported macros are now escaped
- Support for 'tags' in the frontmatter, these are automatically converted into labels
- 

### Known bugs:

- Anchor links are not working
- Test: arduino/nodemcu: broken image, table layout busted (description field)
- Test: docker/docker notes ... strikethrough in table
 