require 'spec_helper'

describe 'create_domain' do
  before(:each) do
    @server = Epp::Server.new(:server => '127.0.0.1', :tag => 'username', :password => 'password')
  end
  
  context 'when response is successful' do
    before(:each) do
      @server.stub(:request).and_return(xml_mock('responses/domain/create_domain_1000.xml'))
      @response = @server.create_domain('testing.ee', 'name_server_set1', 'domain_registrator1', 'administrative_contact1', legal_mock('test.pdf'), 'pdf')
    end
    
    it 'returns domain name' do
      @response.domain_name.should == 'testing.ee'
    end
    
    it 'returns domain create date' do
      @response.domain_create_date.should == '2010-02-15T19:50:00+02:00'
    end
    
    it 'returns domain expire date' do
      @response.domain_expire_date.should == '2011-02-15'
    end
  end
end

describe 'delete_domain' do
  before(:each) do
    @server = Epp::Server.new(:server => '127.0.0.1', :tag => 'username', :password => 'password')
  end
  
  context 'when response is successful' do
    before(:each) do
      @server.stub(:request).and_return(xml_mock('responses/domain/delete_domain_1000.xml'))
      @response = @server.delete_domain('testing.ee', legal_mock('test.pdf'), 'pdf')
    end
    
    it 'returns response code' do
      @response.code.should == 1000
    end
    
    it 'returns response message' do
      @response.message.should == 'Command completed successfully'
    end
  end
end

describe 'info_domain' do
  before(:each) do
    @server = Epp::Server.new(:server => '127.0.0.1', :tag => 'username', :password => 'password')
  end
  
  context 'when response is successful' do
    before(:each) do
      @server.stub(:request).and_return(xml_mock('responses/domain/info_domain_1000.xml'))
      @response = @server.info_domain('testing.ee')
    end
    
    it 'returns domain name' do
      @response.domain_name.should == 'testing.ee'
    end

    it 'returns domain roid' do
      @response.domain_roid.should == 'D0000000052-EPP'
    end
    
    it 'returns domain status' do
      @response.domain_status.should == 'Objekt is without restrictions'
    end
    
    it 'returns domain registrant' do
      @response.domain_registrant.should == 'MARGUSTEST2'
    end
    
    it 'returns domain admin contact' do
      @response.domain_admin.should == 'MARGUSTEST3'
    end
    
    it 'returns domain nsset' do
      @response.domain_nsset.should == 'RACKSPACE1'
    end
    
    it 'returns domain clid' do
      @response.domain_clid.should == 'margus'
    end

    it 'returns domain crid' do
      @response.domain_crid.should == 'margus'
    end
    
    it 'returns domain create date' do
      @response.domain_create_date.should == '2010-02-15T19:50:00+02:00'
    end
    
    it 'returns domain expire date' do
      @response.domain_expire_date.should == '2011-02-15'
    end
    
    it 'returns domain password' do
      @response.domain_authinfo.should == 'b23G6IDH'
    end
  end
end

describe 'renew_domain' do
  before(:each) do
    @server = Epp::Server.new(:server => '127.0.0.1', :tag => 'username', :password => 'password')
  end
  
  context 'when response is successful' do
    before(:each) do
      @server.stub(:request).and_return(xml_mock('responses/domain/renew_domain_1000.xml'))
    end
    
    it 'returns domain name' do
      @server.renew_domain('testing.ee', '2011-02-15').domain_name.should == 'testing.ee'
    end
    
    it 'returns next expire date' do
      @server.renew_domain('testing.ee', '2011-02-15').domain_expire_date.should == '2012-02-15'
    end
  end
end

describe 'transfer_domain' do
  before(:each) do
    @server = Epp::Server.new(:server => '127.0.0.1', :tag => 'username', :password => 'password')
  end
  
  context 'when response is successful' do
    before(:each) do
      @server.stub(:request).and_return(xml_mock('responses/domain/transfer_domain_1000.xml'))
      @response = @server.transfer_domain('teinetest.ee', 'r3aVYGOz', legal_mock('test.pdf'), 'pdf')
    end
    
    it 'returns response code' do
      @response.code.should == 1000
    end
    
    it 'returns response message' do
      @response.message.should == 'Command completed successfully'
    end
  end
end

describe 'update_domain' do
  before(:each) do
    @server = Epp::Server.new(:server => '127.0.0.1', :tag => 'username', :password => 'password')
  end
  
  context 'when response is successful' do
    before(:each) do
      @server.stub(:request).and_return(xml_mock('responses/domain/update_domain_1000.xml'))
      @response = @server.update_domain('testimine.ee', nil, nil, nil, nil, nil, legal_mock('test.pdf'), 'pdf')
    end
    
    it 'returns response code' do
      @response.code.should == 1000
    end
    
    it 'returns response message' do
      @response.message.should == 'Command completed successfully'
    end
  end
end

describe 'check_domain' do
  
  before(:each) do
    @server = Epp::Server.new(:server => '127.0.0.1', :tag => 'username', :password => 'password')
  end
  
  context 'when response is successful' do
    
    before(:each) do
      @server.stub(:request).and_return(xml_mock('responses/domain/check_domain_1000.xml'))
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
      @server.stub(:request).and_return(xml_mock('responses/domain/check_domain_available_1000.xml'))
    end
    
    it 'returns true' do
      @server.is_domain_available?('edicypages.ee').should be_true
    end
  end
  
  context 'when domain is not available' do
    before(:each) do
      @server.stub(:request).and_return(xml_mock('responses/domain/check_domain_taken_1000.xml'))
    end
    
    it 'returns false' do
      @server.is_domain_available?('fraktal.ee').should be_false
    end
  end
end
