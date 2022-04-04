require 'pp'
require 'fileutils'
require 'rubygems'
require_relative './lib/md2confluence/md2confluence.rb'
require_relative './lib/confluence-client/confluence-client.rb'


config_file = "../.cloudconfig"

if File.file?(config_file)      # Grab Confluence options from config file (three lines, site on first line, un second, pw third, space fourth, root page fifth)
    config = File.read(config_file)
    $site        = "#{config.lines[0].strip}/wiki"
    $username    = "#{config.lines[1].strip}"
    $password    = "#{config.lines[2].strip}"        
    $space       = "#{config.lines[3].strip}"
    $root        = "#{config.lines[4].strip}"
else  # Set manually (normally you'd want to exit here instead of hard-coding creds, this is for example only):
    $site        = "https://example.atlassian.net/wiki/"    # The full API base url (ex. https://example.atlassian.net/wiki/)
    $username    = "example@gmail.com"                      # The username (ex. example@gmail.com)
    $password    = "yourpassword"                           # The password, for Confluence Cloud you'll need to setup a token https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/
    $space       = "yourconfluencespace"                    # Your Confluence Space name
    $root        = "yourconfluencepage"                     # The page's parent, the page everything else will fall under
end

# The file to process:
#markdown_file = "./tests/example-single-page.md" 
markdown_file = "./tests/_kubernetes/2021-07-04-bare-metal-setup.md" 

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
page_space = $space                   
page_parent = $root                
page_title = markup.title
page_version = markup.version
labels = []
page_labels = {}

# Get the metadata of the page's parent
parent = client.get({spaceKey: page_space, title: page_parent})[0]

#---
#-> Create a page


#--
# Labels
# First, lets grab the tags from the frontmatter and add them to our labels:
markup.tags.split(/[ ,]/) do |tag|
    labels.push({prefix: "global", name: "#{tag}"})
end

# Let's add a couple custom labels for this script
labels.push({prefix: "global", name: "md2confluence"})
labels.push({prefix: "global", name: "#{markup.file_hash}"})

# Store that hash
page_labels.store(:labels,labels)


# Create the page
result = client.create({
    type:"page",
    title: page_title, 
    space: {key: page_space}, 
    ancestors:[{type:"page",id: parent['id']}],
    metadata: page_labels,
    body: {storage:{value: markup.confluence_markup, representation: "wiki"}}
}) 

pp markup.confluence_markup

if !result["statusCode"] && markup.attachments != nil
    puts "Page Created: #{result["id"]}.\nAdding attachments"
    
    # When the markdown file is processed, we keep track of relative links that don't 
    # end with common website extensions and store them in an array `attachments`
    # Attach files that were found in the markdown (via relative links) to the page
    begin
        attach = client.auto_attach(result["id"],markup.attachments)
    rescue
        puts "An error happened with attachments #{markup.attachments}"
    end

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