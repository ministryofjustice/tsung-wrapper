
require 'spec_helper'    
require_relative '../lib/content_string_encoder'

module TsungWrapper

  describe ContentStringEncoder do

    describe '#encode' do
      
      it 'should simply encode a string without dynvars with no substitution' do
        unencoded_string = 'email=test1@test.com&password=Abc123&submit=Sign up'
        encoded_string   = "email%3Dtest1%40test.com%26password%3DAbc123%26submit%3DSign+up"

        cse = ContentStringEncoder.new(unencoded_string)
        cse.encode.should == encoded_string.to_sym
      end


      it 'should encode a string except the one dynvar' do
        unencoded_string = 'email=%%_user1%%@test.com&password=Abc123&submit=Sign up'
        encoded_string   = "email%3D%%_user1%%%40test.com%26password%3DAbc123%26submit%3DSign+up"

        cse = ContentStringEncoder.new(unencoded_string)
        cse.encode.should == encoded_string.to_sym
      end


      it 'should encode a string containing multiple dynvars' do
        unencoded_string = 'email=%%_email%%@%%_domain%%&name=%%_name%%&submit=%%_submit%%'
        encoded_string   = "email%3D%%_email%%%40%%_domain%%%26name%3D%%_name%%%26submit%3D%%_submit%%"

        cse = ContentStringEncoder.new(unencoded_string)
        cse.encode.should == encoded_string.to_sym
      end
    end


    describe '.encode' do
      it 'should encode exactly as above' do
        unencoded_string = 'email=%%_email%%@%%_domain%%&name=%%_name%%&submit=%%_submit%%'
        encoded_string   = "email%3D%%_email%%%40%%_domain%%%26name%3D%%_name%%%26submit%3D%%_submit%%"

        ContentStringEncoder.encode(unencoded_string).should == encoded_string.to_sym
      end

    end

  end

end
