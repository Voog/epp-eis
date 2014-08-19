require 'spec_helper'

describe Epp::Eis::DomainCommands do

  before(:each) do
    @server = Epp::Server.new(server: '127.0.0.1', tag: 'username', password: 'password')
  end

  describe 'create_domain' do
    before(:each) do
      expect(@server).to receive(:send_request) do |xml|
        @request = Nokogiri::XML(xml)
        xml_mock('responses/domain/create_domain_1000.xml')
      end
      @response = @server.create_domain('testing.ee', 'name_server_set1', 'domain_registrator1', ['administrative_contact1', 'administrative_contact2'], legal_mock('test.pdf'), 'pdf')
    end
    
    context 'request' do
      it 'contains domain name' do
        expect(@request.css('domain|create domain|name', 'domain' => Epp::Eis::XML_NS_DOMAIN).text).to eq('testing.ee')
      end

      it 'contains registration period' do
        expect(@request.css('domain|create domain|period', 'domain' => Epp::Eis::XML_NS_DOMAIN).text).to eq('1')
      end
      
      it 'contains registration period unit' do
        expect(@request.css('domain|create domain|period', 'domain' => Epp::Eis::XML_NS_DOMAIN).first['unit']).to eq('y')
      end
      
      it 'contains nsset' do
        expect(@request.css('domain|create domain|nsset', 'domain' => Epp::Eis::XML_NS_DOMAIN).text).to eq('name_server_set1')
      end

      it 'contains registrant' do
        expect(@request.css('domain|create domain|registrant', 'domain' => Epp::Eis::XML_NS_DOMAIN).text).to eq('domain_registrator1')
      end

      it 'contains administrative contacts' do
        expect(@request.css('domain|create domain|admin', 'domain' => Epp::Eis::XML_NS_DOMAIN).collect{ |n| n.text }).to include('administrative_contact1', 'administrative_contact2')
      end
    end
    
    context 'response' do
      it 'returns domain name' do
        expect(@response.domain_name).to eq('testing.ee')
      end
      
      it 'returns domain create date' do
        expect(@response.domain_create_date).to eq('2010-02-15T19:50:00+02:00')
      end
      
      it 'returns domain expire date' do
        expect(@response.domain_expire_date).to eq('2011-02-15')
      end
    end
  end
  
  describe 'delete_domain' do
    context 'when response is successful' do
      before(:each) do
        expect(@server).to receive(:send_request).and_return(xml_mock('responses/domain/delete_domain_1000.xml'))
        @response = @server.delete_domain('testing.ee', legal_mock('test.pdf'), 'pdf')
      end
      
      it 'returns response code' do
        expect(@response.code).to eq(1000)
      end
      
      it 'returns response message' do
        expect(@response.message).to eq('Command completed successfully')
      end
    end
  end
  
  describe 'info_domain' do
    context 'when response is successful' do
      before(:each) do
        expect(@server).to receive(:send_request).and_return(xml_mock('responses/domain/info_domain_1000.xml'))
        @response = @server.info_domain('testing.ee')
      end
      
      it 'returns domain name' do
        expect(@response.domain_name).to eq('testing.ee')
      end
  
      it 'returns domain roid' do
        expect(@response.domain_roid).to eq('D0000000052-EPP')
      end
      
      it 'returns domain status' do
        expect(@response.domain_status).to eq('Objekt is without restrictions')
      end
      
      it 'returns domain registrant' do
        expect(@response.domain_registrant).to eq('MARGUSTEST2')
      end
      
      it 'returns domain admin contact' do
        expect(@response.domain_admin).to eq('MARGUSTEST3')
      end
      
      it 'returns domain nsset' do
        expect(@response.domain_nsset).to eq('RACKSPACE1')
      end
      
      it 'returns domain clid' do
        expect(@response.domain_clid).to eq('margus')
      end
  
      it 'returns domain crid' do
        expect(@response.domain_crid).to eq('margus')
      end
      
      it 'returns domain create date' do
        expect(@response.domain_create_date).to eq('2010-02-15T19:50:00+02:00')
      end
      
      it 'returns domain expire date' do
        expect(@response.domain_expire_date).to eq('2011-02-15')
      end
      
      it 'returns domain password' do
        expect(@response.domain_authinfo).to eq('b23G6IDH')
      end
    end
  end
  
  describe 'renew_domain' do
    context 'when response is successful' do
      before(:each) do
        expect(@server).to receive(:send_request).and_return(xml_mock('responses/domain/renew_domain_1000.xml'))
      end
      
      it 'returns domain name' do
        expect(@server.renew_domain('testing.ee', '2011-02-15').domain_name).to eq('testing.ee')
      end
      
      it 'returns next expire date' do
        expect(@server.renew_domain('testing.ee', '2011-02-15').domain_expire_date).to eq('2012-02-15')
      end
    end
  end
  
  describe 'transfer_domain' do
    context 'when response is successful' do
      before(:each) do
        expect(@server).to receive(:send_request).and_return(xml_mock('responses/domain/transfer_domain_1000.xml'))
        @response = @server.transfer_domain('teinetest.ee', 'r3aVYGOz', legal_mock('test.pdf'), 'pdf')
      end
      
      it 'returns response code' do
        expect(@response.code).to eq(1000)
      end
      
      it 'returns response message' do
        expect(@response.message).to eq('Command completed successfully')
      end
    end
  end
  
  describe 'update_domain' do
    context 'when response is successful' do
      before(:each) do
        expect(@server).to receive(:send_request).and_return(xml_mock('responses/domain/update_domain_1000.xml'))
        @response = @server.update_domain('testimine.ee', nil, nil, nil, nil, nil, legal_mock('test.pdf'), 'pdf')
      end
      
      it 'returns response code' do
        expect(@response.code).to eq(1000)
      end
      
      it 'returns response message' do
        expect(@response.message).to eq('Command completed successfully')
      end
    end
  end
  
  describe 'check_domain' do
    context 'when response is successful' do
      before(:each) do
        expect(@server).to receive(:send_request).and_return(xml_mock('responses/domain/check_domain_1000.xml'))
      end
      
      it 'has status code 1000' do
        expect(@server.check_domain('fraktal.ee').code).to eq(1000)
      end
      
      context 'when multiple domain names are provided' do
        it 'has multiple domain check items in response object' do
          expect(@server.check_domain('fraktal.ee', 'edicypages.ee').items.size).to eq(2)
        end
      end
    end
  end
  
  describe 'is_domain_available?' do
    context 'when domain is available' do
      before(:each) do
        expect(@server).to receive(:send_request).and_return(xml_mock('responses/domain/check_domain_available_1000.xml'))
      end
      
      it 'returns true' do
        expect(@server.is_domain_available?('edicypages.ee')).to eq(true)
      end
    end
    
    context 'when domain is not available' do
      before(:each) do
        expect(@server).to receive(:send_request).and_return(xml_mock('responses/domain/check_domain_taken_1000.xml'))
      end
      
      it 'returns false' do
        expect(@server.is_domain_available?('fraktal.ee')).to eq(false)
      end
    end
  end
end
