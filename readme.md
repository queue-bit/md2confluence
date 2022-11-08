---
title: "Markdown to Confluence"
version: "0.0.2"
toc: "true"
---
# Markdown to Confluence

## About

Includes two modules to:

1. Convert Github flavoured markdown to Confluence markup
   - Of note:
     - Nested and mixed lists with poor indenting should work!
     - Relative links to files (for things like an image) are parsed and can be easily attached to the confluence page!
2. Interface with Confluence

You can [read more about md2confluence](https://www.andreaswiebe.com/homelab-notes/projects/md2confluence) on my site.

## Requirements

- A *nix environment
- A Confluence instance with API permissions
- Tested in ruby 2.7.4 against Confluence Cloud

## Not Supported

- Lists in tables
- Carriage return in tables
  - You can use two backslashes '\\' in the markdown, or html elements `<br>` or `<br />`
- Language definition inside code blocks is not yet supported
- Windows is not yet supported


## Modules & Classes

1. Confluence.Client (confluence-client.rb)
   - Connects to the Confluence API using Faraday
   - Methods:
     - Add a new page: `create(params)`
     - Update a page: `update_page(id,params)`
     - Add an attachment: `add_attachment(id,file_uri,mime_type)`
     - Add/Update an attachment: `update_attachment(page_id,file_uri,mime_type=nil)`
     - Add attachments from an array of filenames: `auto_attach(page_id,attachments[])`
     - Get attachment metadata: `get_attachment_meta(id,filename)`
     - Get page metadata by ID: `get_by_id(id)`
     - Get page metadata by parameters: `get(params)`
     - Delete page or attachment: `delete(id,version = nil)`
     - Set MIME type (for common mime-types only): `set_mime(file_uri)`
1. Confluence.Convert (md2confluence.rb)
   - Methods:
     - Process a markdown file `process_file(process_file)`

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
tags: "Each word here is a tag/label"
---

# Your markdown here
```

--- 

# History

## 0.0.1

- Initial release, basic conversion and confluence uploading

## 0.0.2

### New

- Added larger test corpus, using Jekyll styled markdown
- Added an example for converting a directory structure into Confluence pages, matching the hierarchy of the directory `example-convert-directory.rb`
  - Also, an example for deleting the pages that get created `example-convert-directory-delete.rb`
- Added feature for 'supported macros', you can add additional macros in /lib/md2confluence/supported-macros.config
  - Any curly braces that don't match supported macros are now escaped
  - Note that macro blocks (eg. plantuml) may not work and have not yet been tested
- Support for 'tags' in the frontmatter, these are automatically converted into labels
  - Note that Confluence does not allow most special characters in tags. Commas, periods, etc. will be stripped when uploading to Confluence

### Fixed

- Regex for picking up relative links that require attachments were also picking up anchor links and some Jekyll specific code
- Relative links were being processed as relative to the working directory instead of the markdown file's location
- Curly braces {} were causing Confluence to reject the page if it didn't match a macro, fixed with 'supported macros' list
- `<br>` and `<br/>` were not converted to confluence new-lines
- Moved example content out of this readme
- URL's with parameters (/watch/?v=alskdfj) were failing
- Elements like Hash (#) inside code blocks were converted 
- Inline code that uses three backticks \`\`\` were not converting properly
- Table layout broken when a non-header row had double pipes without a space for an empty cell (i.e. || instead of | |)

### Known bugs:

- Anchor links are not working
- File: `./tests/_docker/2021-01-24-docker-common-commands.md` has errant strikethrough formatting in the table
- Macro blocks (eg. plantuml) may not work
