require 'nokogiri'
require 'pry'

FILE = ARGV[0]

class Runner
  def parse
    file_to_translate = File.read(FILE)
    file_to_translate.gsub!(/<%=/, 'OPEN_DISPLAY_BALISE')
    file_to_translate.gsub!(/<%/, 'OPEN_BALISE')
    file_to_translate.gsub!(/%>/, 'CLOSE_BALISE')
    file_with_erb_tags_escaped = file_to_translate
    doc = Nokogiri::HTML(file_with_erb_tags_escaped)

    doc.traverse do |node|
      if node.class == Nokogiri::XML::Text
        string = node.text.strip

        if (string !~ /OPEN_DISPLAY_BALISE/ && string !~ /OPEN_BALISE/ && string !~ /CLOSE_BALISE/) && string.length > 2
          puts "Change text: < #{string} > [y/n]"
          answer = $stdin.gets.strip

          until ['y', 'n'].include?(answer)
            puts "Answer y or n"
            answer = $stdin.gets.strip
          end

          node.content = "replaced!" if answer == 'y'
        end
      end
    end
    @new_doc = doc.to_html.gsub(/OPEN_DISPLAY_BALISE/, '<%=')
    @new_doc.gsub!(/OPEN_BALISE/, '<%')
    @new_doc.gsub!(/CLOSE_BALISE/, '%>')
    puts @new_doc

  end
end

Runner.new.parse
