require 'spec_helper'

describe Epp::Eis::CreditCommands do
  
  before(:each) do
    @server = Epp::Server.new(server: '127.0.0.1', tag: 'username', password: 'password')
  end
  
  describe 'credit_info' do
    context 'request' do
      before(:each) do
        expect(@server).to receive(:send_request) do |xml|
          @request = Nokogiri::XML(xml)
          xml_mock('responses/credit/credit_info.xml')
        end
        @response = @server.credit_info
      end
      
      it 'contains credit info in fred namespace' do
        expect(@request.css('fred|creditInfo', 'fred' => Epp::Eis::XML_NS_FRED)).not_to be_empty
      end
    end
    
    context 'when response is successful' do
      before(:each) do
        expect(@server).to receive(:send_request).and_return(xml_mock('responses/credit/credit_info.xml'))
        @response = @server.credit_info
      end
      
      it 'returns response code' do
        expect(@response.code).to eq(1000)
      end
      
      it 'returns hash of credits by TLD' do
        expect(@response.zone_credits['ee']).to eq('1234.56')
      end
    end
  end
end
