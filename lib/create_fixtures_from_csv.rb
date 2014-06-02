# Data source: 
# https://docs.google.com/a/digital.justice.gov.uk/spreadsheet/ccc?key=0Arsa0arziNdndHlwM2xJMVl5Z3pDdFVOYnVsRmZST1E&usp=sharing
# download as CSV
# copy to the same folder as this script
# rename as 'data.csv'

require 'csv'
# require 'pry'
require 'json'
require 'curb'
require 'tempfile'
require_relative 'yaml_scenario_generator'

class DataScenarioGenerator
  def initialize(csv_filename)
    @rows = CSV.read(csv_filename)
    @column_containing_first_journey = 3
    @scenario_data = buildDataHash
  end

  def writeToFile
    @scenario_data.each_with_index do |data, i|
      index = sprintf('%02d', i + 1)
      file = File.join(TsungWrapper.config_dir, "snippets", "post_scenario_#{index }.yml")
      yaml = TsungWrapper::YamlScenarioGenerator.new(data).to_yaml
      File.open(file,'w') do |f|
        f.write(yaml)
      end
      write_session_yaml(index)
    end
    write_scenario_yaml
  end


  def write_session_yaml(index)
    session_name = File.join(TsungWrapper.config_dir, 'sessions', "scenario_#{index}_session.yml")
    snippet_name = "post_scenario_#{index}"
    session_hash = {
      'session' => {
        'snippets' => [
            'get_landing_page',
            snippet_name
        ]
      }
    }
    File.open(session_name, 'w') do |fp|
      fp.write(session_hash.to_yaml)
    end
  end



  def write_scenario_yaml
    session_files        = Dir["#{TsungWrapper.config_dir}/sessions/scenario_*_session.yml"]
    num_sessions         = session_files.size
    percentage           = 100/num_sessions
    percentage_written   = 0
    num_sessions_written = 0
    session_hash         = {}
    session_files.each do |f|
      if num_sessions_written == num_sessions - 1
        percentage = 100 - percentage_written
      end
      session_name               = File.basename(f).gsub(/\.yml$/, '')
      session_hash[session_name] = percentage 
      percentage_written        += percentage
      num_sessions_written      += 1
    end
    hash = { 'scenario' => session_hash }
    File.open(File.join(TsungWrapper.config_dir, 'scenarios', 'all_scenarios.yml'), 'w') do |fp|
      fp.write(hash.to_yaml)
    end
  end



  def sanitizeValue(model, attribute, value)
    value = nil if value == '-'

    if(model == 'property' && attribute == 'house')
      value = (!value.nil? && value.downcase == 'house') ? 'Yes' : 'No'
    end

    if attribute[/date/] && value
      begin
        value = Date.parse(value).strftime('%Y-%m-%d')
      rescue
        puts "Error at #{model}, #{attribute}"
        puts "can't parse #{value} to date"
      end
    end
    value
  end

  def buildDataHash
    scenarios = []
    beginning = @column_containing_first_journey
    ending = countScenarios + @column_containing_first_journey - 1
    beginning.upto(ending) do |index|
      scenarios << getScenario(index)
    end
    scenarios
  end

  def getScenario(index)
    scenario = {
      title: @rows[0][index],
      description: [@rows[1][index], @rows[2][index]],
      claim: {}
    }
    col = index + @column_containing_first_journey - 1
    validRows.each do |row|
      model = row[1]
      field = row[2]
      value = sanitizeValue(model, field, row[index])
      scenario[:claim][model.to_sym] ||= {}
      if is_date_field?(field)
        scenario[:claim][model.to_sym][date_field_name(:year, field)] = date_value(:year, value)
        scenario[:claim][model.to_sym][date_field_name(:month, field)] = date_value(:month, value)
        scenario[:claim][model.to_sym][date_field_name(:day, field)] = date_value(:day, value)
      else
        scenario[:claim][model.to_sym][field.to_sym] = value
      end
    end
    scenario
  end


  def is_date_field?(field)
    field =~ /^date/ || field =~ /date$/
  end

  def date_field_name(part, field)
    case part
    when :year
      suffix = '1i'
    when :month
      suffix = '2i'
    when :day
      suffix = '3i'
    end
    "#{field}(#{suffix})".to_sym
  end  

  def date_value(part, value)
    parts = value.nil? ? ['', '', ''] : value.split('-')
    case part
    when :year
      parts[0]
    when :month
      parts[1]
    when :day
      parts[2]
    end
  end



  def validRows
    valid_rows = []
    @rows.each.with_index do |r, index|
      if(index > 0 && !r[1].nil?)
        valid_rows << r
      end
    end
    valid_rows
  end


  def countScenarios
    r = @rows[0] 
    col = @column_containing_first_journey 
    count = 0 
    while(r[col] != nil) do
      count += 1
      col += 1
    end
    @scenario_count = count
  end
end

class DownloadScenarioData
  def self.download
    url = get_download_url
    puts "Downloading: #{url}"
    http = Curl.get(get_download_url) do |http|
      http.headers['Accept'] = "text/csv"
      http.follow_location = true
    end

    filename  = write_csv_to_tempfile http.body_str
    filename
  end

  def self.write_csv_to_tempfile(csv_data)
    file = Tempfile.new('data_csv', encoding: 'utf-8')
    file.write(csv_data)
    file.path
  end

  def self.get_download_url
    key = "0Arsa0arziNdndHlwM2xJMVl5Z3pDdFVOYnVsRmZST1E"
    "https://docs.google.com/spreadsheet/pub?key=#{key}&single=true&gid=0&output=csv"
  end
end