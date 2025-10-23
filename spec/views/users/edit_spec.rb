require 'rails_helper'

RSpec.describe "users/edit.html.erb", type: :view do
  let(:user) { create(:user, first_name: "John", last_name: "Doe", bio: "Test bio", phone: "555-1234") }

  before do
    assign(:user, user)
  end

  it "displays edit form" do
    render
    expect(rendered).to include('Edit Profile')
    expect(rendered).to include('Update Profile')
  end

  it "displays user information in form fields" do
    render
    expect(rendered).to include('John')
    expect(rendered).to include('Doe')
    expect(rendered).to include('Test bio')
    expect(rendered).to include('555-1234')
  end

  it "displays password fields" do
    render
    expect(rendered).to include('password')
    expect(rendered).to include('password_confirmation')
  end

  it "displays profile photo upload field" do
    render
    expect(rendered).to include('profile_photo')
    expect(rendered).to include('type="file"')
  end

  it "has multipart form encoding" do
    render
    expect(rendered).to include('multipart')
  end

  it "has turbo disabled" do
    render
    expect(rendered).to include('data-turbo="false"')
  end

  context "without profile photo" do
    before do
      allow(user).to receive(:profile_photo).and_return(double(attached?: false))
    end

    it "does not display current photo section" do
      render
      expect(rendered).not_to include('Current Photo')
    end
  end
end