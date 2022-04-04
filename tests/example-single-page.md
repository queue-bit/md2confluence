---
title: "Markdown to Confluence Example"
version: "0.0.2"
toc: "true"
---

# Example markdown 

This page is for `example.rb`, which loads this file into Confluence.

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

![Data](./tests/assets/nodemcu-esp8266-amica.jpg "nodemcu-esp8266")


## Relative Links (local, requires attachment)

[attachment.txt](./tests/assets/test.txt)

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

# Common Macros

Two anchor Macros on the same line: {anchor:here}  {anchor: another one}

Contributor Macro:
{contributors:limit=10|scope=descendants|labels=chocolate,cake|showPages=true|noneFoundMessage=Oh dear, no contributors found|showCount=true|contentType=pages|include=authors,comments,labels,watches|mode=list|showAnonymous=true|order=update|page=ds:Advanced Topics|showLastTime=true}

Change History macro {change-history} and a {non-existent macro} on same line.

And an index {index}

# Common things that break

Inline code tags using three backticks ``` kubectl get namespaces ``` like that.

`>> /etc/profile.d/{your-variable-name}.sh`

Use `source` to load the `/etc/profile.d/{your-variable-name}.sh` file into the current shell

```zsh
~ sudo sh -c 'echo "export TEST_API_KEY=mykeyishere" >>  /etc/profile.d/test-key.sh' 
[sudo] password for user: _
~ sudo chmod +x /etc/profile.d/test-key.sh 
~ source /etc/profile.d/test-key.sh 
~ echo $TEST_API_KEY
mykeyishere
~_
```

# Some things from Jekyll for testing

[Here's a link with common things that (break), it currently doesn't work](#common-things-that-break)

This is a test <br/> where there are multiple <br> line-breaks of \\ different types.