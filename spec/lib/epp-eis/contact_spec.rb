require 'spec_helper'

describe Epp::Eis::ContactCommands do
  
  before(:each) do
    @server = Epp::Server.new(:server => '127.0.0.1', :tag => 'username', :password => 'password')
  end
  
  describe 'check_domain' do

    context 'when response is successful' do

      before(:each) do
        @server.stub(:request).and_return(xml_mock('responses/check_contact_1000.xml'))
      end

      it 'has status code 1000' do
        @server.check_contact('CID:FRAKTAL:1').code.should == 1000
      end

      context 'when multiple contact names are provided' do
        it 'has multiple contact check items in response object' do
          @server.check_contact('CID:FRAKTAL:1', 'CID:FRAKTAL:2').items.size.should == 2
        end
      end
    end
  end
end
