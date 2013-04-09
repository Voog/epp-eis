module Epp
  module Eis
    
    class GetResultsResponse
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
        @response.css('fred|resultsList fred|item', 'fred' => XML_NS_FRED).collect{ |item| item.text }
      end
    end
    
    class HelloResponse
      def initialize(response)
        @response = Nokogiri::XML(response)
      end
      
      def version
        @response.css('epp greeting svcMenu version').text
      end
    end
    
    module SessionCommands
      
      # Opens session to EPP server, and yields the block given. Wraps login and
      # logout request around it.
      def command_session(&block)
        open_connection

        @logged_in = true if login

        begin
          yield
        ensure
          @logged_in = false if @logged_in && logout
          close_connection
        end
      end
      
      def list_command(command_name)
        response = nil
        
        command_session do
          builder = build_epp_request do |xml|
            xml.extension {
              xml.extcommand('xmlns:fred' => 'http://www.nic.cz/xml/epp/fred-1.4', 'xsi:schemaLocation' => 'http://www.nic.cz/xml/epp/fred-1.4 fred-1.4.xsd') {
                xml.parent.namespace = xml.parent.namespace_definitions.first
                xml.send(command_name)
                xml.clTRID UUIDTools::UUID.timestamp_create.to_s
              }
            }
          end
          
          response = send_request(builder.to_xml)
          
          builder = build_epp_request do |xml|
            xml.extension {
              xml.extcommand('xmlns:fred' => 'http://www.nic.cz/xml/epp/fred-1.4', 'xsi:schemaLocation' => 'http://www.nic.cz/xml/epp/fred-1.4 fred-1.4.xsd') {
                xml.parent.namespace = xml.parent.namespace_definitions.first
                xml.getResults
                xml.clTRID UUIDTools::UUID.timestamp_create.to_s
              }
            }
          end
          
          response = GetResultsResponse.new(send_request(builder.to_xml))
        end
        
        return response
      end
      
      def hello
        builder = build_epp_request do |xml|
          xml.hello
        end
        
        HelloResponse.new(send_request(builder.to_xml))
      end
    end
  end
end

Epp::Server.send(:include, Epp::Eis::SessionCommands)
