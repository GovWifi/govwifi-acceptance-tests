require "net/http"
require "spec_helper"

describe "GovWifi Healthcheck" do
  before do
    user_details_db[:userdetails].insert(
      {
        username: "DSLPR",
        contact: "+447766554430",
        password: "SharpRegainDetailed",
        mobile: "+447766554430",
      },
    )
  end
  let(:request) { Net::HTTP.new(frontend_container.to_s, 3000) }

  it "gets a 200 from the healthcheck" do
    response = request.get("/")
    expect(response.code).to eq("200")
  end
end
