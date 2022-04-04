require 'pp'
require 'fileutils'
require 'rubygems'
require 'pathname'
require 'set'
require_relative './lib/md2confluence/md2confluence.rb'
require_relative './lib/confluence-client/confluence-client.rb'

config_file = "../.cloudconfig"

if File.file?(config_file)      # Grab Confluence options from config file (three lines, site on first line, un second, pw third)
    config = File.read(config_file)
    $site        = "#{config.lines[0].strip}/wiki"
    $username    = "#{config.lines[1].strip}"
    $password    = "#{config.lines[2].strip}"        
else  # Set manually (normally you'd want to exit here instead of hard-coding creds, this is for example only):
    $site        = "https://example.atlassian.net/wiki/"    # The full API base url (ex. https://example.atlassian.net/wiki/)
    $username    = "example@gmail.com"                      # The username (ex. example@gmail.com)
    $password    = "yourpassword"                           # The password, for Confluence Cloud you'll need to setup a token https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/
end


# Define where our markdown is
markdown_directory = "./tests"
markdown_files = "*.md"

# Define some confluence info
confluence_space = "EDACRA"                 # The space we're uploading to
confluence_root_name = "Tests"                   

confluence_client = Confluence::Client.new($username, $password, $site)

 # The confluence page that everything will fall under (created if it doesn't exist)
confluence_root = confluence_client.get({spaceKey: confluence_space, title: confluence_root_name})[0]

if confluence_root == nil
    confluence_root = confluence_client.create({
        type:"page",
        title: confluence_root_name, 
        space: {key: confluence_space}, 
        body: {storage:{value: "h1. #{confluence_root_name}", representation: "wiki"}}
    })
    #pp confluence_root     
end

#-
# This will process the entire ./tests directory
# We take the directory structure and use it to build a parent/child page structure on confluence first
process_files = Dir.glob("#{markdown_directory}/**/#{markdown_files}")
structure = Set[]


#pp process_files

process_files.each do |file|
    file_path = Pathname(File.dirname(file)).each_filename.to_a
    temp = file_path[1..-1]
    temp.map! {|t| t.gsub(/_/,"").gsub(/\-/," ").split.map(&:capitalize).join(' ')}
    temp.insert(0,file_path.length)
    structure.add?(temp)  
end

structure = structure.sort_by {|k| k[0]}.reverse    # Sort it by the array size (stored in array[0]) descending.

puts "Building parent pages"
structure.each_with_index do |path,index|
    puts "#{index}: #{path}"
    path.each_with_index do |crumb,crumb_index|
        if crumb_index >= 1
            if page = confluence_client.get({spaceKey: confluence_space, title: crumb})[0]
                puts "--> #{crumb} #{page['id']}"
            else
                # Create the parent page
                parent = confluence_client.get({spaceKey: confluence_space, title: path[crumb_index-1]})[0]
                create_result = confluence_client.create({
                    type:"page",
                    title: crumb, 
                    space: {key: confluence_space}, 
                    ancestors:[{type:"page",id: parent['id']}],
                    body: {storage:{value: "{children:sort=title|style=h4|first=99|depth=4|all=true}", representation: "wiki"}}
                }) 
            end

        end
    end
end


# Now that we know each parent page exists, lets grab the actual files
puts "Building content pages"
process_files.each do |file|
    file_path = Pathname(File.dirname(file)).each_filename.to_a
    file_markup = Confluence::Convert.new(file)      # Convert the current file

    if file_markup.confluence_markup != ""
        parent_name = file_path.last.gsub(/_/,"").gsub(/\-/," ").split.map(&:capitalize).join(' ')
        

        labels = []
        page_labels = {}
        if file_markup.title != ""
            page_title = file_markup.title
        else
            page_title = "#{parent_name}"
        end
        page_version = file_markup.version

        #--
        # Labels
        # First, lets grab the tags from the frontmatter and add them to our labels:
        file_markup.tags.split(/[ ,]/) do |tag|
            labels.push({prefix: "global", name: "#{tag}"})
        end
        
        # Let's add a couple custom labels for this script
        labels.push({prefix: "global", name: "md2confluence"})
        labels.push({prefix: "global", name: "#{file_markup.file_hash}"})

        # Store that hash
        page_labels.store(:labels,labels)

        parent = confluence_client.get({spaceKey: confluence_space, title: parent_name})[0]

        puts "---\nProcessing: #{file}"    
        puts "- #{file} has parent: #{parent_name} with id #{parent['id']}"
        puts "- Title: #{page_title}"
        puts "Attachments: "
        pp file_markup.attachments
        puts "Labels: "
        pp page_labels
        #puts file_markup.confluence_markup

        create_result = confluence_client.create({
            type:"page",
            title: page_title, 
            space: {key: confluence_space}, 
            ancestors:[{type:"page",id: parent['id']}],
            metadata: page_labels,
            body: {storage:{value: file_markup.confluence_markup, representation: "wiki"}}
        }) 

        puts "Status Code: #{create_result["statusCode"]}"

        if !create_result["statusCode"] && file_markup.attachments != nil
            puts "Page: #{create_result["id"]}.\nAdding attachments"
            
            file_markup.attachments.each {|data| data = markdown_directory+data}

            begin
                attach = confluence_client.auto_attach(create_result["id"],file_markup.attachments)
            rescue
                puts "An error happened with attachments #{file_markup.attachments}\n#{attach}"
            end
        elsif create_result['statusCode'].to_int == 500
            pp create_result
        end

    end   
end
