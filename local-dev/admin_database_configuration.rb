# The IP of the local-dev container. This can be different across machines. The
# current IP will be passed as an argument to this script.
#
CLIENT_LOCATION_IP_ADDRESS = ARGV[0]
puts "Configuring admin and using RADIUS server IP '#{CLIENT_LOCATION_IP_ADDRESS}' for location traffic."

if User.where(email: 'admin@example.com').present?
  puts "Set up has been run already."
  return
end

user = User.new({
  name: 'Joe Admin',
  email: 'admin@example.com',
  password: 'tagged-amount-gotcha',
  password_confirmation: 'tagged-amount-gotcha',
  is_super_admin: true
})
user.confirm
user.save

user2 = User.new({
  name: 'Tina Admin',
  email: 'admin+tina@example.com',
  password: 'tagged-amount-gotcha',
  password_confirmation: 'tagged-amount-gotcha',
  is_super_admin: true
})
user2.confirm
user2.save

org = Organisation.new({
 name: 'Civil Aviation Authority',
 service_email: 'admin+civil@example.com',
 cba_enabled: true
})
org.save

memb = org.memberships.create(user: user)
memb.confirm!
memb.save

memb = org.memberships.create(user: user2)
memb.confirm!
memb.save

mou1 = Mou.create!(name:'Joe Admin', email_address: 'admin@example.com', job_role: 'Sys Admin', organisation: org, user: user, version: Mou.latest_known_version)

loc1 = Location.create!(address: 'Upper Street, Islington', postcode: 'N1 2XF', organisation: org)

# 1970-01-01 to bypass the admin 10 day restriction to see the "view traffic" option for the site:
ips1 = Ip.create!(address: CLIENT_LOCATION_IP_ADDRESS, location: loc1, created_at: '1970-01-01')
