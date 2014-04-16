# command line script to wrap session configuration files to produce Tsung XML configs

require 'optparse'
require 'tempfile'
require 'yaml'
require 'erb'
require 'fileutils'

require_relative 'tsung_wrapper'
require_relative 'wrapper'

module TsungWrapper
	class Wrap

		def initialize()
			@options      = {:env => 'development', :output => :nil, :verbose => false, :clean => nil, :load_profile => nil }
			@config       = nil
			@session_name = nil
			@help					= false

		  validate_options
		  validate_config
		end

		def run
			clean_log_dir unless @options[:clean].nil?
			generate_xml unless @options[:output].nil?
			run_tsung if @options[:output] == :tsung
			run_stats unless @options[:stats].nil?
		end



		private

		def run_stats
			command = "#{@config['tsung_stats']}"
			puts "++++++ DEBUG ++++++ #{__FILE__}::#{__LINE__} ++++\n"
			require 'pp'
			pp @config
			puts "++++++ DEBUG ++++++ #{__FILE__}::#{__LINE__} ++++\n"
			puts "PERL5LIB=#{@config['perl_libs'].join(':')} "
			unless  @config['perl_libs'].nil?
				command = "PERL5LIB=#{@config['perl_libs'].join(':')} " + command
			end
			puts command
			Dir.chdir("/Users/stephen/src/tsung-wrapper/log/20140415-0950") 
			pipe = IO.popen(command)
			lines = pipe.readlines
			pipe.close
		end


		def clean_log_dir
			if File.exist?(@config['log_dir'])
				cutoff_time = Time.now - (@options[:clean] * 60 * 60)
				files = Dir["#{@config['log_dir']}/*"]
				files.each do |file|
					mtime = File.stat(file).mtime
					FileUtils.remove_entry_secure(file) if mtime < cutoff_time
				end
			end
		end



		def generate_xml
			output = ""
			if @verbose
				puts "Calling TsungWrapper::Wrapper.new(#{@session_name}, #{@options[:env]})"
			end

			wrapper = TsungWrapper::Wrapper.new(@session_name, @options[:env])
			unless @options[:load_profile].nil?
				wrapper.register_load_profile(@options[:load_profile])
			end
			output = wrapper.wrap
			

			if @options[:output] == :xml 
				puts output
			else
				@tmp_file = TsungWrapper.tmpfilename
				File.open(@tmp_file, 'w') do |fp|	
					fp.puts(output)
				end
			end
		end


		def run_tsung
			FileUtils.mkdir_p(@config['log_dir']) unless File.exist?(@config['log_dir'])

			command = "tsung -f #{@tmp_file} -l #{@config['log_dir']} start "
			if @verbose
				puts "Running commnad: #{command}"
			end

			pipe = IO.popen(command)
			while !pipe.eof do
				line = pipe.readline
				puts "Data returned from Tsung >>> #{line}"
			end
			pipe.close
		end




		def validate_options
			OptionParser.new do |opts|
				opts.banner = "Usage: wrap [-e environment] [-l load_profile] [-v] [-s] -x|-r session_name\n" + 
										  "       wrap [-e environment] -c n"
				opts.separator ""
			  opts.separator "Generate Tsung XML file for session <session_name>"
			  opts.separator ""

				opts.on("-e", "--environment  ENV", 'Use specified environment (default: development)') do |env|
					@options[:env] = env
				end

				opts.on("-x", "--xml-out", "Generate XML config and write to STDOUT") do |xml|
					@options[:output] = :xml
				end

				opts.on("-r", "--run-tsung", "Generate XML config and pipe into tsung") do |xml|
					@options[:output] = :tsung
				end

				opts.on("-l", "--load-profile LOAD_PROFILE", "Use specific load profile") do |load_profile|
					@options[:load_profile] = load_profile
				end

				opts.on("-s", "--generate-stats", "Generate Stats (requires that -r option is set") do |stats|
					@options[:stats] = true
				end

				opts.on("-v", "--verbose", "Set verbose mode ON") do |v|
					@options[:verbose] = true
				end

				opts.on("-c", "--clean-log-dir HOURS", "Clean log dir of directories created before N hours ago") do |hours|
					unless hours =~ /^[0-9+]$/
						puts "Error: parameter passed to -c switch must be numeric"
						exit 2
					end
					@options[:clean] = hours.to_i
				end.parse!
			end



			TsungWrapper.env = @options[:env]
			check_env_exists


			if @options[:stats] == true && @options[:output] != :tsung
				puts "Error: Unable to generate stats (-s option) unless -r otpion is also set."
				exit 2
			end


			@verbose = @options[:verbose]
			if @verbose
				puts "Options: #{@options.inspect}"
				puts "ARGS:    #{ARGV.inspect}"
			end

			if ARGV.empty?
				$stderr.puts "Error: No session name specified" if ARGV.empty?
				exit(1)
			end
			@session_name = ARGV.first
		end


		def check_env_exists
			f = File.expand_path(File.join(TsungWrapper.config_dir, 'environments', "#{@options[:env]}.yml"))
			
			unless File.exist?(File.expand_path(File.join(TsungWrapper.config_dir, 'environments', "#{@options[:env]}.yml")))
				raise ArgumentError.new("Configuration file for environment '#{@options[:env]}' does not exist.")
			end
		end



		def validate_config
			
			filename = File.expand_path(File.join(TsungWrapper.config_dir, 'tsung.yml'))
			unless File.exist?(filename)
				$stderr.puts "Error: Unable to find config file #{filename}"
				exit 2
			end

			@config = YAML.load(ERB.new(File.read(filename)).result)['tsung_config']
			mandatory_config_keys = %w{ log_dir tsung_stats perl_libs }
			mandatory_config_keys.each do |key|
				unless @config.has_key?(key)
					puts $stderr.puts "Error: Config file does not have entry for mandatory key '#{key}'."
					exit 2
				end
			end
		end


	end
end


begin
	wrapper = TsungWrapper::Wrap.new.run
rescue => err
	$stderr.puts "#{err.class}: #{err.message}"
	$stderr.puts err.backtrace
	exit 2
end

