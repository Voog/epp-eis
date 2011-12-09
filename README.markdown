## Usage

    require 'eis-epp'

    server = Epp::Server.new(
      :server => '127.0.0.1',
      :tag => 'username',
      :password => 'password',
      :cert => OpenSSL::X509::Certificate.new(File.open('certificate.pem')),
      :key => OpenSSL::PKey::RSA.new(File.open('priv_key.pem'))
    )
    
    server.check_domain('fraktal.ee', 'edicypages.ee')
    
    <domain:chkData xmlns:domain="http://www.nic.cz/xml/epp/domain-1.4" xsi:schemaLocation="http://www.nic.cz/xml/epp/domain-1.4 domain-1.4.xsd">
    <domain:cd>
      <domain:name avail="0">fraktal.ee</domain:name>
      <domain:reason>already registered.</domain:reason>
    </domain:cd>
    <domain:cd>
      <domain:name avail="1">edicypages.ee</domain:name>
    </domain:cd>
    </domain:chkData>

## TODO

* check_contact
* create_contact
* delete_contact
* info_contact
* list_contacts
* update_contact

* check_nsset
* create_nsset
* delete_nsset
* info_nsset
* list_nssets
* update_nsset
* transfer_nsset

* credit_info
* hello

## Nice to have

* check_keyset
* create_keyset
* delete_keyset
* get_results
* info_keyset
* list_keysets
* poll
* prep_contacts
* prep_domains
* prep_domains_by_contact
* prep_domains_by_keyset
* prep_domains_by_nsset
* prep_keysets
* prep_keysets_by_contact
* prep_nssets
* prep_nssets_by_contact
* prep_nssets_by_ns
* sendauthinfo_contact
* sendauthinfo_domain
* sendauthinfo_keyset
* sendauthinfo_nsset
* technical_test
* transfer_contact
* transfer_keyset
* update_keyset
