---
title: "Markdown to Confluence"
version: "0.0.1"
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


# Example markdown 

The rest of this page is for `example.rb`, which loads this file into Confluence.

## Lists

### Ordered List

1. This is the first top-level item in an ordered list
   1. Item 2 is indented, one level in
      1. Item 3 is indented, two levels in
            1. Item 4 is indented, four levels in
   2. Item 5 is one level in
2. This is the second top-level item

### Unordered List

- This is the first top-level item in an unordered list
  - Item 2 is indented, one level in
    - Item 3 is indented, two levels in
        - Item 4 is indented, four levels in
  - Item 5 is one level in
- This is the second top-level item

### Mixed List

1. This is the first top-level item in a mixed list
   - Item 2 is indented, one level in
     1. Item 3 is indented, two levels in
           1. Item 4 is indented, four levels in
     - Item 5 is two levels in
- This is the second top-level item

## Code Block

```text

This is a code block.
This is the second line of a code block.
This is the third line of a code block.

This is the last line of a code block.
```

## Inline Code

`This is inline code`


## Links

1. This is [an example](http://example.com/ "This is a title attribute") inline link.
1. [This link](http://example.com/) has no title attribute.
1. [More than one](http://example.com/) link [on a line](https://example.org)


## Remote Images

![Branching Concepts 1](http://git-scm.com/figures/18333fig0319-tn.png "Branching Map")

![Branching Concepts 2](http://git-scm.com/figures/18333fig0319-tn.png)

## Local Images

Local images are added to an attachments list so they can be uploaded.

![Data](../../assets/image.png "Distance TimeSeries")


## Relative Links (local, requires attachment)

[attachment.txt](../../assets/attachment.txt)

## Text styling

- *Italic*
- **Bold**


## Tables

| | Column 1 | Column 2 | Column 3 | Column 4 |
|-| - | - | - | - |
|Row 1| 1.1 | 1.2 | 1.3 | 1.4 |
|Row 2| 2.1 | 2.2 | 2.3 | 2.4 |
|Row 3| 3.1 | 3.2 | 3.3 | 3.4 |
|Row 4| 4.1 | 4.2 | 4.3 | 4.4 |


---


# h1

H1 example

## h2

H2 example

### h3

H3 example

#### h4

H4 example

##### h5

H5 example

###### h6

H6 example

