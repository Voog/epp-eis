module Epp
  module Eis
    
    XML_NS_CONTACT = 'http://www.nic.cz/xml/epp/contact-1.6'
    
    class ContactCheck
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

    class ContactCheckResponse

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
        @response.css('contact|chkData contact|cd', 'contact' => XML_NS_CONTACT).collect do |contact|
          ContactCheck.new(
            contact.css('contact|id', 'contact' => XML_NS_CONTACT).text,
            contact.css('contact|id', 'contact' => XML_NS_CONTACT).first['avail'].to_i == 1,
            contact.css('contact|reason', 'contact' => XML_NS_CONTACT).text
          )
        end
      end
    end
    
    module ContactCommands
      
      # Check availability for a contact id. You may provide multiple contact id names.
      def check_contact(*contacts)
        builder = build_epp_request do |xml|
          xml.command {
            xml.check {
              xml.check('xmlns:contact' => XML_NS_CONTACT, 'xsi:schemaLocation' => 'http://www.nic.cz/xml/epp/domain-1.4.xsd') {
                xml.parent.namespace = xml.parent.namespace_definitions.first
                contacts.each { |contact| xml.id_ contact }
              }
            }
            xml.clTRID UUIDTools::UUID.timestamp_create.to_s
          }
        end

        ContactCheckResponse.new(request(builder.to_xml))
      end
      
      def create_contact
      end
      
      def delete_contact
      end
      
      def info_contact
      end
      
      def list_contacts
      end
      
      def update_contact
      end
    end
  end
end

Epp::Server.send(:include, Epp::Eis::ContactCommands)
