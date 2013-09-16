module OpengraphTransporter 
  class Base

    class << self

      @@translation = nil
      @@user = {}

      def run
        setup
        say("<%= color('Preparing Translations....', YELLOW, BOLD) %>")   
        prepare
        Common.show_translations_info(translation)
        say("<%= color('Process existing Destination application Translations (#{Base.translation[:dst_app_name]} native stubs) ....', YELLOW, BOLD) %>")
        run_export
      end

      def translation
        @@translation
      end
      
      def translation=(value)
        @@translation = value
      end

      def user
        @@user
      end
      
      def user=(value)
        @@user = value
      end

      def inspect
        "<#{self.name} user: #{user} translation: #{translation.inspect} >"
      end

      def to_s
        inspect
      end
     
      private

      def setup
        display_app_splash
        get_apps_details
        self      
      end

      def run_export
       translation[:dst_translation_arr] = Scraper.ingest_app_translations(translation[:destination_application_id], translation[:app_locale], translation[:primary_locale])
       if translation[:dst_translation_arr].length == 0
         say("No destination app <%= color('(#{Base.translation[:dst_app_name]})', RED, BOLD) %> Open Graph Translations found, please check that Open Graph stories exist and locales are correct.")  
       else
         translation[:src_translation_arr] = Scraper.update_display_names!(translation[:src_translation_arr], translation[:src_app_name].to_s, translation[:dst_app_name].to_s)
         translations_cleanup
         say("<%= color('Export Translations....', YELLOW, BOLD) %>")  
         choose do |menu|
           menu.prompt = "This action will overwrite existing #{translation[:dst_app_name]} translations. Are you sure you want to export translations?"
           menu.choice(:Yes) { 
            say("....starting Export!")
            Browser.export
           }
           menu.choices(:No) { say("...exiting Exporter!") }
         end
       end
      end

      def prepare 
        src_translation_arr =  Common.get_application_translations(translation[:source_app_token], translation[:app_locale], false)
        dst_translation_arr =  Common.get_application_translations(translation[:destination_app_token], translation[:app_locale], true)
        translation[:src_translation_arr] = src_translation_arr
        translation[:dst_translation_arr] = dst_translation_arr

        if translation[:src_translation_arr].nil?
          Common.show_arguments_info(translation)
          say("<%= color('Invalid application data, please recheck application and locale settings.', RED, BOLD) %>")
          exit
        end
      end

      def get_apps_details(error_keys = [])
        invalid_entries = false
        initialize_translation
       
        translation.each do |key, val|
          if val.empty? || error_keys.include?(key.to_s)
            invalid_entries = true
            case key 
            when :source_application_id then translation[key] = ask_for_app_id(key).to_s
            when :source_application_secret then translation[key] = ask_for_app_secret(key)
            when :destination_application_id then translation[key] = ask_for_app_id(key).to_s
            when :destination_application_secret then translation[key] = ask_for_app_secret(key)
            else translation[key] = ask("\nPlease Enter <%= color('#{capitalize(key)}', GREEN, BOLD) %>", String)
            end
          end
        end

        if invalid_entries
          validate_applications_data
        end
      end

      def validate_applications_data
        locales = generate_locales
        error_keys = []
        
        if translation[:source_application_id].empty?  
          error_keys << "source_application_id"
        end
        if translation[:source_application_secret].empty? 
          error_keys << "source_application_secret"
        end
        if translation[:destination_application_id].empty? 
          error_keys << "destination_application_token"
        end
        if translation[:destination_application_secret].empty?
          error_keys << "destination_application_secret"
        end 
        if translation[:source_application_id].eql?(translation[:destination_application_id])
          say("<%= color('Duplicated selection: ', RED, BOLD) %> please selection different source and destination applications. \n")
          error_keys << "destination_application_id"  << "destination_application_secret"
        end
        if translation[:app_locale].empty? 
          error_keys << "app_locale"
        elsif translation[:primary_locale].empty? 
          error_keys << "primary_locale"
        else
          if !locales.include?(translation[:app_locale])
            error_keys << "app_locale"
          end
          if !locales.include?(translation[:primary_locale])
            error_keys << "primary_locale"
          end
        end
  
        if !error_keys.empty?
          say("<%= color('Invalid Data: ', RED, BOLD) %> #{error_keys.join(' ')} \n")
          choose do |menu|
            menu.prompt = "Re-enter app details?"
            menu.choice(:Yes) { 
              get_apps_details(error_keys)
            }
            menu.choices(:No) { 
              say("...exiting Exporter!") 
              exit
            }
          end
        else
          get_app_specfics
        end
      end

      def generate_locales
        locales_arr = []   
        app_root = File.expand_path(File.dirname(__FILE__))
        fb_locales_doc = File.open(File.join(app_root, "/resources/FacebookLocales.xml"))
        locales = Nokogiri::XML(fb_locales_doc)
        
        locales.xpath("//representation").each do |locale|
          locales_arr << locale.text
        end
        
        return locales_arr
      end

      def get_app_specfics
        say("\n.....retrieving app tokens")
        translation[:source_app_token] = Common.get_app_token(translation[:source_application_id], translation[:source_application_secret]) 
        translation[:destination_app_token] = Common.get_app_token(translation[:destination_application_id], translation[:destination_application_secret]) 
        
        translation[:src_app_name] = Common.get_application_name(translation[:source_app_token], translation[:source_application_id]) 
        translation[:dst_app_name] = Common.get_application_name(translation[:destination_app_token], translation[:destination_application_id]) 
      end

      def initialize_translation
        @@translation ||= {:source_application_id => '', :source_application_secret => '', :destination_application_id => '', :destination_application_secret => '', :primary_locale => '', :app_locale => '' }
      end

      def translations_cleanup
         Common.update_destination_translations(translation)
         Common.remove_empty_translations(translation)
         Common.show_translations_info(translation)
      end

      def capitalize(sym)
        sym.to_s.split('_').map(&:capitalize).join(' ')
      end

      def ask_for_app_id(translation_key)
        ask("\nPlease Enter <%= color('#{capitalize(translation_key)}', GREEN, BOLD) %>", lambda { |id| id.to_s.strip } ) do |q| 
          q.validate              = lambda { |p|  (p =~ /^\d{15}$/) != nil }
          q.responses[:not_valid] = "Please enter a 15 digit App Id."
        end
      end

      def ask_for_app_secret(translation_key)
        ask("\nPlease Enter <%= color('#{capitalize(translation_key)}', GREEN, BOLD) %>", lambda { |id| id.to_s.strip } ) do |q| 
          q.validate              = lambda { |p|  (p =~ /^[a-zA-Z0-9]{32}$/) != nil }
          q.responses[:not_valid] = "Please enter a 32 character alphanumeric App Secret."
        end
      end

      def display_app_splash
        puts "\n"
        splash = ConsoleSplash.new(6, 88)
        splash.write_horizontal_pattern("||")
        splash.write_vertical_pattern("||")
        splash.write_center(-4, "Open Graph Translations Exporter")
        splash.write_center(-3, "Version: #{OpengraphTransporter::VERSION}")
        splash.splash
        puts "\n"
      end

    end


  end
end