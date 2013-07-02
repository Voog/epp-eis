module Epp
  module Eis
    
    XML_NS_NSSET = 'http://www.nic.cz/xml/epp/nsset-1.2'
    
    XML_NSSET_SCHEMALOC = 'http://www.nic.cz/xml/epp/nsset-1.2 nsset-1.2.xsd'
    
    class NssetCheck
      attr_accessor :name, :available

      def initialize(name, available)
        @name = name
        @available = available
      end

      def available?
        @available
      end
    end

    class NssetCheckResponse

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
        @response.css('nsset|chkData nsset|cd', 'nsset' => XML_NS_NSSET).collect do |nsset|
          NssetCheck.new(
            nsset.css('nsset|id', 'nsset' => XML_NS_NSSET).text,
            nsset.css('nsset|id', 'nsset' => XML_NS_NSSET).first['avail'].to_i == 1
          )
        end
      end
    end

    class NssetCreateResponse
      def initialize(response)
        @response = Nokogiri::XML(response)
      end
      
      def code
        @response.css('epp response result').first['code'].to_i
      end
    
      def message
        @response.css('epp response result msg').text
      end
      
      def nsset_id
        @response.css('nsset|creData nsset|id', 'nsset' => XML_NS_NSSET).text
      end
      
      def nsset_create_date
        @response.css('nsset|creData nsset|crDate', 'nsset' => XML_NS_NSSET).text
      end
    end
    
    class NssetDeleteResponse
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
    
    class NssetInfoResponse
      def initialize(response)
        @response = Nokogiri::XML(response)
      end
      
      def code
        @response.css('epp response result').first['code'].to_i
      end
    
      def message
        @response.css('epp response result msg').text
      end
      
      def nsset_id
        @response.css('nsset|infData nsset|id', 'nsset' => XML_NS_NSSET).text
      end
    
      def nsset_roid
        @response.css('nsset|infData nsset|roid', 'nsset' => XML_NS_NSSET).text
      end
    
      def nsset_status
        @response.css('nsset|infData nsset|status', 'nsset' => XML_NS_NSSET).first['s']
      end
      
      def nameservers
        @response.css('nsset|infData nsset|ns', 'nsset' => XML_NS_NSSET).inject(Array.new) do |memo, nsset|
          memo << [nsset.css('nsset|name', 'nsset' => XML_NS_NSSET).text, nsset.css('nsset|addr', 'nsset' => XML_NS_NSSET).text]
        end
      end
    end
    
    class NssetUpdateResponse
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
    
    module NssetCommands
      
      # Check availability for a nsset identification.
      def check_nsset(*nssets)
        builder = build_epp_request do |xml|
          xml.command {
            xml.check {
              xml.check('xmlns:nsset' => XML_NS_NSSET, 'xsi:schemaLocation' => XML_NSSET_SCHEMALOC) {
                xml.parent.namespace = xml.parent.namespace_definitions.first
                nssets.each { |nsset| xml['nsset'].id_ nsset }
              }
            }
            xml.clTRID UUIDTools::UUID.timestamp_create.to_s
          }
        end

        NssetCheckResponse.new(send_request(builder.to_xml))
      end
      
      # Create a new nameserver object
      def create_nsset(nsset, nameservers, contact)
        builder = build_epp_request do |xml|
          xml.command {
            xml.create {
              xml.create('xmlns:nsset' => XML_NS_NSSET, 'xsi:schemaLocation' => XML_NSSET_SCHEMALOC) {
                xml.parent.namespace = xml.parent.namespace_definitions.first
                xml['nsset'].id_ nsset
                nameservers.each do |nameserver|
                  xml['nsset'].ns {
                    xml['nsset'].name nameserver[0]
                    xml['nsset'].addr nameserver[1]
                  }
                end
                xml['nsset'].tech contact
              }
            }
            xml.clTRID UUIDTools::UUID.timestamp_create.to_s
          }
        end
        
        NssetCreateResponse.new(send_request(builder.to_xml))
      end
      
      # Delete nameserver object. Can only be deleted if object does not have relations to other objects.
      def delete_nsset(nsset)
        builder = build_epp_request do |xml|
          xml.command {
            xml.delete {
              xml.delete('xmlns:nsset' => XML_NS_NSSET, 'xsi:schemaLocation' => XML_NSSET_SCHEMALOC) {
                xml.parent.namespace = xml.parent.namespace_definitions.first
                xml['nsset'].id_ nsset
              }
            }
            xml.clTRID UUIDTools::UUID.timestamp_create.to_s
          }
        end
        
        NssetDeleteResponse.new(send_request(builder.to_xml))
      end
      
      # Returns intormation about existing nameserver object.
      def info_nsset(nsset)
        builder = build_epp_request do |xml|
          xml.command {
            xml.info {
              xml.info('xmlns:nsset' => XML_NS_NSSET, 'xsi:schemaLocation' => XML_NSSET_SCHEMALOC) {
                xml.parent.namespace = xml.parent.namespace_definitions.first
                xml['nsset'].id_ nsset
              }
            }
            xml.clTRID UUIDTools::UUID.timestamp_create.to_s
          }
        end
        
        NssetInfoResponse.new(send_request(builder.to_xml))
      end
      
      def list_nssets
        list_command('listNssets')
      end
      
      # Updates nameserver object. Update has been divided into three sections. Depending on the section that is used,
      # update can add, remove and/or change data all at once.
      def update_nsset(nsset, add_nameservers, add_contact, rem_nameserver, rem_contact)
        builder = build_epp_request do |xml|
          xml.command {
            xml.update {
              xml.update('xmlns:nsset' => XML_NS_NSSET, 'xsi:schemaLocation' => XML_NSSET_SCHEMALOC) {
                xml.parent.namespace = xml.parent.namespace_definitions.first
                xml['nsset'].id_ nsset
                if add_nameservers or add_contact
                  xml['nsset'].add {
                    add_nameservers.each do |nameserver|
                      xml['nsset'].ns {
                        xml['nsset'].name nameserver[0]
                        xml['nsset'].addr nameserver[1]
                      }
                    end if add_nameservers
                    xml['nsset'].tech add_contact if add_contact
                  }
                end
                if rem_nameserver or rem_contact
                  xml['nsset'].rem {
                    xml['nsset'].name rem_nameserver
                    xml['nsset'].tech rem_contact
                  }
                end
              }
            }
            xml.clTRID UUIDTools::UUID.timestamp_create.to_s
          }
        end
        
        NssetUpdateResponse.new(send_request(builder.to_xml))
      end
    end
  end
end

Epp::Server.send(:include, Epp::Eis::NssetCommands)
