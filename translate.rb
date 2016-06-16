require 'nokogiri'

FILE = ARGV[0]

class Runner
  def parse(file)
    content = File.read(FILE).to_s
    content_escaped = content.gsub(/<%([^%]*)%>/, 'BITE\1BITE')
    doc = Nokogiri::HTML(content_escaped)
    doc.traverse do |node|
      if node.class == Nokogiri::XML::Text
        text = node.text.strip
        if !(text =~ /BITE/) && text.length > 5
          puts "change text: #{text}?"
          ans = $stdin.gets.strip

          while !['y', 'n'].include?(ans)
            puts "Answer y or n"
            ans = $stdin.get.strip
          end

          if ans == 'y'
            node.content = "replaced!"
          end
        end
      end
    end
    puts doc
  end
end

Runner.new.parse(FILE)
