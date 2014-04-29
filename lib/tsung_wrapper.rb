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


	def self.tmpfilename(seed = nil)
		tmpdir = ENV['TMPDIR']
		tod =  Time.now.strftime("%y%m%d%H%M%S%L")
		name = File.join(tmpdir, "TW#{seed}-#{tod}.tmp")
	end


	def self.formatted_time
		Time.now.strftime('%Y%m%d-%H%M%S')
	end


	def self.md5_to_i(str)
	  i = 0
	  j = 1
	  str.each_byte do |n|
	    i += (n * j)
	    j *= 10
	  end
	  i
	end

end
