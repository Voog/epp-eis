module Epp
  class Server
    
    # create_domain
    # delete_domain
    # info_domain
    # renew_domain
    # transfer_domain
    # update_domain
    # list_domains
    # check_domain
    
    # Request
    #
    # <?xml version="1.0" encoding="utf-8" standalone="no"?><epp xmlns="urn:ietf:params:xml:ns:epp-1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
    # <command>
    #   <check>
    #     <domain:check xmlns:domain="http://www.nic.cz/xml/epp/domain-1.4" xsi:schemaLocation="http://www.nic.cz/xml/epp/domain-1.4 domain-1.4.xsd">
    #       <domain:name>testing.ee</domain:name>
    #       <domain:name>blabla.ee</domain:name>
    #     </domain:check>
    #   </check>
    #   <clTRID>wjhl015#10-02-15at17:59:12</clTRID>
    # </command>
    # </epp>
    #
    # Response
    #
    # <?xml version="1.0" encoding="UTF-8"?>
    # <epp xmlns="urn:ietf:params:xml:ns:epp-1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd">
    # <response>
    #   <result code="1000">
    #     <msg>Command completed successfully</msg>
    #   </result>
    #   <resData>
    #     <domain:chkData xmlns:domain="http://www.nic.cz/xml/epp/domain-1.4" xsi:schemaLocation="http://www.nic.cz/xml/epp/domain-1.4 domain-1.4.xsd">
    #       <domain:cd>
    #         <domain:name avail="0">testing.ee</domain:name>
    #         <domain:reason>already registered.</domain:reason>
    #       </domain:cd>
    #       <domain:cd>
    #         <domain:name avail="1">blabla.ee</domain:name>
    #       </domain:cd>
    #     </domain:chkData>
    #   </resData>
    #   <trID>
    #     <clTRID>wjhl015#10-02-15at17:59:12</clTRID>
    #     <svTRID>ccReg-0000000485</svTRID>
    #   </trID>
    # </response>
    # </epp>
    def check_domain(domain)
      # raise SocketError, "Socket must be opened before logging in" if !@socket or @socket.closed?

      xml = new_epp_request

      xml.root << command = Node.new('command')
      command << check = Node.new('check')
      
      check << domain_check = Node.new('domain:check')
      domain_check['xmlns:domain'] = 'http://www.nic.cz/xml/epp/domain-1.4'
      domain_check['xsi:schemaLocation'] = 'http://www.nic.cz/xml/epp/domain-1.4 domain-1.4.xsd'
      domain_check << Node.new('domain:name', domain)

      command << Node.new('clTRID', UUIDTools::UUID.timestamp_create.to_s)
      
      send_request(xml.to_s)
      
      # response = Hpricot::XML(send_request(xml.to_s))
      # 
      # handle_response(response)
    end
  end
end