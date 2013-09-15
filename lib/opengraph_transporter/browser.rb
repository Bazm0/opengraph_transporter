module OpengraphTransporter
  
  class Browser

    MAX_TRANSLATION_PAGE_LIMIT = 30

    class << self

      def export
        Watir.driver = :webdriver
        @browser = Watir::Browser.new :firefox
        @page_index_counter = 0
        @translation_count_index = 0
        @translation = Base.translation
        @translation_arr = @translation [:dst_translation_arr].clone
        fb_login

        developer_translations_home_uri = "https://www.facebook.com/translations/admin/browse.php?search=&sloc=en_US&aloc=#{@translation[:app_locale]}&app=#{@translation[:destination_application_id]}"
        @browser.goto developer_translations_home_uri
        GracefulQuit.enable
        parse_translation_rows
      end

      private

      def parse_translation_rows
         @translation_arr.each_with_index do |translation, index|
           row_hash = "variant:" << translation[:native_hash]
           translation_row = @browser.tr(:id, row_hash)
           if translation_row.exists? && !translation[:translation].empty?
             say("updating translation native hash: #{translation[:native_hash]} : #{translation[:translation]}")
             translation_row.td(:class, /s_trans/).click
             translation_row.textarea(:class, /uiTextareaAutogrow/).set translation[:translation]
             translation_row.button(:id, /submit:/).click
             sleep(0.25)
             @translation_count_index += 1
           end  
           GracefulQuit.check
         end    
         process_next_page
      end

      def process_next_page
        next_button = @browser.div(:class => "pagerpro_container").link(:text => /Next/)
        if next_button.exists? && @page_index_counter < MAX_TRANSLATION_PAGE_LIMIT
          begin
            translations_page = @page_index_counter + 1
            say("processing translation page.... #{translations_page + 1}")
            @page_index_counter += 1
            next_button.click
            sleep(2.5)
            parse_translation_rows
          rescue Exception => e
            say("Translation error: #{e}, carry on.")
            parse_translation_rows
          end
        else
          complete_translations_process
        end
      end

      def complete_translations_process
         fb_logout
         open_graph_translations_stats
         ask("<%= color('Any key to exit....', BOLD) %>", String)
      end

      def fb_login
         say("\n.....logging into Facebook")
         @browser.goto "https://www.facebook.com"
         @browser.text_field(id: "email").set  Base.user[:fb_username] 
         @browser.text_field(id: "pass").set  Base.user[:fb_password] 
         @browser.label(id: "loginbutton").click
      end

      def fb_logout
         say(".....logging out of Facebook \n")
         @browser.div(id: "userNavigationLabel").click
         @browser.label(class: "uiLinkButton navSubmenu").click
         @browser.close
      end

      def open_graph_translations_stats
         say("<%= color('\n***********************************************************************************************************', GREEN, BOLD) %>")
         say("Source Application: <%= color('#{@translation[:src_app_name]}', GREEN, BOLD) %>")
         say("Destination Application: <%= color('#{@translation[:dst_app_name]}', GREEN, BOLD) %>")
         say("Export completed: <%= color('#{@translation[:dst_translation_arr].length} Open Graph translations processed', GREEN, BOLD) %>")
         say("<%= color('***********************************************************************************************************\n', GREEN, BOLD) %>")
      end

    end

  end
end

