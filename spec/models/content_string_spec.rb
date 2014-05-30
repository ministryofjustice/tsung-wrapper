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

      it 'should encode single dimension arrays correctly as repeated keys followed by []' do
        params = {'products' => ['fish', 'meat', 'eggs'] }
        encoded_params = ContentString.encode(params)
        encoded_params.should == :"products%5B%5D=fish&amp;products%5B%5D=meat&amp;products%5B%5D=eggs"
        CGI.unescape(encoded_params.to_s).should == 'products[]=fish&amp;products[]=meat&amp;products[]=eggs'
      end


      it 'should encode nested arrays correctly as repeated keys followed by []' do
        params = {'products' => [['cod', 'haddock', 'plaice'], ['beef', 'pork'], 'eggs'] }
        encoded_params = ContentString.encode(params)
        encoded_params.should == :"products%5B%5D%5B%5D=cod&amp;products%5B%5D%5B%5D=haddock&amp;products%5B%5D%5B%5D=plaice&amp;products%5B%5D%5B%5D=beef&amp;products%5B%5D%5B%5D=pork&amp;products%5B%5D=eggs"
        CGI.unescape(encoded_params.to_s).should == "products[][]=cod&amp;products[][]=haddock&amp;products[][]=plaice&amp;products[][]=beef&amp;products[][]=pork&amp;products[]=eggs"
      end


      it 'should encode a nested hash with repeated variable names with keys in square brackets' do
        params = {'fish' => {'type' => 'cod', 'size' => 'large'}, 'meat' => {'type' => 'beef', 'price' => '55'} }
        encoded_params = ContentString.encode(params)
        encoded_params.should == :"fish%5Bsize%5D=large&amp;fish%5Btype%5D=cod&amp;meat%5Bprice%5D=55&amp;meat%5Btype%5D=beef"
        CGI.unescape(encoded_params.to_s).should == "fish[size]=large&amp;fish[type]=cod&amp;meat[price]=55&amp;meat[type]=beef"
      end

    end
    
  end



end
