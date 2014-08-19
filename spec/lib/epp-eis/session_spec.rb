require 'spec_helper'

describe 'hello' do
  before(:each) do
    @server = Epp::Server.new(server: '127.0.0.1', tag: 'username', password: 'password')
  end
  
  context 'when response is successful' do
    before(:each) do
      expect(@server).to receive(:send_request).and_return(xml_mock('responses/session/hello.xml'))
      @response = @server.hello
    end
    
    it 'returns version number' do
      expect(@response.version).to eq('1.0')
    end
  end
end
