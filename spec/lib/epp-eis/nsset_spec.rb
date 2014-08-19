require 'spec_helper'

describe Epp::Eis::NssetCommands do
  
  before(:each) do
    @server = Epp::Server.new(server: '127.0.0.1', tag: 'username', password: 'password')
  end
  
  describe 'check_nsset' do
    before(:each) do
      expect(@server).to receive(:send_request) do |xml|
        @request = Nokogiri::XML(xml)
        xml_mock('responses/nsset/check_nsset_1000.xml')
      end
    end
    
    context 'request' do
      it 'contains nsset id' do
        @server.check_nsset('NSSID:TEST:1')
        expect(@request.css('nsset|check nsset|id', 'nsset' => Epp::Eis::XML_NS_NSSET).text).to eq('NSSID:TEST:1')
      end
    end

    context 'response' do
      it 'has status code 1000' do
        expect(@server.check_nsset('NSSID:TEST:1').code).to eq(1000)
      end

      context 'when multiple nsset names are provided' do
        it 'has multiple nsset check items in response object' do
          expect(@server.check_nsset('NSSID:TEST:1', 'NSSID:TEST:2').items.size).to eq(2)
        end
      end
    end
  end
  
  describe 'create_nsset' do
    before(:each) do
      expect(@server).to receive(:send_request) do |xml|
        @request = Nokogiri::XML(xml)
        xml_mock('responses/nsset/create_nsset_1000.xml')
      end
      @response = @server.create_nsset('NSSID:TEST:2', [['test.com', '123.123.123.123'], ['ns2.test.com', '111.111.111.111']], 'test1')
    end
    
    context 'request' do
      it 'contains nsset id' do
        expect(@request.css('nsset|create nsset|id', 'nsset' => Epp::Eis::XML_NS_NSSET).text).to eq('NSSID:TEST:2')
      end
      
      it 'contains nameserver names' do
        expect(@request.css('nsset|create nsset|ns nsset|name', 'nsset' => Epp::Eis::XML_NS_NSSET).collect{ |n| n.text }).to include('test.com', 'ns2.test.com')
      end
      
      it 'contains nameserver ip addresses' do
        expect(@request.css('nsset|create nsset|ns nsset|addr', 'nsset' => Epp::Eis::XML_NS_NSSET).collect{ |n| n.text }).to include('123.123.123.123', '111.111.111.111')
      end
      
      it 'contains technical contact' do
        expect(@request.css('nsset|create nsset|tech', 'nsset' => Epp::Eis::XML_NS_NSSET).text).to eq('test1')
      end
    end
    
    context 'response' do
      it 'returns nsset id' do
        expect(@response.nsset_id).to eq('NSSID:TEST:2')
      end

      it 'returns nsset create date' do
        expect(@response.nsset_create_date).to eq('2010-02-08T16:27:22+02:00')
      end
    end
  end

  describe 'info_nsset' do
    before(:each) do
      expect(@server).to receive(:send_request) do |xml|
        @request = Nokogiri::XML(xml)
        xml_mock('responses/nsset/info_nsset_1000.xml')
      end
      @response = @server.info_nsset('NSSID:TEST:2')
    end
    
    context 'request' do
      it 'contains nsset id' do
        expect(@request.css('nsset|info nsset|id', 'nsset' => Epp::Eis::XML_NS_NSSET).text).to eq('NSSID:TEST:2')
      end
    end
    
    context 'response' do
      it 'returns nsset id' do
        expect(@response.nsset_id).to eq('NSSID:TEST:2')
      end

      it 'returns roid' do
        expect(@response.nsset_roid).to eq('N0000000051-EPP')
      end

      it 'returns status' do
        expect(@response.nsset_status).to eq('ok')
      end
      
      it 'returns nameservers' do
        expect(@response.nameservers).to eq([['test.com', '123.123.123.123'], ['ns2.test.com', '111.111.111.111']])
      end
    end
  end
  
  describe 'update_nsset' do
    before(:each) do
      expect(@server).to receive(:send_request) do |xml|
        @request = Nokogiri::XML(xml)
        xml_mock('responses/nsset/update_nsset_1000.xml')
      end
      @response = @server.update_nsset('NSSID:TEST:2', [['ns3.test.com', '112.112.112.112']], 'margustech1', 'ns2.test.com', 'tech1')
    end
    
    context 'request' do
      it 'contains nsset id' do
        expect(@request.css('nsset|update nsset|id', 'nsset' => Epp::Eis::XML_NS_NSSET).text).to eq('NSSID:TEST:2')
      end
      
      it 'contains nameserver names to be added' do
        expect(@request.css('nsset|update nsset|add nsset|ns nsset|name', 'nsset' => Epp::Eis::XML_NS_NSSET).text).to eq('ns3.test.com')
      end
      
      it 'contains nameserver ip addresses to be added' do
        expect(@request.css('nsset|update nsset|add nsset|ns nsset|addr', 'nsset' => Epp::Eis::XML_NS_NSSET).text).to eq('112.112.112.112')
      end
      
      it 'contains tech contact to be added' do
        expect(@request.css('nsset|update nsset|add nsset|tech', 'nsset' => Epp::Eis::XML_NS_NSSET).text).to eq('margustech1')
      end
      
      it 'contains nameserver to be removed' do
        expect(@request.css('nsset|update nsset|rem nsset|name', 'nsset' => Epp::Eis::XML_NS_NSSET).text).to eq('ns2.test.com')
      end
      
      it 'contains tech contact to be removed' do
        expect(@request.css('nsset|update nsset|rem nsset|tech', 'nsset' => Epp::Eis::XML_NS_NSSET).text).to eq('tech1')
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
