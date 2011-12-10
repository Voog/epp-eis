require 'spec_helper'

describe 'check_domain' do
  
  before(:each) do
    @server = Epp::Server.new(:server => '127.0.0.1', :tag => 'username', :password => 'password')
  end
  
  context 'when response is successful' do
    
    before(:each) do
      @server.stub(:request).and_return(xml_mock('check_domain_1000.xml'))
    end
    
    it 'has status code 1000' do
      @server.check_domain('fraktal.ee').code.should == 1000
    end
    
    context 'when multiple domain names are provided' do
      it 'has multiple domain check items in response object' do
        @server.check_domain('fraktal.ee', 'edicypages.ee').items.size.should == 2
      end
    end
  end
end

describe 'is_domain_available?' do
  
  before(:each) do
    @server = Epp::Server.new(:server => '127.0.0.1', :tag => 'username', :password => 'password')
  end
  
  context 'when domain is available' do
    before(:each) do
      @server.stub(:request).and_return(xml_mock('check_domain_available_1000.xml'))
    end
    
    it 'returns true' do
      @server.is_domain_available?('edicypages.ee').should be_true
    end
  end
  
  context 'when domain is not available' do
    before(:each) do
      @server.stub(:request).and_return(xml_mock('check_domain_taken_1000.xml'))
    end
    
    it 'returns false' do
      @server.is_domain_available?('fraktal.ee').should be_false
    end
  end
end
