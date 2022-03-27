require 'digest/md5'
require 'json'

module Confluence
    class Convert
        attr_accessor :space, :parent, :title, :version, :toc, :confluence_markup, :file_hash, :attachments

        def initialize(process_file, space=nil,parent=nil,title=nil,version=nil,toc=nil)
            space != nil ? @space = space : @space = ""
            parent != nil ? @parent = parent : @parent = ""
            title != nil ? @title = title : @title = ""
            version != nil ? @version = version : @version = ""
            toc != nil ? @toc = toc : @toc = "true"
            @confluence_markup = ""
            @file_hash = nil

            process_file(process_file)
        end        

        def process_file(process_file)

            raw_md          = ""                        # Stores that raw markdown without the frontmatter
            needle          = "---\n"                   # The demarc of config settings in the .md file
            needle_status   = FALSE                     # Status toggle, TRUE if we're inside the config settings of the file, FALSE if we're not.
            indent          = 1                         # Number of spaces at start of line, used for lists
            li_levels       = []                        # Array, stores the indent values when parsing lists
            in_list         = FALSE                     # List flag    
            in_code         = FALSE                     # Code block flag
            in_table        = FALSE                     # Table block flag
            table_header    = TRUE                      # Table header flag, we assume it's true until we're in a table
            @attachments = []

            if File.file?(process_file)
        
                @file_hash = Digest::MD5.hexdigest(File.read(process_file))
        
                IO.foreach(process_file).each_with_index do |line,index|
        
                    # Check if the current line is a needle, if yes -> we're in the frontmatter, toggle needle_status and go to next line
                    if line == needle && needle_status == FALSE && index < 9
                        needle_status = TRUE
                        next
                    elsif line == needle && needle_status == TRUE && index < 9
                        needle_status = FALSE
        
                        if @version != ""
                            raw_md += "{panel}Version: #{@version}{panel}\n"
                        end
        
                        if @toc == "true"
                            raw_md += "{toc:printable=true|style=none|maxLevel=2|indent=20px|type=list|outline=true|include=.*}\n\n"
                        end
        
                        next
                    end
        
                    # If we're between the needles we need to grab the metadata out of the file
                    if needle_status == TRUE
                        if line =~ /^space:\s+?(.*?)$/
                            @space = line.split(":")[1].tr('"','').strip
                        elsif line =~ /^parent:\s+?(.*?)$/
                            @parent = line.split(":")[1].tr('"','').strip
                        elsif line =~ /^title:\s+?(.*?)$/
                            @title = line.split(":")[1].tr('"','').strip
                        elsif line =~ /^version:\s+?(.*?)$/
                            @version = line.split(":")[1].tr('"','').strip
                        elsif line =~ /^toc:\s+?(.*?)$/
                            @toc = line.split(":")[1].tr('"','').strip
                        end            
                    elsif needle_status == FALSE

                        if line != "\n"
                            indent = line.length - line.lstrip.length + 1
        
                            # Handle headers
                            if line =~ /^\s*?\#{1,6}\s+?(.*?)$/
                                header_level = line.count "#"
                                headers = ["h1","h2","h3","h4","h5","h6","h7","h8"]
                                line = line.lstrip.sub(/(\#{1,6}\s+?)/,"#{headers[header_level - 1]}. ") 
                            end
        
                            # Handle Italic
                            if line =~ /\s\*{1}[\w\ \t]+?\*{1}\s/
                                line = line.lstrip.gsub(/(\*)/,"_") 
                            end

                            # Handle Bold
                            if line =~ /\s\*{2}[\w\ \t]+?\*{2}\s/
                                line = line.lstrip.gsub(/(\*\*)/,"*") 
                            end        
        
                            # Handle Quotes (this needs work)
                            if line =~ /^\s*?\>/
                                line = line.lstrip.sub(/\>/,"bq.") 
                            end
                       

                            # Handle inline code
                            line.scan(/\`(.{2,}?)\`/).each do |inline_line|
                                line["`#{inline_line[0]}`"] = "{{#{inline_line[0]}}}"
                            end


                            # Handle Code Block
                            if line =~ /\`\`\`/ && in_code == FALSE
                                in_code = TRUE
                                line = "{code}\n"
                            elsif line =~ /\`\`\`/ && in_code == TRUE
                                in_code = FALSE        
                                line = "{code}\n"
                            end    

                            # Handle text breaks
                            #if line =~ /^\n$/
                            #    line = "//"
                            #end

                            # Handle Horizontal Rules/Lines
                            if line =~ /^---$/ && in_code == FALSE
                                line = "----"
                            end                            

                            # Handle Links & Images
                            line.scan(/\!?\[.*?\]\(.*?\)/).each do |inline_line|
                                link_alias = inline_line.slice(/\[(.*)\]/,1)
                                link_url = inline_line.slice(/\(([\w\:\/\/\-\_\#\.\@]*)/,1)
                                link_tip = ""
                                link_attribute = ""
                                link_ext = link_url.slice(/\w+?\.([a-z0-9\-]{3,5})/,1)
                                attachment = FALSE

                                if link_url !~ /(?:http|https|rss|ftp|sftp)/ && link_ext !~ /(?:html|htm|asp|aspx|cf|php|com)/ 
                                    @attachments.push(link_url)
                                    attachment = TRUE
                                    link_url = link_url.slice(/(\w+?\.[a-z0-9\-]{3,5})/)
                                end 

                                if inline_line =~ /\!\[/  # Image
                                    link_attribute = line.slice(/\(.* \"(.*?)\".*?\)/,1)
                                    line = line.sub(inline_line,"!#{link_url}#{'|' + link_attribute unless link_attribute.nil?}!")                           
                                elsif inline_line !~ /\!\[/ && !attachment  # Link to another place
                                    link_tip = line.slice(/\(.* \"(.*?)\".*?\)/,1)
                                    line = line.sub(inline_line,"[#{link_alias+'|' unless link_alias.nil?}#{link_url}#{'|' + link_tip unless link_tip.nil?}]")
                                else #  Link to an attachment
                                    link_attribute = line.slice(/\(.* \"(.*?)\".*?\)/,1)
                                    line = line.sub(inline_line,"[#{@title}^#{link_url}]")
                                end

                            end
        
                            
                            # Handle table
                            if line =~ /^\s*?\|.*?\|/ && in_table == FALSE
                                in_table = TRUE
                                table_header = TRUE
                            elsif line !~ /^\s*?\|.*?\|/ && in_table == TRUE
                                in_table = FALSE
                            end
        
                            # In a table, we need to strip out any row directly after the header
                            if in_table && line =~ /\s*?\|[ \-\:\+]{1,5}\|[ \-\:\+]{1,5}\|/
                                line=""
                            end
        
                            if in_table && table_header
                                line = line.lstrip.gsub(/\|/,"||")
                                table_header = FALSE
                            end
        
                         
        
                            # Handle lists - nested lists are a pain:
                            # We get the number of characters used in the `indent` then see if it exists in the `li_levels` array
                            # If it doesn't exist, check if the `indent` is > the last item in the `li_levels` array
                            #       If yes, then push it onto the array and get the array index for that value
                            #       If no, find the closest match in the array and get the array index for that value
                            # If it does exist, get the index for that `indent` value
                            # If indent for the line is == 1 then clear the array and start over (add `1` once cleared)                            
                            
                            if line =~ /^\s*?\d{1,3}?\.(.*?)$/ || line =~ /^\s*?[\-\*]\s+?(.*?)$/
        
                                if in_list == FALSE 
                                    in_list = TRUE                            
                                    li_levels.push(indent)
                                end
        
                                if !li_levels.include?(indent)
                                    if li_levels.last < indent
                                        li_levels.push(indent)                                                        
                                        li_level = li_levels.find_index(indent)
                                    else
                                        closest = li_levels.min_by{|x| (indent-x).abs}
                                        li_level = li_levels.find_index(closest)
                                    end
                                else
                                    li_level = li_levels.find_index(indent)
                                end              
         
                                if indent == 1  # if we're back at 1, then clear the array and start over
                                    li_levels.clear()
                                    li_levels.push(1)
                                end                        
        
                                if line =~ /^\s*?\d{1,3}?\.(.*?)$/
                                    temp = line.lstrip.sub(/\d+?\./,"")
                                    line = "#" * (li_level+1) + temp.rstrip + "\n"
                                elsif line =~ /^\s*?[\-\*]\s+?(.*?)$/
                                    temp = line.lstrip.sub(/^\W*?[\-\*]+?/,"")
                                    line = "*" * (li_level+1) + temp.rstrip + "\n"
                                else
                                    in_list = FALSE  
                                    li_levels.clear()
                                end 
                            end # handle lists
                              
                            #if line =~ /<br/
                            #    line = "\n"
                            #end
            
                        else 
                            indent = 0
                        end
                        raw_md += line
                        
                    else
                        puts "Error, needle_status is #{needle_status} but must be either TRUE or FALSE"
                    end
                end
                
                @confluence_markup = raw_md
            else
                raise "Error: md2confluence couldn't find the specified file: #{process_file}"
            end
        end

    end
end