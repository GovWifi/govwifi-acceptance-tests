require 'sinatra'
require 'json'
require 'net/http'
require 'socket'
require 'uri'
require 'open3'

set :bind, '0.0.0.0'
set :port, 4567

# Service configuration
SERVICES = {
  'Frontend (Radius)' => { host: 'govwifi-frontend', port: 3000 },
  'Authentication API' => { host: 'govwifi-authentication-api', port: 8080 },
  'Logging API' => { host: 'govwifi-logging-api', port: 8080 },
  'User Signup API' => { host: 'govwifi-usersignup', port: 3000 },
  'Admin App' => { host: 'govwifi-admin', port: 3000 },
  'Notify Pit' => { host: 'notify-pit', port: 8000 },
  'Fake S3' => { host: 'govwifi-fake-s3', port: 4566 }
}

helpers do
  def check_port(host, port)
    Timeout.timeout(1) do
      TCPSocket.new(host, port).close
      true
    end
  rescue StandardError
    false
  end
end

get '/' do
  erb :index
end

get '/api/services' do
  content_type :json
  statuses = SERVICES.map do |name, config|
    {
      name: name,
      host: config[:host],
      port: config[:port],
      status: check_port(config[:host], config[:port]) ? 'online' : 'offline'
    }
  end
  statuses.to_json
end

post '/api/send-go' do
  content_type :json
  request_payload = JSON.parse(request.body.read) rescue {}

  phone_number = request_payload['phoneNumber'] || '07700900000'
  api_url = request_payload['apiUrl'] || "http://govwifi-usersignup:3000/user-signup/sms-notification/notify"
  bearer_token = request_payload['bearerToken'] || 'dummy-bearer-token-1234'

  uri = URI(api_url)
  http = Net::HTTP.new(uri.host, uri.port)
  req = Net::HTTP::Post.new(uri.path, {
    'Content-Type' => 'application/json',
    'HOST' => 'localhost',
    'Authorization' => "Bearer #{bearer_token}"
  })

  req.body = {
    source_number: phone_number,
    destination_number: '07700900001', # Verify specific destination if needed
    message: 'GO'
  }.to_json

  begin
    res = http.request(req)
    if res.code.to_i >= 200 && res.code.to_i < 300
      { status: 'success', message: 'GO message sent successfully!' }.to_json
    else
      status 500
      { status: 'error', message: "Failed to send GO message. HTTP Code: #{res.code} - #{res.body}" }.to_json
    end
  rescue StandardError => e
    status 500
    { status: 'error', message: "Connection failed: #{e.message}" }.to_json
  end
end

post '/api/run-test' do
  content_type :json
  request_payload = JSON.parse(request.body.read) rescue {}

  username = request_payload['username'] || 'DSLPR'
  password = request_payload['password'] || 'SharpRegainDetailed'

  # Create a temporary config file
  config_content = <<~CONF
    network={
            ssid="GovWifi"
            key_mgmt=WPA-EAP
            eap=PEAP
            identity="#{username}"
            anonymous_identity="anonymous"
            password="#{password}"
            phase2="autheap=MSCHAPV2"
    }
  CONF

  config_file = "/tmp/eapol_test_#{Time.now.to_i}.conf"
  File.write(config_file, config_content)

  # Ensure env vars
  radius_ip = Resolv.getaddress('govwifi-frontend') rescue 'govwifi-frontend'

  cmd = "eapol_test -a #{radius_ip} -c #{config_file} -s testingradiussecret"

  stdout, stderr, status = Open3.capture3(cmd)

  # Cleanup
  File.delete(config_file) if File.exist?(config_file)

  # Determine Result
  result_status = "UNKNOWN"
  if stdout.include?("Access-Accept")
    result_status = "ACCEPTED"
  elsif stdout.include?("Access-Reject")
    result_status = "REJECTED"
  end

  {
    status: result_status,
    command: cmd,
    stdout: stdout,
    stderr: stderr,
    exit_code: status.exitstatus
  }.to_json
end
