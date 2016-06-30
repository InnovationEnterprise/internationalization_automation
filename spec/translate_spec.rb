require 'spec_helper'

describe Runner do
  let!(:file_to_translate) { './spec/file_test/file_test.html.erb' }
  let!(:file_name) { 'file_test' }
  let!(:path_for_translation) { './spec/file_test/en.yml' }
  let!(:file_with_translation) { 'en' }
  let!(:folder_for_translation) { 'test' }
  let!(:old_html_file) { File.read(file_to_translate) }
  let!(:old_yml_file) { File.read(path_for_translation) }

  after(:each) do
    File.open(file_to_translate, 'w') { |f| f.write old_html_file }
    File.open(path_for_translation, 'w') { |f| f.write old_yml_file }
  end

  it 'works properly' do
    runner = Runner.new
    InputFaker.with_fake_input(['y', 'admin_path', 'y', 'log_out_path', 'y', 'log_in', 'y', 'register_today', 'y', 'no_registration_present', 'y', 'avaibility_limited' ]) do
      runner.parse(file_to_translate, file_name, path_for_translation, file_with_translation, folder_for_translation)
    end
  end
end
