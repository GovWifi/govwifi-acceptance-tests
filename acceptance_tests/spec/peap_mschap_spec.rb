require "spec_helper"
require "govwifi_eapoltest"

describe "PEAP-MSCHAPV2" do
  let(:eapoltest) { GovwifiEapoltest.new(radius_ips: [frontend_container_ip], secret: radius_key) }
  let(:username) { "DSLPR" }
  let(:contact) { "+447766554430" }
  let(:password) { "SharpRegainDetailed" }
  let(:server_cert_path) { "/usr/src/app/certs/server_root_ca.pem" }
  let(:tls_version) { :tls1_2 }
  let(:run_eapoltest) do
    lambda {
      eapoltest.run_peap_mschapv2(server_cert_path:,
                                  username:,
                                  password:,
                                  tls_version:).first
    }
  end

  before :each do
    user_details_db[:userdetails].insert(
      {
        username: "DSLPR",
        password: "SharpRegainDetailed",
      },
    )
  end

  context "With valid username and password" do
    it "succeeds" do
      expect(run_eapoltest.call).to have_been_successful
    end
    it "logs the request" do
      expect { run_eapoltest.call }.to change(sessions_db[:sessions], :count).by 1
    end
    context "TLS 1.0" do
      let(:tls_version) { :tls1_0 }
      it "uses TLS version 1.0" do
        expect(run_eapoltest.call).to use_tls_version_1_0
      end
    end
    context "TLS 1.1" do
      let(:tls_version) { :tls1_1 }
      it "uses TLS version 1.1" do
        expect(run_eapoltest.call).to use_tls_version_1_1
      end
    end
    context "TLS 1.2" do
      let(:tls_version) { :tls1_2 }
      it "uses TLS version 1.2" do
        expect(run_eapoltest.call).to use_tls_version_1_2
      end
    end
    context "TLS 1.3" do
      let(:tls_version) { :tls1_3 }
      it "uses TLS version 1.3" do
        expect(run_eapoltest.call).to use_tls_version_1_3
      end
    end
  end

  context "with invalid password" do
    let(:password) { "invalid" }
    it "fails" do
      expect(run_eapoltest.call).to have_failed
    end
    it "logs the request" do
      expect { run_eapoltest.call }.to change(sessions_db[:sessions], :count).by 2
    end
  end
end
