
shared_examples 'a success logger' do
  # needs :db
  # needs :eapol_test_command

  before do
    eapol_test_command
  end

  it 'logs the authentication' do
    expect(db[:sessions].order(:id).last).to_not be_nil
  end

  it 'logs exactly one sessions' do
    expect(db[:sessions].count).to eq(1)
  end
end

shared_examples 'set authentication context' do |configuration|
  # needs :db
  # needs :configuration
  # needs :frontend_container_ip
  # needs :radius_key

  let(:eapol_test_command) do
    `eapol_test -t5 -c ./spec/support/#{configuration} -a #{frontend_container_ip} -s #{radius_key}`
  end
  let(:result) { eapol_test_command.split("\n").last }
  let(:logged_with) { {} unless logged_with }

  before do
    db[:userdetails].insert(
      {
        username: 'DSLPR',
        contact: '+447766554430',
        password: 'SharpRegainDetailed',
        mobile: '+447766554430'
      }
    )
  end
end

shared_examples 'a valid auth' do |configuration|
  include_examples 'set authentication context', configuration

  it 'ACCEPT' do
    expect(result).to match('SUCCESS')
  end
  it_behaves_like 'a success logger'

  context 'with invalid radius secret' do
    let(:radius_key) { 'somerandomkey' }

    it 'REJECT' do
      expect(result).to eq('FAILURE')
    end
  end
end

shared_examples 'an invalid auth' do |configuration|
  include_examples 'set authentication context', configuration

  it 'REJECT' do
    expect(result).to eq('FAILURE')
  end

  context 'with invalid radius secret' do
    let(:radius_key) { 'somerandomkey' }

    it 'REJECT' do
      expect(result).to eq('FAILURE')
    end
  end
end
