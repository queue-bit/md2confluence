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


# Delete each of the content pages first
process_files.each do |file|
    file_path = Pathname(File.dirname(file)).each_filename.to_a
    file_markup = Confluence::Convert.new(file)      # Convert the current file

    if file_markup.confluence_markup != ""
        puts "\nProcessing: #{file}"    
        if file_markup.title != ""
            page_title = file_markup.title
        else
            page_title = "#{page_title}"
        end

        if page = confluence_client.get({spaceKey: confluence_space, title: page_title})[0]                
            confluence_client.delete(page['id'])
        end
        
    end   
end

# Then the parent pages
structure.each_with_index do |path,index|
    puts "#{index}: #{path}"
    path.each_with_index do |crumb,crumb_index|
        if crumb_index >= 1 and crumb != confluence_root_name
            if page = confluence_client.get({spaceKey: confluence_space, title: crumb})[0]                
                confluence_client.delete(page['id'])
            end
        end
    end
end
