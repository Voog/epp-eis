module Epp
  module Eis
    
    XML_NS_DOMAIN = 'http://www.nic.cz/xml/epp/domain-1.4'
    
    XML_DOMAIN_SCHEMALOC = 'http://www.nic.cz/xml/epp/domain-1.4.xsd domain-1.4.xsd'

    class DomainCreateResponse
      def initialize(response)
        @response = Nokogiri::XML(response)
      end
      
      def code
        @response.css('epp response result').first['code'].to_i
      end

      def message
        @response.css('epp response result msg').text
      end
      
      def domain_name
        @response.css('domain|creData domain|name', 'domain' => XML_NS_DOMAIN).text
      end
      
      def domain_create_date
        @response.css('domain|creData domain|crDate', 'domain' => XML_NS_DOMAIN).text
      end
      
      def domain_expire_date
        @response.css('domain|creData domain|exDate', 'domain' => XML_NS_DOMAIN).text
      end
    end
    
    class DomainDeleteResponse
      def initialize(response)
        @response = Nokogiri::XML(response)
      end
      
      def code
        @response.css('epp response result').first['code'].to_i
      end

      def message
        @response.css('epp response result msg').text
      end
    end

    class DomainTransferResponse
      def initialize(response)
        @response = Nokogiri::XML(response)
      end
      
      def code
        @response.css('epp response result').first['code'].to_i
      end

      def message
        @response.css('epp response result msg').text
      end
    end
    
    class DomainUpdateResponse
      def initialize(response)
        @response = Nokogiri::XML(response)
      end
      
      def code
        @response.css('epp response result').first['code'].to_i
      end

      def message
        @response.css('epp response result msg').text
      end
    end

    class DomainInfoResponse
      def initialize(response)
        @response = Nokogiri::XML(response)
      end
      
      def code
        @response.css('epp response result').first['code'].to_i
      end

      def message
        @response.css('epp response result msg').text
      end
      
      def domain_name
        @response.css('domain|infData domain|name', 'domain' => XML_NS_DOMAIN).text
      end

      def domain_roid
        @response.css('domain|infData domain|roid', 'domain' => XML_NS_DOMAIN).text
      end

      def domain_status
        @response.css('domain|infData domain|status', 'domain' => XML_NS_DOMAIN).text
      end
      
      def domain_registrant
        @response.css('domain|infData domain|registrant', 'domain' => XML_NS_DOMAIN).text
      end
      
      def domain_admin
        @response.css('domain|infData domain|admin', 'domain' => XML_NS_DOMAIN).text
      end
      
      def domain_nsset
        @response.css('domain|infData domain|nsset', 'domain' => XML_NS_DOMAIN).text
      end
      
      def domain_clid
        @response.css('domain|infData domain|clID', 'domain' => XML_NS_DOMAIN).text
      end
      
      def domain_crid
        @response.css('domain|infData domain|crID', 'domain' => XML_NS_DOMAIN).text
      end
      
      def domain_create_date
        @response.css('domain|infData domain|crDate', 'domain' => XML_NS_DOMAIN).text
      end
      
      def domain_expire_date
        @response.css('domain|infData domain|exDate', 'domain' => XML_NS_DOMAIN).text
      end
      
      def domain_authinfo
        @response.css('domain|infData domain|authInfo', 'domain' => XML_NS_DOMAIN).text
      end
    end

    class DomainRenewResponse
      def initialize(response)
        @response = Nokogiri::XML(response)
      end
      
      def code
        @response.css('epp response result').first['code'].to_i
      end

      def message
        @response.css('epp response result msg').text
      end
      
      def domain_name
        @response.css('domain|renData domain|name', 'domain' => XML_NS_DOMAIN).text
      end
      
      def domain_expire_date
        @response.css('domain|renData domain|exDate', 'domain' => XML_NS_DOMAIN).text
      end
    end

    class DomainCheck
      attr_accessor :name, :available, :reason

      def initialize(name, available, reason)
        @name = name
        @available = available
        @reason = reason
      end

      def available?
        @available
      end
    end

    class DomainCheckResponse

      def initialize(response)
        @response = Nokogiri::XML(response)
      end

      def code
        @response.css('epp response result').first['code'].to_i
      end

      def message
        @response.css('epp response result msg').text
      end

      def items
        @response.css('domain|chkData domain|cd', 'domain' => XML_NS_DOMAIN).collect do |domain|
          DomainCheck.new(
            domain.css('domain|name', 'domain' => XML_NS_DOMAIN).text,
            domain.css('domain|name', 'domain' => XML_NS_DOMAIN).first['avail'].to_i == 1,
            domain.css('domain|reason', 'domain' => XML_NS_DOMAIN).text
          )
        end
      end
    end
    
    module DomainCommands
      
      # Create a new domain.
      #
      # Domain names with IDN characters õ, ä. ö. ü, š, ž will be allowed. If a domain name contains at least one of
      # these characters then it must be translated to PUNYCODE before domain create.
      #
      # domain          - Domain name to be registered
      # nsset           - Nameserver id
      # registrant      - Registrant contact id
      # admin           - Admin contact id, or array of id-s
      # legal_document  - Legal document binary data
      # legal_doc_type  - Legal document type (pdf, ddoc)
      #
      # Returns DomainCreateResponse object
      def create_domain(domain, nsset, registrant, admins, legal_document, legal_doc_type)
        builder = build_epp_request do |xml|
          xml.command {
            xml.create {
              xml.create('xmlns:domain' => XML_NS_DOMAIN, 'xsi:schemaLocation' => XML_DOMAIN_SCHEMALOC) {
                xml.parent.namespace = xml.parent.namespace_definitions.first
                xml['domain'].name domain
                xml['domain'].period '1', 'unit' => 'y'
                xml['domain'].nsset nsset
                xml['domain'].registrant registrant
                [admins].flatten.each { |admin| xml['domain'].admin admin }
              }
            }
            append_legal_document(xml, legal_document, legal_doc_type)
            xml.clTRID UUIDTools::UUID.timestamp_create.to_s
          }
        end
        
        DomainCreateResponse.new(send_request(builder.to_xml))
      end
      
      # Delete domain.
      #
      # domain          - Domain name to be registered
      # legal_document  - Legal document binary data
      # legal_doc_type  - Legal document type (pdf, ddoc)
      #
      # Returns DomainDeleteResponse object
      def delete_domain(domain, legal_document, legal_doc_type)
        builder = build_epp_request do |xml|
          xml.command {
            xml.delete {
              xml.delete('xmlns:domain' => XML_NS_DOMAIN, 'xsi:schemaLocation' => XML_DOMAIN_SCHEMALOC) {
                xml.parent.namespace = xml.parent.namespace_definitions.first
                xml['domain'].name domain
              }
            }
            append_legal_document(xml, legal_document, legal_doc_type)
            xml.clTRID UUIDTools::UUID.timestamp_create.to_s
          }
        end
        
        DomainDeleteResponse.new(send_request(builder.to_xml))
      end
      
      # Will return detailed information about the domain. The information will include domain password field. The field
      # will be populated with a real value if the domain owner executed the function. Non-owner will see empty domain
      # password field value.
      #
      # domain  - Domain name to be queried
      #
      # Returns DomainInfoResponse object
      def info_domain(domain)
        builder = build_epp_request do |xml|
          xml.command {
            xml.info {
              xml.info('xmlns:domain' => XML_NS_DOMAIN, 'xsi:schemaLocation' => XML_DOMAIN_SCHEMALOC) {
                xml.parent.namespace = xml.parent.namespace_definitions.first
                xml['domain'].name domain
              }
            }
            xml.clTRID UUIDTools::UUID.timestamp_create.to_s
          }
        end
        
        DomainInfoResponse.new(send_request(builder.to_xml))
      end
      
      # Updates domain expiration period for another year.
      #
      # domain                - Domain to be renewed
      # current_expire_date   - Current expiration date of the domain in YYYY-MM-DD format
      #
      # Returns DomainRenewResponse object with server response information
      def renew_domain(domain, current_expire_date)
        builder = build_epp_request do |xml|
          xml.command {
            xml.renew {
              xml.renew('xmlns:domain' => XML_NS_DOMAIN, 'xsi:schemaLocation' => XML_DOMAIN_SCHEMALOC) {
                xml.parent.namespace = xml.parent.namespace_definitions.first
                xml['domain'].name domain
                xml['domain'].curExpDate current_expire_date
                xml['domain'].period '1', 'unit' => 'y'
              }
            }
            xml.clTRID UUIDTools::UUID.timestamp_create.to_s
          }
        end
        
        DomainRenewResponse.new(send_request(builder.to_xml))
      end
      
      # Used to transfer domain ownership from one registrar to another.
      #
      # domain      - Name of the domain to be transferred
      # auth_info   - Domain authorization code
      #
      # Returns DomainTransferResponse object
      def transfer_domain(domain, auth_info, legal_document, legal_doc_type)
        builder = build_epp_request do |xml|
          xml.command {
            xml.transfer('op' => 'request') {
              xml.transfer('xmlns:domain' => XML_NS_DOMAIN, 'xsi:schemaLocation' => XML_DOMAIN_SCHEMALOC) {
                xml.parent.namespace = xml.parent.namespace_definitions.first
                xml['domain'].name domain
                xml['domain'].authInfo auth_info
              }
            }
            append_legal_document(xml, legal_document, legal_doc_type)
            xml.clTRID UUIDTools::UUID.timestamp_create.to_s
          }
        end
        
        DomainTransferResponse.new(send_request(builder.to_xml))
      end
      
      # Used to update domain information.
      #
      # domain          - Domain name to be updated
      # add_admins      - Array of admin contact ids to be added. Set to nil or empty array if no changes needed
      # rem_admins      - Array of admin contact ids to be removed. Set to nil or empty array if no changes needed
      # nsset           - Domain nsset id to be changed. Set to nil if no changes needed
      # registrant      - Domain registrant contact id to be changed. Set to nil if no changes needed
      # auth_info       - Domain authorization code to be changed. Set to nil if no changes needed
      # legal_document  - Legal document binary data
      # legal_doc_type  - Legal document type (pdf, ddoc)
      # 
      # Returns DomainUpdateResponse object
      def update_domain(domain, add_admins, rem_admins, nsset, registrant, auth_info, legal_document, legal_doc_type)
        builder = build_epp_request do |xml|
          xml.command {
            xml.update {
              xml.update('xmlns:domain' => XML_NS_DOMAIN, 'xsi:schemaLocation' => XML_DOMAIN_SCHEMALOC) {
                xml.parent.namespace = xml.parent.namespace_definitions.first
                xml['domain'].name domain
                if !add_admins.nil? && !add_admins.empty?
                  xml['domain'].add {
                    add_admins.each { |add_admin| xml['domain'].admin add_admin }
                  }
                end
                if !rem_admins.nil? && !rem_admins.empty?
                  xml['domain'].rem {
                    rem_admins.each { |rem_admin| xml['domain'].admin rem_admin }
                  }
                end
                if [nsset, registrant, auth_info].any?{ |item| !item.nil? }
                  xml['domain'].chg {
                    xml['domain'].nsset nsset if nsset
                    xml['domain'].registrant registrant if registrant
                    xml['domain'].auth_info auth_info if auth_info
                  }
                end
              }
            }
            append_legal_document(xml, legal_document, legal_doc_type)
            xml.clTRID UUIDTools::UUID.timestamp_create.to_s
          }
        end
        
        DomainUpdateResponse.new(send_request(builder.to_xml))
      end
      
      def list_domains
        list_command('listDomains')
      end

      # Check availability for a domain or a list of domains.
      #
      # Returns DomainCheckResponse object with server response information
      def check_domain(*domains)
        builder = build_epp_request do |xml|
          xml.command {
            xml.check {
              xml.check('xmlns:domain' => XML_NS_DOMAIN, 'xsi:schemaLocation' => XML_DOMAIN_SCHEMALOC) {
                xml.parent.namespace = xml.parent.namespace_definitions.first
                domains.each do |domain|
                  xml['domain'].name domain
                end
              }
            }
            xml.clTRID UUIDTools::UUID.timestamp_create.to_s
          }
        end
        
        DomainCheckResponse.new(send_request(builder.to_xml))
      end
      
      # Shortcut function to check whether domain is available.
      #
      # domain  - Domain name to be checked
      #
      # Returns true if domain is available and false if it is not.
      def is_domain_available?(domain)
        results = check_domain(domain).items
        results.nil? ? false : results.first.available?
      end
    end
  end
end

Epp::Server.send(:include, Epp::Eis::DomainCommands)
