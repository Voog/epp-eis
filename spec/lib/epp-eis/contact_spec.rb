require 'spec_helper'

describe Epp::Eis::ContactCommands do
  
  before(:each) do
    @server = Epp::Server.new(:server => '127.0.0.1', :tag => 'username', :password => 'password')
  end
  
  describe 'check_contact' do
    before(:each) do
      @server.should_receive(:send_request) do |xml|
        @request = Nokogiri::XML(xml)
        xml_mock('responses/contact/check_contact_1000.xml')
      end
    end
    
    context 'request' do
      it 'contains contact id' do
        @server.check_contact('CID:FRAKTAL:1')
        expect(@request.css('contact|check contact|id', 'contact' => Epp::Eis::XML_NS_CONTACT).text).to eq('CID:FRAKTAL:1')
      end
    end
    
    context 'response' do
      it 'has status code 1000' do
        expect(@server.check_contact('CID:FRAKTAL:1').code).to eq(1000)
      end

      context 'when multiple contact names are provided' do
        it 'has multiple contact check items in response object' do
          expect(@server.check_contact('CID:FRAKTAL:1', 'CID:FRAKTAL:2').items.size).to eq(2)
        end
      end
    end
  end
  
  describe 'create_contact' do
    before(:each) do
      @server.should_receive(:send_request) do |xml|
        @request = Nokogiri::XML(xml)
        xml_mock('responses/contact/create_contact_1000.xml')
      end
      @response = @server.create_contact('CID:TEST:10', 'Test', 'Test Street 11-2', 'Test City', '123456', 'EE', '+372.5555555', 'test@test.com', '37812124567', 'op')
    end
    
    context 'request' do
      it 'contains contact id' do
        expect(@request.css('contact|create contact|id', 'contact' => Epp::Eis::XML_NS_CONTACT).text).to eq('CID:TEST:10')
      end
      
      it 'contains contact name' do
        expect(@request.css('contact|create contact|postalInfo contact|name', 'contact' => Epp::Eis::XML_NS_CONTACT).text).to eq('Test')
      end
      
      it 'contains street' do
        expect(@request.css('contact|create contact|postalInfo contact|addr contact|street', 'contact' => Epp::Eis::XML_NS_CONTACT).text).to eq('Test Street 11-2')
      end
      
      it 'contains city' do
        expect(@request.css('contact|create contact|postalInfo contact|addr contact|city', 'contact' => Epp::Eis::XML_NS_CONTACT).text).to eq('Test City')
      end
      
      it 'contains postal code' do
        expect(@request.css('contact|create contact|postalInfo contact|addr contact|pc', 'contact' => Epp::Eis::XML_NS_CONTACT).text).to eq('123456')
      end
      
      it 'contains country code' do
        expect(@request.css('contact|create contact|postalInfo contact|addr contact|cc', 'contact' => Epp::Eis::XML_NS_CONTACT).text).to eq('EE')
      end
      
      it 'contains phone number' do
        expect(@request.css('contact|create contact|voice', 'contact' => Epp::Eis::XML_NS_CONTACT).text).to eq('+372.5555555')
      end
      
      it 'contains phone email' do
        expect(@request.css('contact|create contact|email', 'contact' => Epp::Eis::XML_NS_CONTACT).text).to eq('test@test.com')
      end
      
      it 'contains identification code' do
        expect(@request.css('contact|create contact|ident', 'contact' => Epp::Eis::XML_NS_CONTACT).text).to eq('37812124567')
      end
      
      it 'contains identification type' do
        expect(@request.css('contact|create contact|ident', 'contact' => Epp::Eis::XML_NS_CONTACT).first['type']).to eq('op')
      end
    end
    
    context 'response' do
      it 'returns contact id' do
        expect(@response.contact_id).to eq('CID:TEST:10')
      end

      it 'returns contact create date' do
        expect(@response.contact_create_date).to eq('2010-02-08T15:50:55+02:00')
      end
    end
  end
  
  describe 'info_contact' do
    before(:each) do
      @server.should_receive(:send_request) do |xml|
        @request = Nokogiri::XML(xml)
        xml_mock('responses/contact/info_contact_1000.xml')
      end
      @response = @server.info_contact('CID:TEST:1')
    end
    
    context 'request' do
      it 'contains contact id' do
        expect(@request.css('contact|info contact|id', 'contact' => Epp::Eis::XML_NS_CONTACT).text).to eq('CID:TEST:1')
      end
    end
    
    context 'response' do
      it 'returns contact id' do
        expect(@response.contact_id).to eq('CID:TEST:1')
      end

      it 'returns roid' do
        expect(@response.contact_roid).to eq('C0000000006-EPP')
      end

      it 'returns status' do
        expect(@response.contact_status).to eq('linked')
      end
      
      it 'returns name' do
        expect(@response.contact_name).to eq('Uus nimi ajee')
      end
      
      it 'returns street' do
        expect(@response.contact_street).to eq('Kastani')
      end
      
      it 'returns city' do
        expect(@response.contact_city).to eq('Tallinn')
      end
      
      it 'returns postal code' do
        expect(@response.contact_postal_code).to eq('10613')
      end
      
      it 'returns country code' do
        expect(@response.contact_country_code).to eq('EE')
      end
      
      it 'returns contact email' do
        expect(@response.contact_email).to eq('test@test.host')
      end
    end
  end
  
  describe 'update_contact' do
    before(:each) do
      @server.should_receive(:send_request) do |xml|
        @request = Nokogiri::XML(xml)
        xml_mock('responses/contact/update_contact_1000.xml')
      end
      @response = @server.update_contact('CID:TEST:10', 'Test', 'Test Street 11-2', 'Test City', '123456', 'EE', '+372.5555555', 'test@test.com', '37812124567', 'op', legal_mock('test.pdf'), 'pdf')
    end
    
    context 'request' do
      it 'contains contact id' do
        expect(@request.css('contact|update contact|id', 'contact' => Epp::Eis::XML_NS_CONTACT).text).to eq('CID:TEST:10')
      end
      
      it 'contains contact name' do
        expect(@request.css('contact|update contact|postalInfo contact|name', 'contact' => Epp::Eis::XML_NS_CONTACT).text).to eql('Test')
      end
      
      it 'contains street' do
        expect(@request.css('contact|update contact|postalInfo contact|addr contact|street', 'contact' => Epp::Eis::XML_NS_CONTACT).text).to eql('Test Street 11-2')
      end
      
      it 'contains city' do
        expect(@request.css('contact|update contact|postalInfo contact|addr contact|city', 'contact' => Epp::Eis::XML_NS_CONTACT).text).to eql('Test City')
      end
      
      it 'contains postal code' do
        expect(@request.css('contact|update contact|postalInfo contact|addr contact|pc', 'contact' => Epp::Eis::XML_NS_CONTACT).text).to eql('123456')
      end
      
      it 'contains country code' do
        expect(@request.css('contact|update contact|postalInfo contact|addr contact|cc', 'contact' => Epp::Eis::XML_NS_CONTACT).text).to eql('EE')
      end
      
      it 'contains phone number' do
        expect(@request.css('contact|update contact|voice', 'contact' => Epp::Eis::XML_NS_CONTACT).text).to eql('+372.5555555')
      end
      
      it 'contains phone email' do
        expect(@request.css('contact|update contact|email', 'contact' => Epp::Eis::XML_NS_CONTACT).text).to eql('test@test.com')
      end
      
      it 'contains identification code' do
        expect(@request.css('contact|update contact|ident', 'contact' => Epp::Eis::XML_NS_CONTACT).text).to eql('37812124567')
      end
      
      it 'contains identification type' do
        expect(@request.css('contact|update contact|ident', 'contact' => Epp::Eis::XML_NS_CONTACT).first['type']).to eql('op')
      end
    end
    
    context 'response' do
      it 'returns response code' do
        expect(@response.code).to eq(1000)
      end

      it 'returns response message' do
        expect(@response.message).to eq('Command completed successfully')
      end
    end
  end
end
