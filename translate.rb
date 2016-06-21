require 'nokogiri'
require 'yaml'
require 'pry'

FILE_TO_TRANSLATE = ARGV[0]
FILE_NAME = ARGV[0].split('.').first
PATH_FOR_TRANSLATION = ARGV[1]
FILE_WITH_TRANSLATION = ARGV[1].split('/').last
FOLDER_FOR_TRANSLATION = ARGV[1].split('/')[-2]

class Runner
  def parse
    file_to_translate = File.read(FILE_TO_TRANSLATE)

    file_with_erb_tags_escaped = transform_text(replace_tags_with_words, file_to_translate)

    doc = Nokogiri::HTML.fragment(file_with_erb_tags_escaped)
    translations = {}

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

          if answer == 'y'
            puts 'Enter new ref with only downcase and underscore : For example new_translation_test'
            new_string = $stdin.gets.strip
            node.content = "OPEN_DISPLAY_BALISE t('.#{new_string}') CLOSE_BALISE"
            translations[new_string] = string
          end
        end
      end
    end

    new_data = {
      FILE_WITH_TRANSLATION.delete('.yml') => { FOLDER_FOR_TRANSLATION => { FILE_NAME => translations } }
    }
    File.open(PATH_FOR_TRANSLATION, 'w') { |f| f.write new_data.to_yaml }

    new_doc = transform_text(replace_words_with_tags, doc.to_html)
    File.open(FILE_TO_TRANSLATE, 'w') { |f| f.write new_doc }
  end

  def transform_text(replacements, text_to_change)
    replacements.inject(text_to_change) do |string, mapping|
      string.gsub(*mapping)
    end
  end

  private

  def replace_tags_with_words
    {
      /<%=/ => 'OPEN_DISPLAY_BALISE',
      /<%/ => 'OPEN_BALISE',
      /%>/ => 'CLOSE_BALISE '
    }
  end

  def replace_words_with_tags
    {
      /OPEN_DISPLAY_BALISE/ => '<%=',
      /OPEN_BALISE/ => '<%',
      /CLOSE_BALISE/ => '%>'
    }
  end
end

Runner.new.parse
