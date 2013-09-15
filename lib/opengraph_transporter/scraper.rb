module OpengraphTransporter
  class Scraper

    MAX_FB_LOGIN_ATTEMPTS = 3
    MAX_TRANSLATION_PAGE_LIMIT = 30
 
    class << self
  
      def ingest_app_translations(app_id, locale)
        @agent = Mechanize.new
        # Defaulting to en_US native locale
        source_app_uri = "https://www.facebook.com/translations/admin/browse.php?search&sloc=en_US&aloc=#{locale}&app=#{app_id}"
        @agent.get(source_app_uri)
        login_attempt = 1
        login(login_attempt) do |continue|
          if continue
            puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  login current_url  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
            puts @agent.page.uri.to_s
            puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
            translations_page_index = 0
            translations_arr = Array.new 
            GracefulQuit.enable
            recurse_translations(translations_page_index, translations_arr) do |complete_translation_arr, idx|
              logout
              return complete_translation_arr
            end
          else
            return []
          end
        end
      end

      def update_display_names!(translations_arr, src_display_name, dst_display_name)
        say(".....swapping app translation tokens")
        translation_src_name =  "{" << src_display_name << "}"
        translation_dst_name =  "{" << dst_display_name << "}"
        translations_arr.each_with_index do |el, index|
          
          if el['native'] =~ /(#{Regexp.escape(translation_src_name)})/i 
            app_name = "#{$1}".strip
            unless app_name.eql?("application")
              el['native'].gsub!(/(#{Regexp.escape(translation_src_name)})/i , "#{translation_dst_name}")
              el['translation'].gsub!(/(#{Regexp.escape(translation_src_name)})/i, "#{translation_dst_name}")
            end
          end
        end
        
        return translations_arr
      end

      private

      def recurse_translations(translations_page_index, translations_arr, &block)
        GracefulQuit.check do
          logout
        end
        next_button = @agent.page.link_with(:text => "Next")
        say(".....processing translations page: " << (translations_page_index + 1).to_s)
        bundle_translations(translations_arr, translations_page_index)
        translations_page_index += 1

        if next_button.nil? || translations_page_index > MAX_TRANSLATION_PAGE_LIMIT
          say(".....completed application translations ingest.") 
          block.call(translations_arr, translations_page_index) if block_given? 
        else
          next_button.click
          recurse_translations(translations_page_index, translations_arr, &block) if block_given? 
        end
      end

      def bundle_translations(translations_arr, translations_page_index)
        form = @agent.page
        form.search('*').select{|e| e[:class] =~ /all_variations/}.each_with_index { |item, index|
          native = item.search('*').select{|f| f[:class] =~ /native/}.first.text
          translation = item.search('*').select{|f| f[:class] =~ /s_trans/}.first.text
          say("#{native} : #{translation}") 
          
          unless native.empty? 
            native_hash = item.attributes['id'].text.sub("variants:","")
            translations_arr.push({:native_hash => native_hash, :native => native, :translation => translation})
          end
        }
      end

      def login(login_attempt, &block)
        
        if login_attempt <= MAX_FB_LOGIN_ATTEMPTS
          get_user_credentials
          say("\n.....logging in to Facebook")
          form = @agent.page.forms.first
          form.email = Base.user[:fb_username]
          form.pass = Base.user[:fb_password]
          @agent.submit(form, form.buttons.first)

          if @agent.page.uri.to_s =~ /login_attempt/
            # FB Login error
            choose do |menu|
              menu.prompt = "Facebook Login failed..... attempt #{login_attempt}. Would you like to try again?  "
              menu.choice(:Yes) { 
                login_attempt += 1
                login(login_attempt, &block) if block_given? 
              }
              menu.choices(:No) { 
                say("...exiting Exporter!") 
                block.call(false) if block_given? 
              }
            end
          else
             block.call(true) if block_given? 
          end
        else
          block.call(false) if block_given? 
        end
      end

      def logout
        say(".....logging out of Facebook \n")
        puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  logout current_url  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        puts @agent.page.uri.to_s
        puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        form = @agent.page.form_with(:id => 'logout_form')
        @agent.submit(form, form.buttons.first)
      end

      def get_user_credentials
        Base.user[:fb_username] = ask("Facebook Username:  ", lambda { |u| u.to_s.strip } ) do |q|
          q.validate              = lambda { |p|  (p =~ /^.+@.+$/) != nil }
          q.responses[:not_valid] = "Please enter a valid email address."
        end
        Base.user[:fb_password] = ask("Password:  ") { |q| q.echo = "*" }
      end

    end
  
  end
end