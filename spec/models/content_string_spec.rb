require_relative '../spec_helper'   
require_relative '../../lib/content_string' 

module TsungWrapper

  describe ContentString do 

    describe '.encode' do


      it 'should simply encode one set of params without substitutions' do
        params = {'name' =>'stephen'}
        ContentString.encode(params).should == "name=stephen".to_sym
      end


      it 'should encode multiple parameters without substitutions' do
        params = {'email' => 'user@test.com', 'password' => 'Abc123', 'submit' => 'Sign up'}
        ContentString.encode(params).should == "email=user%40test.com&amp;password=Abc123&amp;submit=Sign+up".to_sym
      end

      it 'should encode multiple parameters with substitutions' do
        params = {'email' => '%%_user%%@%%_domain%%.com', 'password' => '%%_password%%', 'submit' => 'Sign up'}
        ContentString.encode(params).should == "email=%%_user%%%40%%_domain%%.com&amp;password=%%_password%%&amp;submit=Sign+up".to_sym
      end

    end
    
  end



end
