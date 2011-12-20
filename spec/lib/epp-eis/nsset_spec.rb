require 'spec_helper'

describe Epp::Eis::NssetCommands do
  
  before(:each) do
    @server = Epp::Server.new(:server => '127.0.0.1', :tag => 'username', :password => 'password')
  end
  
  describe 'check_nsset' do

    context 'when response is successful' do

      before(:each) do
        @server.stub(:send_request).and_return(xml_mock('responses/nsset/check_nsset_1000.xml'))
      end

      it 'has status code 1000' do
        @server.check_nsset('NSSID:TEST:1').code.should == 1000
      end

      context 'when multiple nsset names are provided' do
        it 'has multiple nsset check items in response object' do
          @server.check_nsset('NSSID:TEST:1', 'NSSID:TEST:2').items.size.should == 2
        end
      end
    end
  end
  
  describe 'create_nsset' do
    context 'when response is successful' do
      before(:each) do
        @server.stub(:send_request).and_return(xml_mock('responses/nsset/create_nsset_1000.xml'))
        @response = @server.create_nsset('NSSID:TEST:2', [['test.com', '123.123.123.123'], ['ns2.test.com', '111.111.111.111']], 'test1')
      end

      it 'returns nsset id' do
        @response.nsset_id.should == 'NSSID:TEST:2'
      end

      it 'returns nsset create date' do
        @response.nsset_create_date.should == '2010-02-08T16:27:22+02:00'
      end
    end
  end

  describe 'info_nsset' do
    context 'when response is successful' do
      before(:each) do
        @server.stub(:send_request).and_return(xml_mock('responses/nsset/info_nsset_1000.xml'))
        @response = @server.info_nsset('NSSID:TEST:2')
      end
      
      it 'returns nsset id' do
        @response.nsset_id.should == 'NSSID:TEST:2'
      end

      it 'returns roid' do
        @response.nsset_roid.should == 'N0000000051-EPP'
      end

      it 'returns status' do
        @response.nsset_status.should == 'ok'
      end
      
      it 'returns nameservers' do
        @response.nameservers.should == [['test.com', '123.123.123.123'], ['ns2.test.com', '111.111.111.111']]
      end
    end
  end
  
  describe 'update_nsset' do
    context 'when response is successful' do
      before(:each) do
        @server.stub(:send_request).and_return(xml_mock('responses/nsset/update_nsset_1000.xml'))
        @response = @server.update_nsset('NSSID:TEST:2', [['ns3.test.com', '112.112.112.112']], 'margustech1', 'ns2.test.com', 'tech1')
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
