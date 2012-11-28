require 'base64'

# EIS specific EPP extensions
module Epp
  module Eis
    module EisExtensions
      
      private
    
      def append_legal_document(xml, legal_document, legal_doc_type)
        xml.extension {
          xml.extdata('xmlns:eis' => 'urn:ee:eis:xml:epp:eis-1.0', 'xsi:schemaLocation' => 'urn:ee:eis:xml:epp:eis-1.0 eis-1.0.xsd') {
            xml.parent.namespace = xml.parent.namespace_definitions.first
            xml.legalDocument Base64.encode64(legal_document), 'type' => legal_doc_type
          }
        }
      end
    end
  end
end

Epp::Server.send(:include, Epp::Eis::EisExtensions)