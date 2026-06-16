require "spec_helper"
require "json"

describe "Govlogger postprocesser output" do

  context "Check log lines from post processor" do

    it "succeeds" do
      lines = []
      f = File.open("/test_log_data/govlogs.out","r")
      f.each do |line|
        STDERR.puts(line)
        STDERR.puts(JSON.parse(line))
        lines.push(JSON.parse(line))
      end

      expect(lines.length).to eq 7
    end
  end

#less-802.11","StartDate":"1781008861214904","User-Name":"test@client.org","lines":[{"Date":"1781008861215526","EAP-Type":"NAK","Stage":"authorize"},{"Date":"178100886
#1240237","EAP-Type":"TLS","Stage":"authorize"},{"Date":"1781008861240237","EAP-Type":"TLS","Stage":"post-auth","TLS-Cert-Expiration":"21230925144058Z","TLS-Cert-Seria
#l":"5ff3dbf70f1b838b8535406aec31872a6fa29a4c","TLS-Client-Cert-Expiration":"21230925144059Z","TLS-Client-Cert-Serial":"450bd904bdc30b21497f0d9710744256c6576401","TLS-
#Session-Cipher-Suite":"ECDHE-RSA-AES256-GCM-SHA384"}]}
#{"Calling-Station-Id":"F5-23-78-27-71-03","Connect-Info":"CONNECT 11Mbps 802.11b","EapSessions":2,"Framed-MTU":1400,"NAS-IP-Address":"127.0.0.1","NAS-Port-Type":"Wire
#less-802.11","StartDate":"1781008879942456","User-Name":"test@client.org","lines":[{"Date":"1781008879944823","EAP-Type":"NAK","Stage":"authorize"},{"Date":"178100887
#9982727","EAP-Type":"TLS","Stage":"authorize"},{"Date":"1781008879982727","EAP-Type":"TLS","Module-Failure-Message":["eap_tls: (TLS) OpenSSL says error 10 : certifica
#te has expired","eap_tls: (TLS) TLS - Alert write:fatal:certificate expired","eap_tls: (TLS) TLS - Server : Error in error","eap_tls: (TLS) Failed reading from OpenSS
#L: error:0A000086:SSL routines::certificate verify failed","eap_tls: (TLS) System call (I\\/O) error (-1)","eap_tls: (TLS) EAP Receive handshake failed during operati
#on","eap_tls: [eaptls process] = fail","eap: Failed continuing EAP TLS (13) session.  EAP sub-module failed"],"Stage":"post-auth","TLS-Cert-Expiration":"2123092514405
#8Z","TLS-Cert-Serial":"5ff3dbf70f1b838b8535406aec31872a6fa29a4c","TLS-Client-Cert-Expiration":"260519111431Z","TLS-Client-Cert-Serial":"706e5f0a642539b8270a29e6d434c2
#eb79210546"}]}
#{"Calling-Station-Id":"F5-23-78-27-71-02","Connect-Info":"CONNECT 11Mbps 802.11b","EapSessions":2,"Framed-MTU":1400,"NAS-IP-Address":"127.0.0.1","NAS-Port-Type":"Wire
#less-802.11","StartDate":"1781008870698268","User-Name":"test@client.org","lines":[{"Date":"1781008870699347","EAP-Type":"NAK","Stage":"authorize"}]}
#{"Calling-Station-Id":"F5-23-78-27-71-04","Connect-Info":"CONNECT 11Mbps 802.11b","EapSessions":2,"Framed-MTU":1400,"NAS-IP-Address":"127.0.0.1","NAS-Port-Type":"Wire
#less-802.11","StartDate":"1781008881254052","User-Name":"test@client.org","lines":[{"Date":"1781008881256599","EAP-Type":"NAK","Stage":"authorize"},{"Date":"178100888
#1289205","EAP-Type":"TLS","Stage":"authorize"},{"Date":"1781008881289205","EAP-Type":"TLS","Module-Failure-Message":["eap_tls: (TLS) OpenSSL says error 20 : unable to
# get local issuer certificate","eap_tls: (TLS) TLS - Alert write:fatal:unknown CA","eap_tls: (TLS) TLS - Server : Error in error","eap_tls: (TLS) Failed reading from 
#OpenSSL: error:0A000086:SSL routines::certificate verify failed","eap_tls: (TLS) System call (I\\/O) error (-1)","eap_tls: (TLS) EAP Receive handshake failed during o
#peration","eap_tls: [eaptls process] = fail","eap: Failed continuing EAP TLS (13) session.  EAP sub-module failed"],"Stage":"post-auth","TLS-Client-Cert-CRL-Distribut
#ion-Points":"http:\\/\\/e8.c.lencr.org\\/121.crl","TLS-Client-Cert-Expiration":"260723120339Z","TLS-Client-Cert-Serial":"0628c7179407ddd0c8d8624618d085db1a78","TLS-Cl
#ient-Cert-Subject-Alt-Name-Dns":"unclealbert.bigmight.com"}]}
#{"Calling-Station-Id":"F5-23-78-27-71-05","Connect-Info":"CONNECT 11Mbps 802.11b","EapSessions":2,"Framed-MTU":1400,"NAS-IP-Address":"127.0.0.1","NAS-Port-Type":"Wire
#less-802.11","StartDate":"1781008882466254","User-Name":"test@client.org","lines":[{"Date":"1781008882467326","EAP-Type":"NAK","Stage":"authorize"},{"Date":"178100888
#2497037","EAP-Type":"TLS","Stage":"authorize"},{"Date":"1781008882497037","EAP-Type":"TLS","Stage":"post-auth","TLS-Cert-Expiration":"21230925144058Z","TLS-Cert-Seria
#l":"5ff3dbf70f1b838b8535406aec31872a6fa29a4c","TLS-Client-Cert-Expiration":"21230925144059Z","TLS-Client-Cert-Serial":"450bd904bdc30b21497f0d9710744256c6576401","TLS-
#Session-Cipher-Suite":"ECDHE-RSA-AES256-GCM-SHA384"}]}
#{"Calling-Station-Id":null,"Connect-Info":null,"EapSessions":null,"Framed-MTU":null,"NAS-IP-Address":null,"NAS-Port-Type":null,"StartDate":"1781008890481294","User-Na
#me":null}
 
end
