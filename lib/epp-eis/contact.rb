module Epp
  module Eis
    
    XML_NS_CONTACT = 'http://www.nic.cz/xml/epp/contact-1.6'
    
    XML_CONTACT_SCHEMALOC = 'http://www.nic.cz/xml/epp/contact-1.6 contact-1.6.xsd'
    
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
    
    class ContactCreateResponse
      def initialize(response)
        @response = Nokogiri::XML(response)
      end
      
      def code
        @response.css('epp response result').first['code'].to_i
      end

      def message
        @response.css('epp response result msg').text
      end
      
      def contact_id
        @response.css('contact|creData contact|id', 'contact' => XML_NS_CONTACT).text
      end
      
      def contact_create_date
        @response.css('contact|creData contact|crDate', 'contact' => XML_NS_CONTACT).text
      end
    end
    
    class ContactDeleteResponse
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
    
    class ContactInfoResponse
      def initialize(response)
        @response = Nokogiri::XML(response)
      end
      
      def code
        @response.css('epp response result').first['code'].to_i
      end

      def message
        @response.css('epp response result msg').text
      end
      
      def contact_id
        @response.css('contact|infData contact|id', 'contact' => XML_NS_CONTACT).text
      end

      def contact_roid
        @response.css('contact|infData contact|roid', 'contact' => XML_NS_CONTACT).text
      end

      def contact_status
        @response.css('contact|infData contact|status', 'contact' => XML_NS_CONTACT).first['s']
      end

      def contact_name
        @response.css('contact|infData contact|postalInfo contact|name', 'contact' => XML_NS_CONTACT).text
      end
      
      def contact_street
        @response.css('contact|infData contact|addr contact|street', 'contact' => XML_NS_CONTACT).text
      end
      
      def contact_city
        @response.css('contact|infData contact|addr contact|city', 'contact' => XML_NS_CONTACT).text
      end
      
      def contact_postal_code
        @response.css('contact|infData contact|addr contact|pc', 'contact' => XML_NS_CONTACT).text
      end
      
      def contact_country_code
        @response.css('contact|infData contact|addr contact|cc', 'contact' => XML_NS_CONTACT).text
      end
      
      def contact_email
        @response.css('contact|infData contact|email', 'contact' => XML_NS_CONTACT).text
      end
    end
    
    class ContactUpdateResponse
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
    
    module ContactCommands
      
      # Check availability for a contact id. You may provide multiple contact id names.
      def check_contact(*contacts)
        builder = build_epp_request do |xml|
          xml.command {
            xml.check {
              xml.check('xmlns:contact' => XML_NS_CONTACT, 'xsi:schemaLocation' => XML_CONTACT_SCHEMALOC) {
                xml.parent.namespace = xml.parent.namespace_definitions.first
                contacts.each { |contact| xml['contact'].id_ contact }
              }
            }
            xml.clTRID UUIDTools::UUID.timestamp_create.to_s
          }
        end

        ContactCheckResponse.new(send_request(builder.to_xml))
      end
      
      # Create a new contact object. The contact object will be available immediately.
      def create_contact(contact, name, street, city, postal_code, country_code, voice, email, ident, ident_type)
        builder = build_epp_request do |xml|
          xml.command {
            xml.create {
              xml.create('xmlns:contact' => XML_NS_CONTACT, 'xsi:schemaLocation' => XML_CONTACT_SCHEMALOC) {
                xml.parent.namespace = xml.parent.namespace_definitions.first
                xml['contact'].id_ contact
                xml['contact'].postalInfo {
                  xml['contact'].name name
                  xml['contact'].addr {
                    xml['contact'].street street
                    xml['contact'].city city
                    xml['contact'].pc postal_code
                    xml['contact'].cc country_code
                  }
                }
                xml['contact'].voice voice
                xml['contact'].email email
                xml['contact'].ident ident, 'type' => ident_type
              }
            }
            xml.clTRID UUIDTools::UUID.timestamp_create.to_s
          }
        end
        
        ContactCreateResponse.new(send_request(builder.to_xml))
      end
      
      # Delete contact handle. Contact object can not be deleted if it has relations to other objects like domains or
      # nssets.
      def delete_contact(contact)
        builder = build_epp_request do |xml|
          xml.command {
            xml.delete {
              xml.delete('xmlns:contact' => XML_NS_CONTACT, 'xsi:schemaLocation' => XML_CONTACT_SCHEMALOC) {
                xml.parent.namespace = xml.parent.namespace_definitions.first
                xml['contact'].id_ contact
              }
            }
            xml.clTRID UUIDTools::UUID.timestamp_create.to_s
          }
        end
        
        ContactDeleteResponse.new(send_request(builder.to_xml))
      end
      
      # Returns detailed information about a contact.
      def info_contact(contact)
        builder = build_epp_request do |xml|
          xml.command {
            xml.info {
              xml.info('xmlns:contact' => XML_NS_CONTACT, 'xsi:schemaLocation' => XML_CONTACT_SCHEMALOC) {
                xml.parent.namespace = xml.parent.namespace_definitions.first
                xml['contact'].id_ contact
              }
            }
            xml.clTRID UUIDTools::UUID.timestamp_create.to_s
          }
        end
        
        ContactInfoResponse.new(send_request(builder.to_xml))
      end
      
      def list_contacts
        list_command('listContacts')
      end
      
      # Update contact object. All domain and nsset objects will be updated as well.
      def update_contact(contact, name, street, city, postal_code, country_code, voice, email, ident, ident_type, legal_document, legal_doc_type)
        builder = build_epp_request do |xml|
          xml.command {
            xml.update {
              xml.update('xmlns:contact' => XML_NS_CONTACT, 'xsi:schemaLocation' => XML_CONTACT_SCHEMALOC) {
                xml.parent.namespace = xml.parent.namespace_definitions.first
                xml['contact'].id_ contact
                if [name, street, city, postal_code, country_code].any?{ |item| !item.nil? }
                  xml['contact'].postalInfo {
                    xml['contact'].name name if name
                    if [street, city, postal_code, country_code].any?{ |item| !item.nil? }
                      xml['contact'].addr {
                        xml['contact'].street street if street
                        xml['contact'].city city if city
                        xml['contact'].pc postal_code if postal_code
                        xml['contact'].cc country_code if country_code
                      }
                    end
                  }
                end
                xml['contact'].voice voice if voice
                xml['contact'].email email if email
                xml['contact'].ident ident, 'type' => ident_type
              }
            }
            append_legal_document(xml, legal_document, legal_doc_type)
            xml.clTRID UUIDTools::UUID.timestamp_create.to_s
          }
        end
        
        ContactUpdateResponse.new(send_request(builder.to_xml))
      end
    end
  end
end

Epp::Server.send(:include, Epp::Eis::ContactCommands)
