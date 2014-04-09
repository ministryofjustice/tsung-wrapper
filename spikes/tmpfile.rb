require 'tempfile'

file = Tempfile.new('stepripoinikas')
puts file.path      # => A unique filename in the OS's temp directory,
               #    e.g.: "/tmp/foo.24722.0"
               #    This filename contains 'foo' in its basename.
file.puts("hello world")
file.close



# file.rewind
# file.read      # => "hello world"
# file.close
# # file.unlink    # deletes the temp file