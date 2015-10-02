#!/usr/bin/env ruby

require 'highline/import'
require 'ap'

class TsungRunner

  def initialize
    @config_dir = File.dirname(__FILE__) + '/config'
    @project = nil
  end

  def run
    task = get_task
    send(task)
  end




  private

  def delete_logs
    projects = get_project_list
    projects.each { |project| delete_logs_for_project(project) }
  end


  def delete_logs_for_project(project)
    puts "Deleting logs for project #{project}"
    log_dir = "#{@config_dir}/project/#{project}/log"
    log_dirs = Dir["#{log_dir}/*"]
    if log_dirs.empty?
      puts "No logs found for project #{project}"
    else
      log_dirs.each do |dir|
        puts "removing #{dir}"
        system "rm -rf #{dir}"
      end
    end
  end


  def run_load_test
    project_list = get_project_list
    @project = display_menu_and_choose("Select the project you want to load test:", project_list)
    project_dir = "#{@config_dir}/project/#{@project}"
    xml_file = display_menu_and_choose("Select the XML file to run:", get_resource_list_from_files('xml', 'xml'))
    command = "tsung -f #{project_dir}/xml/#{xml_file}.xml -l #{project_dir}/log start"
    puts "Executing command: #{command}"
    pipe = IO.popen(command)
    lines = pipe.readlines
    lines.each { |l| puts l }
  end

  def analyse_results 
    project_list = get_project_list
    @project = display_menu_and_choose("Select the project you want to load test:", project_list)
    project_dir = "#{@config_dir}/project/#{@project}"
    dirs = reverse_sort(Dir["#{project_dir}/log/*"])
    dir = display_menu_and_choose("Select the log file you want to analyse: ", dirs)
    intervals = [5, 10, 15, 20, 30]
    interval = display_menu_and_choose("Select the interval in seconds to summarise by: ", intervals.map{ |n| "Every #{n} seconds"})
    interval =~ /^Every (\S+) seconds$/
    command = "lib/dfa -f #{dir}/tsung.dump -s #{$1}"
    system command
    summary_file = File.expand_path("#{dir}/tsung.dump.summary.csv")
    puts "Results have been summarised and are available in file #{summary_file}"
    
  end


  def reverse_sort(array)
    array.sort{ |a, b| b <=> a }
  end

  def generate_xml
    project_list = get_project_list
    @project = display_menu_and_choose("Select the project you want to load test:", project_list)
    environment = display_menu_and_choose("Select the environment to use:", get_resource_list_from_files('environments'))
    load_profile = display_menu_and_choose("Select the load_profile to use:", get_resource_list_from_files('load_profiles'))
    session = display_menu_and_choose("Select the session to run", get_resource_list_from_files('sessions'))
    
    xml_dir = "#{File.dirname(__FILE__)}/config/project/#{@project}/xml"
    Dir.mkdir(xml_dir) unless Dir.exist?(xml_dir)
    xml_file = "#{xml_dir}/#{environment}-#{load_profile}-#{session}.xml"

   
    command = "ruby lib/wrap.rb -p #{@project} -e #{environment} -l #{load_profile} #{session} -x > #{xml_file}"
    puts command
    system command
  end


  def display_menu_and_choose(prompt, options)
    chosen_option = nil
    puts " "
    choose do | menu |
      menu.prompt = prompt
      options.each do |option|
        menu.choice(option)     { task = option }
      end
    end

  end


  def get_resource_list_from_files(subdir_name, extension = 'yml')
    resources = []
    resource_files = Dir["#{@config_dir}/project/#{@project}/#{subdir_name}/*.#{extension}"]
    resource_files.each do |file|
      file =~ /.*\/(.*)\.#{extension}$/
      resources << $1
    end
    resources
  end


  def get_task
    task = nil
    choose do |menu|
      menu.prompt = "Select task:"
      menu.choice("Generate session XML")       { task = :generate_xml }
      menu.choice("Run load lest")              { task = :run_load_test }
      menu.choice("Anyalyse results")           { task = :analyse_results }
      menu.choice("Remove log directories")     { task = :delete_logs }
    end
    task
  end


  def get_project_list
    project_dirs = Dir["#{@config_dir}/project/*"]
    projects = []
    project_dirs.each do |dir|
      next unless File.directory?(dir)
      dir =~ /.*\/(.*$)/
      projects << $1
    end
    projects
  end

end

TsungRunner.new.run