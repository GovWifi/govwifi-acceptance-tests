require "spec_helper"
require "govwifi_eapoltest"

describe "EAP TLS" do
  let(:eapoltest) { GovwifiEapoltest.new(radius_ips: [frontend_container_ip], secret: radius_key) }
  let(:server_cert_path) { "/usr/src/app/certs/server_root_ca.pem" }
  let(:tls_version) { :tls1_2 }
  let(:client_cert_path) { "/usr/src/app/certs/client.pem" }
  let(:client_key_path) { "/usr/src/app/certs/client.key" }
  let(:run_eapoltest) do
    lambda {
      eapoltest.run_eap_tls(client_cert_path:, client_key_path:, server_cert_path:).first
    }
  end

  context "Successful" do
    it "succeeds" do
      expect(run_eapoltest.call).to have_been_successful
    end
  end
  context "Unsuccessful" do
    let(:client_cert_path) { "/usr/src/app/certs/invalid_client.pem" }
    let(:client_key_path) { "/usr/src/app/certs/invalid_client.key" }
    it "fails" do
      expect(run_eapoltest.call).to have_failed
    end
  end
end
