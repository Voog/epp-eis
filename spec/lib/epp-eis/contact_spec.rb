require 'spec_helper'

describe Epp::Eis::ContactCommands do
  
  before(:each) do
    @server = Epp::Server.new(:server => '127.0.0.1', :tag => 'username', :password => 'password')
  end
  
  describe 'check_contact' do

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
  
  describe 'create_contact' do
    context 'when response is successful' do
      before(:each) do
        @server.stub(:request).and_return(xml_mock('responses/create_contact_1000.xml'))
        @response = @server.create_contact('CID:TEST:10', 'Test', 'Test Street 11-2', 'Test City', '123456', 'EE', '+372.5555555', 'test@test.com', '37812124567', 'op')
      end

      it 'returns contact id' do
        @response.contact_id.should == 'CID:TEST:10'
      end

      it 'returns contact create date' do
        @response.contact_create_date.should == '2010-02-08T15:50:55+02:00'
      end
    end
  end
  
  describe 'info_contact' do
    context 'when response is successful' do
      before(:each) do
        @server.stub(:request).and_return(xml_mock('responses/info_contact_1000.xml'))
        @response = @server.info_contact('CID:TEST:1')
      end
      
      it 'returns contact id' do
        @response.contact_id.should == 'CID:TEST:1'
      end

      it 'returns roid' do
        @response.contact_roid.should == 'C0000000006-EPP'
      end

      it 'returns status' do
        @response.contact_status.should == 'linked'
      end
      
      it 'returns name' do
        @response.contact_name.should == 'Uus nimi ajee'
      end
      
      it 'returns street' do
        @response.contact_street.should == 'Kastani'
      end
      
      it 'returns city' do
        @response.contact_city.should == 'Tallinn'
      end
      
      it 'returns postal code' do
        @response.contact_postal_code.should == '10613'
      end
      
      it 'returns country code' do
        @response.contact_country_code.should == 'EE'
      end
      
      it 'returns contact email' do
        @response.contact_email.should == 'test@test.host'
      end
    end
  end
  
  describe 'update_contact' do
    context 'when response is successful' do
      before(:each) do
        @server.stub(:request).and_return(xml_mock('responses/update_contact_1000.xml'))
        @response = @server.update_contact('CID:TEST:10', nil, nil, nil, nil, nil, nil, nil, nil, 'op', legal_mock('test.pdf'), 'pdf')
      end

      it 'returns response code' do
        @response.code.should == 1000
      end

      it 'returns response message' do
        @response.message.should == 'Command completed successfully'
      end
    end
  end
end
