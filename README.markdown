Ruby client for Estonian Internet Foundation registry EPP server.

Under the hood, this gem uses magnificient [EPP server client](https://github.com/ultraspeed/epp) gem by Josh Delsman and Delwyn de Villiers.

## Installation

In Gemfile add it as a gem:

    gem 'epp-eis'

## Usage

    require 'epp-eis'

    server = Epp::Server.new(
      :server => '127.0.0.1',
      :tag => 'username',
      :password => 'password',
      :cert => OpenSSL::X509::Certificate.new(File.open('certificate.pem')),
      :key => OpenSSL::PKey::RSA.new(File.open('priv_key.pem'))
    )
    
    server.is_domain_available?('fraktal.ee') #=> false
    
## TODO

Need to implement the following commands

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

Commands that are nice to have, but not needed.

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
