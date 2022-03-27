require 'json'
require 'faraday'
require 'faraday/adapter/net_http'

# Inspired by https://github.com/amishyn/confluence-api-client/blob/master/lib/confluence/api/client.rb

module Confluence
    class Client
        attr_accessor :username, :password, :site, :confluence

        def initialize(username,password,site)
          
            self.confluence = Faraday.new(url: site) do |f|
                #f.response :logger 
                f.request :multipart
                f.request :url_encoded
                f.adapter :net_http 
                f.basic_auth(username,password)
            end
        end

        def get_by_id(id)
            response = confluence.get('/rest/api/content/' + id)
            JSON.parse(response.body)
        end

        def get_by_params(params)
            response  = confluence.get('rest/api/content', params)
            JSON.parse(response.body)['results']
        end
        alias :get :get_by_params

        def create_page(params)
            response = confluence.post do |req|
                req.url 'rest/api/content'
                req.headers['Content-Type'] = 'application/json'
                req.body                    = params.to_json
              end
              JSON.parse(response.body)
        end
        alias :create :create_page

        def update_page(id,params)
            response = confluence.put do |req|
                req.url "rest/api/content/#{id}"
                req.headers['Content-Type'] = 'application/json'
                req.body                    = params.to_json
              end
              JSON.parse(response.body)            
        end

        def get_attachment_meta(id,filename)
            response = confluence.get("rest/api/content/#{id}/child/attachment?filename=#{filename}")
            JSON.parse(response.body)['results'][0]
        end

        def delete(id,version = nil)
            # delete(id,version) handles both pages and attachments
            # version is only required if you want to delete a specific version of the page/attachment
            # You do not need to delete attachments before deleting a page

            if version == nil
                url = "rest/api/content/#{id}"
            elsif version != nil && version > 0
                url = "rest/api/content/#{id}/version/#{version}"
            else
                raise 'ERROR: Version has been passed but is not valid'
            end

            response = confluence.put do |req|
                req.url url
                req.method = "DELETE"
                req.headers['Content-Type'] = 'application/json'
                req.headers['Accept'] = 'application/json'
            end
            response.status
        end


        def set_mime(file_uri)
            # Matches up against a common list of mime-types

            mime_types_common = {
                '.aac'   => 'audio/aac',
                '.abw'   => 'application/x-abiword',
                '.arc'   => 'application/x-freearc',
                '.avif'  => 'image/avif',
                '.avi'   => 'video/x-msvideo',
                '.azw'   => 'application/vnd.amazon.ebook',
                '.bin'   => 'application/octet-stream',
                '.bmp'   => 'image/bmp',
                '.bz'    => 'application/x-bzip',
                '.bz2'   => 'application/x-bzip2',
                '.cda'   => 'application/x-cdf',
                '.csh'   => 'application/x-csh',
                '.css'   => 'text/css',
                '.csv'   => 'text/csv',
                '.doc'   => 'application/msword',
                '.docx'  => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                '.eot'   => 'application/vnd.ms-fontobject',
                '.epub'  => 'application/epub+zip',
                '.gz'    => 'application/gzip',
                '.gif'   => 'image/gif',
                '.htm'   => 'text/html',
                '.html'  => 'text/html',
                '.ico'   => 'image/vnd.microsoft.icon',
                '.ics'   => 'text/calendar',
                '.jar'   => 'application/java-archive',
                '.jpg'   => 'image/jpeg',
                '.jpeg'  => 'image/jpeg',
                '.js'    => 'text/javascript',
                '.json'  => 'application/json',
                '.jsonld'=> 'application/ld+json',
                '.midi'  => 'audio/midi',
                '.mid'   => 'audio/midi',
                '.mjs'   => 'text/javascript',
                '.mp3'   => 'audio/mpeg',
                '.mp4'   => 'video/mp4',
                '.mpeg'  => 'video/mpeg',
                '.mpkg'  => 'application/vnd.apple.installer+xml',
                '.odp'   => 'application/vnd.oasis.opendocument.presentation',
                '.ods'   => 'application/vnd.oasis.opendocument.spreadsheet',
                '.odt'   => 'application/vnd.oasis.opendocument.text',
                '.oga'   => 'audio/ogg',
                '.ogv'   => 'video/ogg',
                '.ogx'   => 'application/ogg',
                '.opus'  => 'audio/opus',
                '.otf'   => 'font/otf',
                '.png'   => 'image/png',
                '.pdf'   => 'application/pdf',
                '.php'   => 'application/x-httpd-php',
                '.ppt'   => 'application/vnd.ms-powerpoint',
                '.pptx'  => 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
                '.rar'   => 'application/vnd.rar',
                '.rtf'   => 'application/rtf',
                '.sh'    => 'application/x-sh',
                '.svg'   => 'image/svg+xml',
                '.swf'   => 'application/x-shockwave-flash',
                '.tar'   => 'application/x-tar',
                '.tiff'  => 'image/tiff',
                '.tif'   => 'image/tiff',
                '.ts'    => 'video/mp2t',
                '.ttf'   => 'font/ttf',
                '.txt'   => 'text/plain',
                '.vsd'   => 'application/vnd.visio',
                '.wav'   => 'audio/wav',
                '.weba'  => 'audio/webm',
                '.webm'  => 'video/webm',
                '.webp'  => 'image/webp',
                '.woff'  => 'font/woff',
                '.woff2' => 'font/woff2',
                '.xhtml' => 'application/xhtml+xml',
                '.xls'   => 'application/vnd.ms-excel',
                '.xlsx'  => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                '.xml'   => 'application/xml',
                '.xul'   => 'application/vnd.mozilla.xul+xml',
                '.zip'   => 'application/zip',
                '.3gp'   => 'video/3gpp',
                '.3g2'   => 'video/3gpp2',
                '.7z'    => 'application/x-7z-compressed'
            }
            file = File.basename(file_uri.gsub("\\","/"))
            file_type = mime_types_common[File.extname(file).downcase]
                      
            if file_type
                file_type
            else
                nil
            end
        end

        def add_attachment(id,file_uri,mime_type)            
            headers = {'Content-Type'=>'multipart/form-data','Accept'=>'application/json', 'X-Atlassian-Token' => 'no-check', 'minorEdit' =>  'true'}
            payload = { :file => Faraday::UploadIO.new(file_uri, mime_type) }  
            response = confluence.post("rest/api/content/#{id}/child/attachment",payload,headers)
            JSON.parse(response.body)
        end

        def auto_attach(id,attachments)
            attachments.each do |file|                
                update_attachment(id,file)
            end
        end


        def update_attachment(page_id,file_uri,mime_type=nil)

            if mime_type == nil
                mime_type = set_mime(file_uri)
            end
            
            file = File.basename(file_uri.gsub("\\","/"))
            
            # run get_attachment_meta to get the attachment ID
            attachment_meta = get_attachment_meta(page_id,file)

            if attachment_meta && mime_type != nil # If an attachment with this filename exists, update it
                attachment_id = attachment_meta["id"]
                headers = {'Content-Type'=>'multipart/form-data','Accept'=>'application/json', 'X-Atlassian-Token' => 'no-check', 'minorEdit' =>  'true'}
                payload = { :file => Faraday::UploadIO.new(file_uri, mime_type) }  
                response = confluence.post("rest/api/content/#{page_id}/child/attachment/#{attachment_id}/data",payload,headers)
                JSON.parse(response.body)
            elsif !attachment_meta && mime_type != nil    # If it doesn't, create it
                add_attachment(page_id,file_uri,mime_type)
            else
                raise 'ERROR: in `update_attachment(page id, file uri, mime type)`, couldn\'t match the file extension to a common MIME type, please pass the correct MIME-type'
            end
        end
        alias :attach :update_attachment

    end
end