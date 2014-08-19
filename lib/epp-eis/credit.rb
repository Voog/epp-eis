module Epp
  module Eis
    
    class CreditInfoResponse
      def initialize(response)
        @response = Nokogiri::XML(response)
      end
      
      def code
        @response.css('epp response result').first['code'].to_i
      end

      def message
        @response.css('epp response result msg').text
      end
      
      def zone_credits
        @response.css('fred|resCreditInfo fred|zoneCredit', 'fred' => XML_NS_FRED).inject({}) do |memo, item|
          memo[item.css('fred|zone', 'fred' => XML_NS_FRED).text] = item.css('fred|credit', 'fred' => XML_NS_FRED).text
          memo
        end
      end
    end
    
    module CreditCommands
      
      def credit_info
        builder = build_epp_request do |xml|
          xml.extension {
            xml.extcommand('xmlns:fred' => 'http://www.nic.cz/xml/epp/fred-1.4', 'xsi:schemaLocation' => 'http://www.nic.cz/xml/epp/fred-1.4 fred-1.4.xsd') {
              xml.parent.namespace = xml.parent.namespace_definitions.first
              xml['fred'].creditInfo
              xml['fred'].clTRID UUIDTools::UUID.timestamp_create.to_s
            }
          }
        end
        
        CreditInfoResponse.new(send_request(builder.to_xml))
      end
    end
  end
end

Epp::Server.send(:include, Epp::Eis::CreditCommands)
