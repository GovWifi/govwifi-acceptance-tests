require 'net/http'
require 'json'
require 'uri'

NOTIFY_PIT_URL = ENV.fetch('NOTIFY_PIT_URL')

TEMPLATES = %w[
  self_signup_credentials_email
  rejected_email_address_email
  sponsor_credentials_email
  sponsor_confirmation_plural_email
  sponsor_confirmation_singular_email
  sponsor_confirmation_failed_email
  active_users_signup_survey_email
  followup_email
  credentials_expiring_notification_email
  credentials_sms
  recap_sms
  help_menu_sms
  device_help_other_sms
  device_help_android_sms
  device_help_iphone_sms
  device_help_mac_sms
  device_help_windows_sms
  device_help_blackberry_sms
  device_help_chromebook_sms
  active_users_signup_survey_sms
  followup_sms
].freeze

uri = URI("#{NOTIFY_PIT_URL}/pit/template")

puts "Running Notify Seeder..."
puts "Target: #{NOTIFY_PIT_URL}"

TEMPLATES.each do |template_name|
  type = template_name.end_with?('sms') ? 'sms' : 'email'

  req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
  req.body = {
    type: type,
    name: template_name,
    body: "Dummy body for #{template_name}"
  }.to_json

  begin
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end

    if res.is_a?(Net::HTTPSuccess)
      puts "Created template: #{template_name}"
    else
      puts "Failed to create #{template_name}: #{res.code} #{res.body}"
      exit 1
    end
  rescue StandardError => e
    puts "Error creating #{template_name}: #{e.message}"
    exit 1
  end
end

puts "Seeding complete."
