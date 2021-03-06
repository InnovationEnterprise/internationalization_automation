require 'yaml'
require 'pry'
require 'nokogiri'
require 'colorize'

if !ARGV.include?("spec/translate_spec.rb")
  FILE_TO_TRANSLATE = ARGV[0]
  FILE_NAME = ARGV[0].split('/').last.split('.').first
  PATH_FOR_TRANSLATION = ARGV[1]
  FILE_WITH_TRANSLATION = ARGV[1].split('/').last.split('.').first
  FOLDER_FOR_TRANSLATION = ARGV[1].split('/')[-2]
end

class Runner
  def parse(file_to_translate, file_name, path_for_translation, file_with_translation, folder_for_translation)
    @file_to_translate = File.read(file_to_translate)
    file_with_erb_tags_escaped = transform_text(replace_tags_with_words, @file_to_translate)
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
                answer_result_logic(node, @link)
              else
                "'#{@link}'"
              end
            end
        end

        if text_for_translation?
          ask_for_text_change(@string)
          @answer = $stdin.gets.strip
          @link = nil
          answer_result_logic(node, @string) if positive_answer?
        end
      end
    end

    new_data = {
      file_with_translation => { folder_for_translation => { file_name => @translations } }
    }
    overwrite_file(path_for_translation, new_data.to_yaml)
    new_doc = transform_text(replace_words_with_tags, doc.to_html)
    overwrite_file(file_to_translate, new_doc)
    puts 'Modifications completed!'.colorize(:green)
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
      /&nbsp;/ => 'SPACE',
      /(\[")/ => 'OPEN_INTER',
      /(\"\])/ => 'CLOSE_INTER'
    }
  end

  def replace_words_with_tags
    {
      /OPEN_DISPLAY_BALISE/ => '<%=',
      /OPEN_BALISE/ => '<%',
      /CLOSE_BALISE/ => '%>',
      /ARROW/ => '=>',
      /SPACE/ => '&nbsp;',
      /OPEN_INTER/ => '["',
      /CLOSE_INTER/ => '"]'
    }
  end

  def answer_result
    if @answer != 'y' && @answer != 'n'
      puts "Answer y or n".colorize(:yellow)
      @answer = $stdin.gets.strip
      answer_result
    else
      @answer
    end
  end

  def positive_answer?
    answer_result == 'y'
  end

  def ask_for_text_change(string)
    string_for_prompt = string.clone
    puts "\nChange text: < #{string_for_prompt.colorize(:cyan)} > [y/n]"
  end

  def answer_result_logic(node, text_to_change)
    @file_to_translate.each_line("\n") do |line|
      @translations.each do |key, value|
        if line.include?(value)
          line.gsub!(/#{value}/, "t('.#{key}')")
          if line.include?('link_to')
            line.gsub!(/('t.+\)')/, line[/('t.+\)')/].chop.reverse.chop.reverse)
          end
        end
      end
      if line.include?(text_to_change)
        print line.colorize(:light_green)
      elsif line.include?("t('.")
        print line.colorize(:light_yellow)
      else
        print line.colorize(:light_red)
      end
    end

    string_for_prompt = text_to_change.clone
    puts "\nEnter new reference for < #{string_for_prompt.colorize(:cyan)} > with only downcase and underscore : For example new_translation_test"
    new_string = $stdin.gets.strip

    if (new_string =~ /^[a-z_]+$/).nil?
      puts "\nError : Wrong format".colorize(:red)
      sleep(1)
      answer_result_logic(node, text_to_change)
    end

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

Runner.new.parse(FILE_TO_TRANSLATE, FILE_NAME, PATH_FOR_TRANSLATION, FILE_WITH_TRANSLATION, FOLDER_FOR_TRANSLATION) if !ARGV.include?("spec/translate_spec.rb")
