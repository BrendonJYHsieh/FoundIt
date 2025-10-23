require 'rails_helper'

RSpec.describe "users/show.html.erb", type: :view do
  let(:user) { create(:user) }

  before do
    assign(:user, user)
    assign(:recent_lost_items, [])
    assign(:recent_found_items, [])
    assign(:recent_matches, [])
  end

  it "displays user profile information" do
    render
    expect(rendered).to include(user.display_name)
    expect(rendered).to include(user.email)
  end

  it "displays profile completion section" do
    render
    expect(rendered).to include('Profile Completion')
  end

  it "displays trust level section" do
    render
    expect(rendered).to include('New Member')
  end

  it "displays recent activity section" do
    render
    expect(rendered).to include('Recent Activity')
  end

  context "without profile photo" do
    before do
      allow(user).to receive(:profile_photo).and_return(double(attached?: false))
    end

    it "displays initials when no photo is attached" do
      render
      expect(rendered).to include(user.display_name.first)
    end
  end
end