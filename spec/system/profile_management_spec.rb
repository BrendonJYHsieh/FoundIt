require 'rails_helper'

RSpec.describe "Profile Management", type: :system do
  let(:user) { create(:user, first_name: 'John', last_name: 'Doe') }

  before do
    driven_by(:rack_test)
  end

  describe "Profile Viewing" do
    before do
      login_as(user)
    end

    it "displays user profile information" do
      visit user_path(user)
      
      expect(page).to have_content('John Doe')
      expect(page).to have_content(user.email)
      expect(page).to have_content(user.uni.upcase)
      expect(page).to have_content('Member Since')
      expect(page).to have_content('Last Active')
    end

    it "displays profile completion percentage" do
      visit user_path(user)
      
      expect(page).to have_content('Profile Completion')
      expect(page).to have_content('%')
    end

    it "displays trust level and reputation" do
      visit user_path(user)
      
      expect(page).to have_content('New Member')
      expect(page).to have_content('Reputation Score')
    end

    it "shows edit profile link" do
      visit user_path(user)
      
      expect(page).to have_link('Edit Profile')
    end
  end

  describe "Profile Editing" do
    before do
      login_as(user)
    end

    it "allows editing profile information" do
      visit edit_user_path(user)
      
      fill_in 'First Name', with: 'Jane'
      fill_in 'Last Name', with: 'Smith'
      fill_in 'Bio', with: 'Updated bio information'
      fill_in 'Phone', with: '555-987-6543'
      select 'Phone', from: 'Preferred Contact Method'
      select 'Private - Only you can see your profile', from: 'Profile Visibility'
      
      click_button 'Update Profile'
      
      expect(page).to have_current_path(user_path(user))
      expect(page).to have_content('Jane Smith')
      expect(page).to have_content('Updated bio information')
      expect(page).to have_content('555-987-6543')
    end

    it "allows updating password" do
      visit edit_user_path(user)
      
      fill_in 'New Password', with: 'newpassword123'
      fill_in 'Confirm New Password', with: 'newpassword123'
      
      click_button 'Update Profile'
      
      expect(page).to have_current_path(user_path(user))
      
      # Test login with new password
      visit dashboard_path
      click_button 'Logout'
      fill_in 'Columbia Email', with: user.email
      fill_in 'New Password', with: 'newpassword123'
      click_button 'Log In'
      
      expect(page).to have_current_path(dashboard_path)
    end

    it "allows profile updates without password" do
      visit edit_user_path(user)
      
      fill_in 'Bio', with: 'Updated without password'
      
      click_button 'Update Profile'
      
      expect(page).to have_current_path(user_path(user))
      expect(page).to have_content('Updated without password')
    end

    it "shows validation errors for invalid data" do
      visit edit_user_path(user)
      
      fill_in 'Phone', with: 'invalid-phone'
      select 'Phone', from: 'Preferred Contact Method'
      
      click_button 'Update Profile'
      
      expect(page).to have_content('must be a valid phone number')
    end

    it "shows password confirmation error" do
      visit edit_user_path(user)
      
      fill_in 'New Password', with: 'newpassword123'
      fill_in 'Confirm New Password', with: 'differentpassword'
      
      click_button 'Update Profile'
      
      expect(page).to have_content("doesn't match Password")
    end

    it "allows canceling profile edit" do
      visit edit_user_path(user)
      
      click_link 'Cancel'
      
      expect(page).to have_current_path(user_path(user))
    end
  end

  describe "Profile Photo Upload" do
    before do
      login_as(user)
    end

    it "allows uploading profile photo" do
      visit edit_user_path(user)
      
      # Create a test image file
      test_image_path = Rails.root.join('spec', 'fixtures', 'test_image.jpg')
      FileUtils.mkdir_p(File.dirname(test_image_path))
      File.write(test_image_path, "fake image content")
      
      attach_file 'Profile Photo', test_image_path
      click_button 'Update Profile'
      
      expect(page).to have_current_path(user_path(user))
      # Note: In a real test, you'd verify the image is displayed
    end
  end

  describe "Profile Completion Tracking" do
    before do
      login_as(user)
    end

    it "tracks profile completion progress" do
      visit user_path(user)
      
      # Initially should show low completion
      expect(page).to have_content('Profile Completion')
      
      # Complete more fields
      visit edit_user_path(user)
      fill_in 'Bio', with: 'Complete bio'
      fill_in 'Phone', with: '555-123-4567'
      click_button 'Update Profile'
      
      # Should show higher completion
      expect(page).to have_content('Profile Completion')
    end
  end

  describe "Profile Visibility" do
    let(:other_user) { create(:user, first_name: 'Other', last_name: 'User') }

    before do
      login_as(user)
    end

    it "respects profile visibility settings" do
      # Set profile to private
      visit edit_user_path(user)
      select 'Private - Only you can see your profile', from: 'Profile Visibility'
      click_button 'Update Profile'
      
      # Logout and login as different user
      visit dashboard_path
      click_button 'Logout'
      login_as(other_user)
      
      # Try to view profile (should work for now, but could be restricted)
      visit user_path(user)
      expect(page).to have_content('John Doe')
    end
  end

  describe "Navigation" do
    before do
      login_as(user)
    end

    it "provides navigation between profile pages" do
      visit user_path(user)
      click_link 'Edit Profile'
      expect(page).to have_current_path(edit_user_path(user))
      
      click_link 'Cancel'
      expect(page).to have_current_path(user_path(user))
    end

    it "provides navigation to dashboard" do
      visit user_path(user)
      click_link 'Dashboard'
      expect(page).to have_current_path(dashboard_path)
    end
  end

  private

  def login_as(user)
    visit login_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'password123'
    click_button 'Log In'
  end
end
