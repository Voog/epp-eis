require 'spec_helper'

describe Epp::Eis::CreditCommands do
  
  before(:each) do
    @server = Epp::Server.new(:server => '127.0.0.1', :tag => 'username', :password => 'password')
  end
  
  describe 'credit_info' do
    context 'when response is successful' do
      before(:each) do
        @server.stub(:send_request).and_return(xml_mock('responses/credit/credit_info.xml'))
        @response = @server.credit_info
      end
      
      it 'returns response code' do
        @response.code.should == 1000
      end
      
      it 'returns hash of credits by TLD' do
        @response.zone_credits['ee'].should == '1234.56'
      end
    end
  end
end
