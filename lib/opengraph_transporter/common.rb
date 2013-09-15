module OpengraphTransporter
  
  class Common

    FB_GRAPH_HOST = "https://graph.facebook.com"

    class << self

      def update_destination_translations(translation)
        say(".....updating translation text")
        translation[:dst_translation_arr].each do |dst_translation| 
          translation[:src_translation_arr].each do |src_translation| 
            if dst_translation[:native].eql?(src_translation['native'])
              dst_translation[:translation] = src_translation['translation']
            end
          end
        end
      end

      def remove_empty_translations(translation)
        say(".....remove empty translations")
         translation[:dst_translation_arr].each_with_index do |dst_translation, index| 
           if dst_translation[:translation].empty?
             translation[:dst_translation_arr].delete_at(index)
           end 
        end
      end

      def get_application_translations(app_token, app_locale, include_hash)
        if include_hash
          fql = %Q{select native_hash, native_string, best_string FROM translation WHERE locale = "#{app_locale}"}
          mappings = {"native_hash" => "native_hash", "native_string" => "native", "best_string" => "translation"}
        else
          fql = %Q{select native_string, best_string FROM translation WHERE locale = "#{app_locale}"}
          mappings = {"native_string" => "native", "best_string" => "translation"}
        end
        
        params = {:access_token => app_token, :q => fql}
        request = 'fql'
        app_translations = fb_graph_call(request, params)['data']
        @app_translations = Array.new
        
        app_translations.each do |translation| 
          @app_translations.push(Hash[translation.map {|k, v| [mappings[k], v] }])
        end
         
        if !include_hash
          @app_translations = @app_translations.uniq!
        end
        return @app_translations
      end

      def get_application_details(app_token, app_id)
        fql = %Q{select display_name, description, link, namespace from application where app_id = #{app_id}}
        params = {:access_token => app_token, :q => fql}
        request = 'fql'
        response = fb_graph_call(request, params)
        return response['data'][0]
      end

      def show_translations_info(translation)
        say("<%= color('\n***********************************************************************************************************', YELLOW, BOLD) %>")
        say("Source Application ID:      <%= color('#{translation[:source_application_id]}', BOLD) %>    Existing translations: <%= color('#{translation[:src_translation_arr].length}', YELLOW, BOLD) %>    Application Name: <%= color('#{translation[:src_app_name]}', BOLD) %>")
        say("Destination Application ID: <%= color('#{translation[:destination_application_id]}', BOLD) %>    Existing translations: <%= color('#{translation[:dst_translation_arr].length}', YELLOW, BOLD) %>    Application Name: <%= color('#{translation[:dst_app_name]}', BOLD) %>")
        say("<%= color('***********************************************************************************************************\n', YELLOW, BOLD) %>")
      end


      def show_arguments_info(translation)
        say("<%= color('\n***********************************************************************************************************', YELLOW, BOLD) %>")
        say("Source Application ID:      <%= color('#{Base.translation[:source_application_id]}', YELLOW, BOLD) %>     Application Name: <%= color('#{Base.translation[:src_app_name]}', YELLOW, BOLD) %>")
        say("Destination Application ID: <%= color('#{Base.translation[:destination_application_id]}', YELLOW, BOLD) %>     Application Name: <%= color('#{Base.translation[:dst_app_name]}', YELLOW, BOLD) %>")
        say("Selected Locale:      <%= color('#{Base.translation[:app_locale]}', YELLOW, BOLD) %>")
        say("<%= color('***********************************************************************************************************\n', YELLOW, BOLD) %>")
      end

      def get_application_name(app_token, app_id)
        params = {:access_token => app_token}
        request = "#{app_id}"
        response = fb_graph_call(request, params)
        if response.nil?
          show_arguments_info(translation)
          say("<%= color('Invalid application data, please recheck application and locale settings.', RED, BOLD) %>")
          exit
        end
        return response['name']
      end

      # Borrowing heavily from Bookface
      def get_app_token(app_id, app_secret)
        say(".....retrieving app tokens")
        params = {
          :client_id => app_id,
          :client_secret => app_secret,
          :grant_type => 'client_credentials'
        }
        path = "/oauth/access_token"
        response = fb_graph_call(path, params, {:format => :text})
        
        dummy = Addressable::URI.new
        dummy.query = response
        access_token = dummy.query_values["access_token"]

        return access_token
      end


      private

      # Borrowing heavily from Bookface
      def fb_graph_call(path, params = {}, options = {})
        clnt = HTTPClient.new
        uri = Addressable::URI.parse(FB_GRAPH_HOST)
        uri.path = path
        query = params
        # default to JSON response
        options = {:format => :json}.merge(options)
        begin
          response = clnt.get(uri, query)
          if response.status == 200
            case options[:format]
            when :text then response.body
            else JSON.parse(response.content)
            end
          end
        rescue StandardError => e
          say("Graph Call error: #{e}")
          say("...exiting Exporter!")
          exit
          # raise e
        end
      end

      # unused
      def write_csv(translations_arr)
        unless translations_arr.length == 0
          csv_file_name = "appid_#{@translation[:source_application_id]}.csv"
          csv_tmp_file = Tempfile.new(csv_file_name)
          headers_arr = Array.new
          translations_arr[0].each_key {|key| headers_arr.push(key) }
          
          CSV.open(csv_tmp_file, "w") do |csv|
            csv << headers_arr
            translations_arr.each do |el|
              csv << el.values
            end 
          end
          
          send_file csv_tmp_file, :type => 'text/csv', :disposition => 'download', :filename => csv_file_name
          csv_tmp_file.close
          csv_tmp_file.unlink
        end
      end

    end

  end
end