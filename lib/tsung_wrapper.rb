module TsungWrapper

	def self.root
		File.expand_path(File.dirname(__FILE__) + '/..')
	end


	def self.dtd
		"#{self.root}/config/tsung-1.0.dtd"
	end


end
