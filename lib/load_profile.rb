require 'yaml'
require 'builder'


module TsungWrapper

	class LoadProfile

		attr_accessor :builder

		def initialize(load_profile_name)
			@builder       = nil
			@arrivalphases = []
			filename       = File.join(TsungWrapper.config_dir, 'load_profiles', "#{load_profile_name}.yml")
			phases         = YAML.load_file(filename)['arrivalphases']
			
			phases.each do |phase|
				@arrivalphases << OpenStruct.new(phase)
			end
		end

		def set_xml_builder(builder)
			@builder = builder
		end

		def num_phases
			@arrivalphases.size
		end

		def to_xml
			raise "Must call set_xml_builder() before calling to_xml" if @builder.nil?
			@builder.load do
				@arrivalphases.each { |phase| phase_to_xml(phase) }
			end
		end

		private

		def phase_to_xml(phase)
			@builder.comment! "Scenario #{phase.sequence}: #{phase.name}"
			@builder.arrivalphase(:phase => phase.sequence, :duration => phase.duration, :unit => phase.duration_unit) do
				if phase.max_users.nil?
					@builder.users(:interarrival => phase.arrival_interval, :unit => phase.arrival_interval_unit)
				else
					@builder.users(:maxnumber => phase.max_users, :arrivalrate => phase.arrival_rate, :unit => phase.arrival_rate_unit)
				end
			end
		end
		
	end

end

