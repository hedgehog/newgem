Given /^default env variables setup for name and email$/ do
  Given 'env variable $NAME set to "Dr Nic"'
  Given 'env variable $EMAIL set to "drnicwilliams@gmail.com"'
end

Given /^an existing newgem scaffold \[called "(.*)"\]/ do |project_name|
  newgem = File.expand_path(File.dirname(__FILE__) + "/../../bin/newgem")
  setup_active_project_folder project_name
  in_tmp_folder do
    @stdout = "newgem.out"
    system "ruby #{newgem} #{project_name} > #{@stdout} 2> #{@stdout}"
    force_local_lib_override
  end
end

Given /^an existing newgem scaffold using options "(.*)" \[called "(.*)"\]/ do |arguments, project_name|
  newgem = File.expand_path(File.dirname(__FILE__) + "/../../bin/newgem")
  setup_active_project_folder project_name
  in_tmp_folder do
    @stdout = "newgem.out"
    system "ruby #{newgem} #{arguments} #{project_name} > #{@stdout} 2> #{@stdout}"
    force_local_lib_override
  end
end

Given /^project website configuration for safe folder on local machine$/ do
  @remote_folder = File.expand_path(File.join(@tmp_root, 'website'))
  FileUtils.rm_rf   @remote_folder
  FileUtils.mkdir_p @remote_folder
  FileUtils.chdir @active_project_folder do
    FileUtils.mkdir_p 'config'
    config_yml = { "remote_dir" => @remote_folder }.to_yaml
    config_path = File.join('config', 'website.yml')
    File.open(config_path, "w") { |io| io << config_yml }
  end  
end

Given /^~\/([^\s]+) contains (\{.*\})$/ do |file, config|
  in_home_folder do
    File.open(file, 'w') do |f|
      yaml = eval(config)
      f << yaml.to_yaml
    end
  end
end

When /^newgem is executed for project "(.*)" with no options$/ do |project_name|
  @newgem_cmd = newgem_cmd
  setup_active_project_folder project_name
  in_tmp_folder do
    @stdout = File.expand_path("newgem.out")
    system "ruby #{@newgem_cmd} #{project_name} > #{@stdout}"
    force_local_lib_override
  end
end

When /^newgem is executed for project "(.*)" with options "(.*)"$/ do |project_name, arguments|
  @newgem_cmd = newgem_cmd
  setup_active_project_folder project_name
  in_tmp_folder do
    @stdout = File.expand_path("newgem.out")
    system "ruby #{@newgem_cmd} #{arguments} #{project_name} > #{@stdout}"
    force_local_lib_override
  end
end

When /^newgem is executed only with options "(.*)"$/ do |arguments|
  @newgem_cmd = newgem_cmd
  in_tmp_folder do
    @stdout = File.expand_path("newgem.out")
    system "ruby #{@newgem_cmd} #{arguments} > #{@stdout}"
  end
end


When /^I run unit tests for test file "(.*)"$/ do |test_file|
  @stdout = File.expand_path(File.join(@tmp_root, "tests.out"))
  in_project_folder do
    system "ruby #{test_file} > #{@stdout}"
  end
end

When /^I enable rspec autorun$/ do
  in_project_folder do
    File.open("spec/spec_helper.rb", "a") do |f|
      f << "require 'spec/autorun'"
    end
  end
end

Then /^remote folder "(.*)" is created/ do |folder|
  FileUtils.chdir @remote_folder do
    File.exists?(folder).should be_true
  end
end

Then /^remote file "(.*)" (is|is not) created/ do |file, is|
  FileUtils.chdir @remote_folder do
    File.exists?(file).should(is == 'is' ? be_true : be_false)
  end
end

Then /^shows version number$/ do
  stdout = File.read(@stdout)
  stdout.should =~ /#{Newgem::VERSION}/
end
