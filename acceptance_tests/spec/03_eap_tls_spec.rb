require "spec_helper"
require "govwifi_eapoltest"
require "json"

describe "EAP TLS" do
  let(:eapoltest) { GovwifiEapoltest.new(radius_ips: [frontend_container_ip], secret: radius_key) }
  let(:server_cert_path) { "/usr/src/app/certs/server_root_ca.pem" }
  let(:tls_version) { :tls1_2 }
  let(:client_cert_path) { "/usr/src/app/certs/client.pem" }
  let(:client_key_path) { "/usr/src/app/certs/client.key" }
  let(:client_mac)       { "f5:23:78:27:71:00" }
  let(:run_eapoltest) do
    lambda {
      eapoltest.run_eap_tls(client_cert_path:, client_key_path:, server_cert_path:, client_mac:, ).first
    }
  end

  context "Successful" do
    it "succeeds" do
      expect(run_eapoltest.call).to have_been_successful
    end
  end

  context "Unsuccessful - wrong key" do
    let(:client_cert_path) { "/usr/src/app/certs/client.pem" }
    let(:client_key_path)  { "/usr/src/app/certs/foreign_client.key" }
    let(:client_mac)       { "f5:23:78:27:71:01" }
    it "fails" do
      expect(run_eapoltest.call).to have_failed
    end
  end

  context "Unsuccessful - invalid client" do
    let(:client_cert_path) { "/usr/src/app/certs/invalid_client.pem" }
    let(:client_key_path)  { "/usr/src/app/certs/invalid_client.key" }
    let(:client_mac)       { "f5:23:78:27:71:02" }
    it "fails" do
      expect(run_eapoltest.call).to have_failed
    end
  end

  context "Unsuccessful - expired client certificate" do
    let(:client_cert_path) { "/usr/src/app/certs/expired_client.pem" }
    let(:client_key_path)  { "/usr/src/app/certs/expired_client.key" }
    let(:client_mac)       { "f5:23:78:27:71:03" }
    it "fails" do
      expect(run_eapoltest.call).to have_failed
    end
  end

  context "Unsuccessful - foreign client certificate" do
    let(:client_cert_path) { "/usr/src/app/certs/foreign_client.pem" }
    let(:client_key_path)  { "/usr/src/app/certs/foreign_client.key" }
    let(:client_mac)       { "f5:23:78:27:71:04" }
    it "fails" do
      expect(run_eapoltest.call).to have_failed
    end
  end

  context "Delayed success to flush logs" do
    let(:client_cert_path) { "/usr/src/app/certs/client.pem" }
    let(:client_key_path)  { "/usr/src/app/certs/client.key" }
    let(:client_mac)       { "f5:23:78:27:71:05" }
    it "succeeds" do
      sleep(12)
      expect(run_eapoltest.call).to have_been_successful
    end
  end

end
