module Epp
  module Eis
    
    XML_NS_DOMAIN = 'http://www.nic.cz/xml/epp/domain-1.4'

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
      
      def create_domain(domain, period, nsset, registrant, admin, legal_document)
      end
      
      def delete_domain
      end
      
      def info_domain(domain)
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
              xml.renew('xmlns:domain' => XML_NS_DOMAIN, 'xsi:schemaLocation' => 'http://www.nic.cz/xml/epp/domain-1.4.xsd') {
                xml.parent.namespace = xml.parent.namespace_definitions.first
                xml.name domain
                xml.curExpDate current_expire_date
                xml.period '1', 'unit' => period_unit
              }
            }
            xml.clTRID UUIDTools::UUID.timestamp_create.to_s
          }
        end
        
        DomainRenewResponse.new(request(builder.to_xml))
      end
      
      def transfer_domain
      end
      
      def update_domain
      end
      
      def list_domains
      end

      # Check availability for a domain or a list of domains.
      #
      # Returns DomainCheckResponse object with server response information
      def check_domain(*domains)
        builder = build_epp_request do |xml|
          xml.command {
            xml.check {
              xml.send('check', 'xmlns:domain' => XML_NS_DOMAIN, 'xsi:schemaLocation' => 'http://www.nic.cz/xml/epp/domain-1.4.xsd') {
                xml.parent.namespace = xml.parent.namespace_definitions.first
                domains.each do |domain|
                  xml.name domain
                end
              }
            }
            xml.clTRID UUIDTools::UUID.timestamp_create.to_s
          }
        end

        DomainCheckResponse.new(request(builder.to_xml))
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
