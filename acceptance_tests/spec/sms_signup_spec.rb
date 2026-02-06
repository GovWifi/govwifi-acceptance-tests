require "spec_helper"
require "govwifi_eapoltest"
require "net/http"
require "json"
require "uri"

describe "SMS Signup and Authentication" do
  # Use helper methods from EnvHelper (defined in spec_helper.rb)
  let(:eapol_test_radius_ip) { frontend_container_ip }
  let(:radius_key) { ENV.fetch("RADIUS_KEY") }

  # Service URLs defined in docker-compose.yml
  # We use the internal container name and port 3000 (which is where the app listens)
  let(:user_signup_api_url) { "http://govwifi-usersignup:3000/user-signup/sms-notification/notify" }
  let(:notify_pit_url) { "http://notify-pit:8000" }
  # Token defined in docker-compose.yml environment variables
  let(:notify_bearer_token) { "dummy-bearer-token-1234" }

  let(:source_number) { "07700900000" }
  # The API internationalises numbers before sending to Notify
  let(:internationalised_number) { "+447700900000" }

  before do
    # 1. Reset Notify Pit to ensure a clean state
    uri = URI("#{notify_pit_url}/pit/reset")
    req = Net::HTTP::Delete.new(uri)
    Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }

    # 2. Create the 'credentials_sms' template in Notify Pit
    template_body = <<~BODY
      Your GovWifi details are:

      Username:
      ((LOGIN))
      Password:
      ((PASS))

      Your password is case-sensitive with no spaces between words.

      Go to your wifi settings, select 'GovWifi' and enter your details.

      Android and Chromebook users: reply with '1' for instructions.

      For help, reply with 'Help' or visit www.wifi.service.gov.uk/help

      By connecting, you accept our:
      - privacy notice www.wifi.service.gov.uk/privacy
      - terms and conditions www.wifi.service.gov.uk/terms
    BODY

    create_template_uri = URI("#{notify_pit_url}/pit/template")
    create_req = Net::HTTP::Post.new(create_template_uri, 'Content-Type' => 'application/json')
    create_req.body = {
      type: "sms",
      name: "credentials_sms",
      body: template_body
    }.to_json

    Net::HTTP.start(create_template_uri.hostname, create_template_uri.port) do |http|
      http.request(create_req)
    end
  end

  it "successfully signs up a user via SMS and authenticates with the received credentials" do
    # 1. Send 'Go' SMS to User Signup API to trigger account creation
    signup_uri = URI(user_signup_api_url)
    signup_req = Net::HTTP::Post.new(signup_uri)

    # We override the Host header to 'localhost' because the app (running in development mode)
    # likely rejects the container hostname 'govwifi-usersignup' for security/binding reasons.
    # This mimics the successful curl command from your host machine.
    signup_req['Host'] = 'localhost'
    signup_req['Content-Type'] = 'application/json'
    signup_req['Authorization'] = "Bearer #{notify_bearer_token}"

    signup_req.body = {
      source_number: source_number,
      destination_number: "07123456789",
      message: "Go"
    }.to_json

    signup_res = Net::HTTP.start(signup_uri.hostname, signup_uri.port) do |http|
      http.request(signup_req)
    end

    expect(signup_res.code).to eq("200")

    # 2. Retrieve the credentials from Notify Pit
    credentials = nil
    notifications = []

    30.times do
      sleep 0.5
      uri = URI("#{notify_pit_url}/pit/notifications")
      res = Net::HTTP.get_response(uri)
      notifications = JSON.parse(res.body)

      target_notification = notifications.find do |n|
        n['phone_number'] == internationalised_number || n['phone_number'] == source_number
      end

      if target_notification && target_notification['personalisation']
        p = target_notification['personalisation']
        credentials = {
          username: p['login'],
          password: p['pass']
        }
        break
      end
    end

    expect(credentials).to_not be_nil, "Could not find signup notification in Notify Pit. Found: #{notifications}"

    # 3. Authenticate against the Radius server using the retrieved credentials
    eapoltest = GovwifiEapoltest.new(radius_ips: [eapol_test_radius_ip], secret: radius_key)
    server_cert_path = "/usr/src/app/certs/server_root_ca.pem"

    results = eapoltest.run_peap_mschapv2(
      server_cert_path: server_cert_path,
      username: credentials[:username],
      password: credentials[:password],
      tls_version: :tls1_2
    )

    result = results.first
    expect(result).to have_been_successful
  end
end