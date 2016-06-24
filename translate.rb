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
    @translations = {}

    doc.traverse do |node|
      if node.class == Nokogiri::XML::Text
        @string = node.text.strip

        if @string.include?('link_to')
          node.content =
            node.text.gsub!(/'.*?(?=,)/) do |link|
              @link = link.chop.reverse.chop.reverse #remove single quotes at the beginning and end of string
              ask_for_text_change(@link)
              @answer = $stdin.gets.strip

              if positive_answer?
                answer_result_logic(node)
              else
                "'#{@link}'"
              end
            end
        end

        if text_for_translation?
          ask_for_text_change(@string)
          @answer = $stdin.gets.strip
          answer_result_logic(node) if positive_answer?
        end
      end
    end

    new_data = {
      FILE_WITH_TRANSLATION.delete('.yml') => { FOLDER_FOR_TRANSLATION => { FILE_NAME => @translations } }
    }
    overwrite_file(PATH_FOR_TRANSLATION, new_data.to_yaml)
    new_doc = transform_text(replace_words_with_tags, doc.to_html)
    overwrite_file(FILE_TO_TRANSLATE, new_doc)
  end

  def transform_text(replacements, text_to_change)
    replacements.inject(text_to_change) do |string, mapping|
      string.gsub(*mapping)
    end
  end

  private

  def overwrite_file(path, new_data)
    File.open(path, 'w') { |f| f.write new_data }
  end

  def text_for_translation?
    (@string !~ /OPEN_DISPLAY_BALISE/ && @string !~ /OPEN_BALISE/ && @string !~ /CLOSE_BALISE/) && @string.length > 2
  end

  def replace_tags_with_words
    {
      /<%=/ => 'OPEN_DISPLAY_BALISE',
      /<%/ => 'OPEN_BALISE',
      /%>/ => 'CLOSE_BALISE',
      /=>/ => 'ARROW',
      /&nbsp;/ => 'SPACE'
    }
  end

  def replace_words_with_tags
    {
      /OPEN_DISPLAY_BALISE/ => '<%=',
      /OPEN_BALISE/ => '<%',
      /CLOSE_BALISE/ => '%>',
      /ARROW/ => '=>',
      /SPACE/ => '&nbsp;'
    }
  end

  def answer_result
    until ['y', 'n'].include?(@answer)
      puts "Answer y or n"
      $stdin.gets.strip
    end
    @answer
  end

  def positive_answer?
    answer_result == 'y'
  end

  def ask_for_text_change(string)
    puts "Change text: < #{string} > [y/n]"
  end

  def answer_result_logic(node)
    puts 'Enter new ref with only downcase and underscore : For example new_translation_test'
    new_string = $stdin.gets.strip

    if !@link.nil?
      old_link = @link
      @translations[new_string] = old_link
      "t('.#{new_string}')"
    else
      node.content = "OPEN_DISPLAY_BALISE t('.#{new_string}') CLOSE_BALISE"
      @translations[new_string] = @string
    end
  end
end

Runner.new.parse
