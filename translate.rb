require 'nokogiri'
require 'pry'

FILE = ARGV[0]

class Runner
  def parse
    file_to_translate = File.read(FILE)
    file_with_erb_tags_escaped = file_to_translate.gsub(/<%([^%]*)%>/, 'BALISE\1BALISE')
    doc = Nokogiri::HTML(file_with_erb_tags_escaped)

    doc.traverse do |node|
      if node.class == Nokogiri::XML::Text
        string = node.text.strip

        if (string !~ /BALISE/) && string.length > 2
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
    puts doc
  end
end

Runner.new.parse
