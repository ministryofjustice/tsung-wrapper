module TsungWrapper


	# return the environemnt
	def self.env
		if ENV['TSUNG_WRAPPER_ENV'].nil?
			ENV['TSUNG_WRAPPER_ENV'] = 'development'
		end
		ENV['TSUNG_WRAPPER_ENV']
	end


	def self.env=(new_env)
		ENV['TSUNG_WRAPPER_ENV'] = new_env
	end


	def self.test_env?
		self.env == 'test' ? true : false
	end

	def self.development_env?
		self.env == 'development' ? true : false
	end




	# return the file path of the project root
	def self.root
		File.expand_path(File.dirname(__FILE__) + '/..')
	end

	def self.config_dir
		if TsungWrapper.test_env?
			File.expand_path(File.join(TsungWrapper.root, 'spec', 'config'))
		else
			File.expand_path(File.join(TsungWrapper.root, 'config'))
		end
	end

	def self.dtd
		"#{self.config_dir}/tsung-1.0.dtd"
	end


end
