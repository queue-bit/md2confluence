require 'pp'
require 'fileutils'
require 'rubygems'
require_relative './lib/md2confluence/md2confluence.rb'
require_relative './lib/confluence-client/confluence-client.rb'


# Confluence connection details:
$site        = "https://example.atlassian.net/wiki/"    # The full API base url (ex. https://example.atlassian.net/wiki/)
$username    = "example@gmail.com"                      # The username (ex. example@gmail.com)
$password    = "yourpassword"                           # The password, for Confluence Cloud you'll need to setup a token https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/

# The file to process:
markdown_file = "./readme.md" 

#---
#-> Instantiate
# Convert the file:
markup = Confluence::Convert.new(markdown_file)

# Confluence Connection: 
client = Confluence::Client.new($username, $password, $site)

#---
#-> Retrieve metadata

# Get the page's metadata
# page_space = markup.space            # <-- for this example, readme.md's frontmatter doesn't contain the space tag,
# page_parent = markup.parent          # <-- or the page's parent so we need to set here:
page_space = "SPACE"                   # <-- Set this to your Confluence Space name
page_parent = "Parent"                 # <-- Set this to the page's parent
page_title = markup.title
page_version = markup.version


# Get the metadata of the page's parent
parent = client.get({spaceKey: page_space, title: page_parent})[0]

#---
#-> Create a page

# Define some labels
# Note that confluence labels cannot have spaces in them and are stored in all lowercase
page_labels = {labels:[
    {prefix: "global", name: "md2confluence"},
    {prefix: "global", name: markup.file_hash}
]}

# Create the page
result = client.create({
    type:"page",
    title: page_title, 
    space: {key: page_space}, 
    ancestors:[{type:"page",id: parent['id']}],
    metadata: page_labels,
    body: {storage:{value: markup.confluence_markup, representation: "wiki"}}
}) 

if result["statusCode"] != 400 && markup.attachments != nil
    puts "Page Created: #{result["id"]}.\nAdding attachments"
    
    # When the markdown file is processed, we keep track of relative links that don't 
    # end with common website extensions and store them in an array `attachments`
    # Attach files that were found in the markdown (via relative links) to the page
    attach = client.auto_attach(result["id"],markup.attachments)

    # To attach a single file manually:
    #attach = client.attach(result["id"],'attachment.txt')
else
    pp result
end

#---
#-> Update a page

# First get the page metadata, the API requires the page ID, an updated version #, and the parent page ID:
 page = client.get({spaceKey: page_space, title: page_title, expand: "version"})[0]  # We're going to update the same page so I'm 
 parent = client.get({spaceKey: page_space, title: page_parent})[0]                  # leaving this the same as above
 page_version = page["version"]["number"] + 1  # When updating, you need to provide Confluence with a new version # (must be incremented)

 new_markup = "This has been updated\n\n" + markup.confluence_markup    # Just prepending some text to show the update worked.

 udpate_result = client.update_page(page["id"],{
     type:"page",
     title: page_title, 
     space: {key: page_space}, 
     ancestors:[{type:"page",id: parent['id']}],
     body: {storage:{value: new_markup, representation: "wiki"}},
     "version":{"number":page_version}
 })

 puts "fin."