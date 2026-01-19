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
  # govwifi-usersignup is the internal service name for the user signup api
  let(:user_signup_api_url) { "http://govwifi-usersignup:3000/user-signup/sms-notification/notify" }
  let(:notify_pit_url) { "http://notify-pit:8000" }
  # Token defined in docker-compose.yml environment variables
  let(:notify_bearer_token) { "dummy-bearer-token-1234" }

  let(:source_number) { "07700900000" }
  # The API internationalises numbers before sending to Notify
  let(:internationalised_number) { "+447700900000" }

  before do
    # Reset Notify Pit to ensure a clean state before the test
    uri = URI("#{notify_pit_url}/pit/reset")
    req = Net::HTTP::Delete.new(uri)
    Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
  end

  it "successfully signs up a user via SMS and authenticates with the received credentials" do
    # 1. Send 'Go' SMS to User Signup API to trigger account creation
    signup_uri = URI(user_signup_api_url)
    signup_req = Net::HTTP::Post.new(signup_uri, 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{notify_bearer_token}")
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
    # We poll the mock service until the notification containing the credentials appears
    credentials = nil
    notifications = []

    60.times do
      sleep 0.5
      uri = URI("#{notify_pit_url}/pit/notifications")
      res = Net::HTTP.get_response(uri)
      notifications = JSON.parse(res.body)

      # Find the SMS sent to our test number
      target_notification = notifications.find do |n|
        n['phone_number'] == internationalised_number || n['phone_number'] == source_number
      end

      # Extract login details from personalisation block
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
    # We use the eapol_test tool via the GovwifiEapoltest gem
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