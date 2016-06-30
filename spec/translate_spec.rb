require 'spec_helper'

describe Runner do
  let!(:file_to_translate) { './spec/file_test/file_test.html.erb' }
  let!(:file_name) { 'file_test' }
  let!(:path_for_translation) { './spec/file_test/en.yml' }
  let!(:file_with_translation) { 'en' }
  let!(:folder_for_translation) { 'test' }
  let!(:old_html_file) { File.read(file_to_translate) }
  let!(:old_yml_file) { File.read(path_for_translation) }

  before(:each) do
    InputFaker.with_fake_input(['y', 'admin_path', 'y', 'log_out_path', 'n', 'y', 'register_today', 'y', 'no_registration_present', 'n']) do
    runner = Runner.new
      runner.parse(file_to_translate, file_name, path_for_translation, file_with_translation, folder_for_translation)
    end
  end

  after(:each) do
    File.open(file_to_translate, 'w') { |f| f.write old_html_file }
    File.open(path_for_translation, 'w') { |f| f.write old_yml_file }
  end

  context 'after runner parses html.erb file' do
    let!(:new_html_file) { File.read(file_to_translate) }

    it "replaces link_to 'Admin' with admin_path" do
      expect(new_html_file).to include("<%= link_to t('.admin_path'), admin_path %>")
    end

    it "replaces link_to 'Log Out' with log_out_path" do
      expect(new_html_file).to include("<%= link_to t('.log_out_path'), test_sign_out_path %>")
    end

    it 'not replaces link_to Log In' do
      expect(new_html_file).to include("<%= link_to 'Log In', test_session_path, class: 'btn btn-small' %>")
    end

    it "replaces 'Register Today' with register_today" do
      expect(new_html_file).to include("<h1><%= t('.register_today') %></h1>")
    end

    it "replaces 'No registration present' with no_registration_present" do
      expect(new_html_file).to include("<h1><%= t('.no_registration_present') %></h1>")
    end

    it "not replaces 'Availability may be limited by approval or submission'" do
      expect(new_html_file).to include("</sup> Availability may be limited by approval or submission</small>")
    end

    it 'sets en.yml file with values from file_test.html.erb file' do
      new_yml_file = File.read(path_for_translation)
      expect(new_yml_file).to eql("---\nen:\n  test:\n    file_test:\n      admin_path: Admin\n      log_out_path: Log Out\n      register_today: Register Today\n      no_registration_present: No registration present.\n")
    end

    it 'keeps &nbsp tags' do
      expect(new_html_file).to include('&nbsp;')
    end
  end
end
