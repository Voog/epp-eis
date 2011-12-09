require 'spec_helper'

describe 'check_domain' do
  
  before(:each) do
    @server = Epp::Server.new(
      :server => '127.0.0.1',
      :tag => 'username',
      :password => 'password'
      # :cert => OpenSSL::X509::Certificate.new(File.open('certificate.pem')),
      # :key => OpenSSL::PKey::RSA.new(File.open('priv_key.pem'))
    )
    # @server.stub(:send_request).and_return('<?xml version="1.0" encoding="UTF-8"?>')
  end
  
end
