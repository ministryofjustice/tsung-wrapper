require 'ap'
require 'yaml'
require 'pp'
require 'securerandom'


# class to use curl to upload files to adp service endpoints

class FileUploader

  def initialize(config_file = nil)
    config_file ||= File.dirname(__FILE__) + '/../config/project/adp/file_uploads/documentary_evidence.yml'
    config               = YAML.load_file(config_file)
    @username            = config['login']['username_value']
    @username_field_name = config['login']['username_field_name']
    @password            = config['login']['password_value']
    @password_field_name = config['login']['password_field_name']
    @cookie_jar          = File.expand_path(File.dirname(__FILE__) + "/#{config['login']['cookie_jar']}")
    @data_dir            = config['data_directory']
    @filenames           = config['filenames']
    @login_url           = config['login']['url']
    @upload_url          = config['upload_url']
    @iterations          = config['iterations']
    @log                 = File.open('file_uploader.log', 'a')
  end

  def run
    login_and_save_cookie
    @iterations.times do 
      upload_files
    end
  end

  def login_and_save_cookie
    command = "curl -F #{@username_field_name}=#{@username} -F #{@password_field_name}=#{@password} --cookie-jar #{@cookie_jar} #{@login_url}"
    output_log "Logging in"
    system command
  end


  def upload_files
    form_id = SecureRandom.uuid
    @filenames.each_with_index do |filename|
      upload_file(filename, form_id)
    end
  end

  def upload_file(filename, form_id)
    full_path = "#{@data_dir}/#{filename['name']}"
    file_size = File.stat(full_path).size
    start_time = Time.now.to_f
    type = filename['type']
    command  = %Q|curl -i -F document[form_id]=#{form_id} -F document[document]="@#{full_path};type=#{type}" -F document[creator_id]=42 --cookie #{@cookie_jar} #{@upload_url}|
    system command
    stop_time = Time.now.to_f
    elapsed_time = stop_time - start_time
    output_log "size: #{file_size} elapsed_time: #{elapsed_time}"
  end


  def output_log(message)
    @log.puts "#{Time.now.to_f} [#{Process.pid}] #{message}" 
  end

end

FileUploader.new.run




# curl -F user[email]=advocate@example.com -F user[password]=liverbird --cookie-jar ./cookie_jar.txt http://localhost:3000/users/sign_in

# curl -i -F document[form_id]=000001   -F document[document]="@/Users/stephen/tmp/adp_documents/hardship.pdf;type=application/pdf"   -F document[creator_id]=9001   --cookie ./cookie_jar.txt   http://localhost:3000/documents