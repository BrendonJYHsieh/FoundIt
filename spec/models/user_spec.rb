require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = User.new(
        email: 'test1@columbia.edu',
        uni: 'ts1235',
        first_name: 'John',
        last_name: 'Doe',
        password: 'password123',
        password_confirmation: 'password123'
      )
      expect(user).to be_valid
    end

    it 'is invalid without an email' do
      user = User.new(email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'is invalid with non-Columbia email' do
      user = User.new(email: 'test@gmail.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
    end

    it 'is invalid without a UNI' do
      user = User.new(uni: nil)
      expect(user).not_to be_valid
      expect(user.errors[:uni]).to include("can't be blank")
    end

    it 'is invalid with invalid UNI format' do
      user = User.new(uni: 'invalid123')
      expect(user).not_to be_valid
      expect(user.errors[:uni]).to include('is invalid')
    end

    it 'is invalid with duplicate email' do
      User.create!(
        email: 'test2@columbia.edu',
        uni: 'ts1236',
        first_name: 'Jane',
        last_name: 'Doe',
        password: 'password123',
        password_confirmation: 'password123'
      )
      
      user = User.new(email: 'test2@columbia.edu')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('has already been taken')
    end

    it 'is invalid with duplicate UNI' do
      User.create!(
        email: 'test3@columbia.edu',
        uni: 'ts1237',
        first_name: 'Jane',
        last_name: 'Doe',
        password: 'password123',
        password_confirmation: 'password123'
      )
      
      user = User.new(uni: 'ts1237')
      expect(user).not_to be_valid
      expect(user.errors[:uni]).to include('has already been taken')
    end

    # Profile field validations
    it 'is invalid without first_name' do
      user = User.new(first_name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:first_name]).to include("can't be blank")
    end

    it 'is invalid without last_name' do
      user = User.new(last_name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:last_name]).to include("can't be blank")
    end

    it 'is invalid with too short first_name' do
      user = User.new(first_name: 'A')
      expect(user).not_to be_valid
      expect(user.errors[:first_name]).to include('is too short (minimum is 2 characters)')
    end

    it 'is invalid with too long first_name' do
      user = User.new(first_name: 'A' * 51)
      expect(user).not_to be_valid
      expect(user.errors[:first_name]).to include('is too long (maximum is 50 characters)')
    end

    it 'is invalid with invalid phone format' do
      user = User.new(phone: 'invalid-phone')
      expect(user).not_to be_valid
      expect(user.errors[:phone]).to include('must be a valid phone number')
    end

    it 'is valid with valid phone format' do
      user = User.new(phone: '555-123-4567')
      user.valid?
      expect(user.errors[:phone]).to be_empty
    end

    it 'is valid with blank phone' do
      user = User.new(phone: '')
      user.valid?
      expect(user.errors[:phone]).to be_empty
    end

    it 'is invalid with invalid contact_preference' do
      user = User.new(contact_preference: 'invalid')
      expect(user).not_to be_valid
      expect(user.errors[:contact_preference]).to include('must be either \'email\' or \'phone\'')
    end

    it 'is valid with email contact_preference' do
      user = User.new(contact_preference: 'email')
      user.valid?
      expect(user.errors[:contact_preference]).to be_empty
    end

    it 'is valid with phone contact_preference' do
      user = User.new(contact_preference: 'phone')
      user.valid?
      expect(user.errors[:contact_preference]).to be_empty
    end

    it 'is invalid with invalid profile_visibility' do
      user = User.new(profile_visibility: 'invalid')
      expect(user).not_to be_valid
      expect(user.errors[:profile_visibility]).to include('must be either \'public\' or \'private\'')
    end

    it 'is valid with public profile_visibility' do
      user = User.new(profile_visibility: 'public')
      user.valid?
      expect(user.errors[:profile_visibility]).to be_empty
    end

    it 'is valid with private profile_visibility' do
      user = User.new(profile_visibility: 'private')
      user.valid?
      expect(user.errors[:profile_visibility]).to be_empty
    end
  end

  describe 'associations' do
    let(:user) { create(:user) }

    it 'has many lost items' do
      expect(user).to respond_to(:lost_items)
    end

    it 'has many found items' do
      expect(user).to respond_to(:found_items)
    end

    it 'destroys associated lost items when user is destroyed' do
      lost_item = user.lost_items.create!(
        item_type: 'phone',
        description: 'Test phone',
        location: 'Butler Library',
        lost_date: 1.day.ago,
        verification_questions: '[]'
      )
      
      expect { user.destroy }.to change { LostItem.count }.by(-1)
    end

    it 'destroys associated found items when user is destroyed' do
      found_item = user.found_items.create!(
        item_type: 'phone',
        description: 'Test phone',
        location: 'Butler Library',
        found_date: 1.day.ago
      )
      
      expect { user.destroy }.to change { FoundItem.count }.by(-1)
    end
  end

  describe 'scopes' do
    let!(:verified_user) { create(:user, verified: true) }
    let!(:unverified_user) { create(:user, :unverified) }

    it 'returns only verified users' do
      expect(User.verified).to include(verified_user)
      expect(User.verified).not_to include(unverified_user)
    end
  end

  describe 'methods' do
    let(:user) { create(:user) }

    describe '#columbia_email?' do
      it 'returns true for Columbia email' do
        user.email = 'test@columbia.edu'
        expect(user.columbia_email?).to be true
      end

      it 'returns false for non-Columbia email' do
        user.email = 'test@gmail.com'
        expect(user.columbia_email?).to be false
      end
    end

    describe '#increment_reputation' do
      it 'increases reputation score by default amount' do
        expect { user.increment_reputation }.to change { user.reputation_score }.by(1)
      end

      it 'increases reputation score by specified amount' do
        expect { user.increment_reputation(5) }.to change { user.reputation_score }.by(5)
      end
    end

    describe '#good_samaritan?' do
      it 'returns true when reputation score >= 10' do
        user.update!(reputation_score: 10)
        expect(user.good_samaritan?).to be true
      end

      it 'returns false when reputation score < 10' do
        user.update!(reputation_score: 9)
        expect(user.good_samaritan?).to be false
      end
    end

    # Profile methods
    describe '#full_name' do
      it 'returns first and last name combined' do
        user.update!(first_name: 'John', last_name: 'Doe')
        expect(user.full_name).to eq('John Doe')
      end

      it 'handles missing names gracefully' do
        user.update!(first_name: 'John', last_name: 'Do')
        expect(user.full_name).to eq('John Do')
      end
    end

    describe '#display_name' do
      it 'returns full name when available' do
        user.update!(first_name: 'John', last_name: 'Doe')
        expect(user.display_name).to eq('John Doe')
      end

      it 'returns email prefix when no name' do
        user.update!(first_name: 'Jo', last_name: 'Do', email: 'john.doe@columbia.edu')
        expect(user.display_name).to eq('Jo Do')
      end
    end

    describe '#profile_complete?' do
      it 'returns true when all required fields are present' do
        user.update!(first_name: 'John', last_name: 'Doe', bio: 'Test bio')
        expect(user.profile_complete?).to be true
      end

      it 'returns false when missing required fields' do
        user.update!(first_name: 'John', last_name: 'Doe', bio: '')
        expect(user.profile_complete?).to be false
      end
    end

    describe '#profile_completion_percentage' do
      it 'calculates completion percentage correctly' do
        user.update!(first_name: 'John', last_name: 'Doe', bio: 'Test bio', phone: '555-1234')
        expect(user.profile_completion_percentage).to eq(80) # 4/5 fields = 80%
      end

      it 'includes photo bonus in calculation' do
        user.update!(first_name: 'John', last_name: 'Doe', bio: 'Test bio', phone: '555-1234')
        # Mock profile_photo.attached? to return true
        allow(user).to receive(:profile_photo).and_return(double(attached?: true))
        expect(user.profile_completion_percentage).to eq(100) # 5/5 fields = 100%
      end
    end

    describe '#total_items_posted' do
      it 'returns sum of lost and found items' do
        user.lost_items.create!(item_type: 'phone', description: 'Test description', location: 'Test', lost_date: 1.day.ago, verification_questions: '[]')
        user.found_items.create!(item_type: 'phone', description: 'Test description', location: 'Test', found_date: 1.day.ago)
        expect(user.total_items_posted).to eq(2)
      end
    end

    describe '#successful_matches' do
      it 'returns count of approved matches' do
        lost_item = user.lost_items.create!(item_type: 'phone', description: 'Test description', location: 'Test', lost_date: 1.day.ago, verification_questions: '[]')
        found_item = user.found_items.create!(item_type: 'phone', description: 'Test description', location: 'Test', found_date: 1.day.ago)
        Match.create!(lost_item: lost_item, found_item: found_item, similarity_score: 0.8, status: 'approved')
        # Since user is both loser and finder, it counts as 2 matches
        expect(user.successful_matches).to eq(2)
      end
    end

    describe '#items_returned' do
      it 'returns count of found lost items' do
        user.lost_items.create!(item_type: 'phone', description: 'Test description', location: 'Test', lost_date: 1.day.ago, verification_questions: '[]', status: 'found')
        expect(user.items_returned).to eq(1)
      end
    end

    describe '#member_since' do
      it 'returns formatted creation date' do
        user.update!(created_at: Date.new(2023, 1, 15))
        expect(user.member_since).to eq('January 2023')
      end
    end

    describe '#last_active_display' do
      it 'returns "Never" when last_active_at is nil' do
        user.update_column(:last_active_at, nil)
        expect(user.last_active_display).to eq('Never')
      end

      it 'returns "Active now" for recent activity' do
        user.update!(last_active_at: 30.minutes.ago)
        expect(user.last_active_display).to eq('Active now')
      end

      it 'returns hours ago for recent activity' do
        user.update!(last_active_at: 2.hours.ago)
        expect(user.last_active_display).to eq('2 hours ago')
      end
    end

    describe '#trust_level' do
      it 'returns "New Member" for low reputation' do
        user.update!(reputation_score: 2)
        expect(user.trust_level).to eq('New Member')
      end

      it 'returns "Trusted Member" for medium reputation' do
        user.update!(reputation_score: 7)
        expect(user.trust_level).to eq('Trusted Member')
      end

      it 'returns "Good Samaritan" for high reputation' do
        user.update!(reputation_score: 15)
        expect(user.trust_level).to eq('Good Samaritan')
      end

      it 'returns "Community Leader" for very high reputation' do
        user.update!(reputation_score: 25)
        expect(user.trust_level).to eq('Community Leader')
      end
    end

    describe '#trust_level_color' do
      it 'returns appropriate color for each trust level' do
        user.update!(reputation_score: 2)
        expect(user.trust_level_color).to eq('text-gray-500')
        
        user.update!(reputation_score: 7)
        expect(user.trust_level_color).to eq('text-blue-500')
        
        user.update!(reputation_score: 15)
        expect(user.trust_level_color).to eq('text-green-500')
        
        user.update!(reputation_score: 25)
        expect(user.trust_level_color).to eq('text-purple-500')
      end
    end

    describe 'password validation' do
      it 'requires password for new records' do
        user = User.new(email: 'test@columbia.edu', uni: 'ts1234', first_name: 'John', last_name: 'Doe')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("can't be blank")
      end

      it 'does not require password for existing records when blank' do
        user = create(:user)
        user.password = ''
        user.password_confirmation = ''
        expect(user).to be_valid
      end

      it 'requires password confirmation when password is provided' do
        user = create(:user)
        user.password = 'newpassword'
        user.password_confirmation = 'different'
        expect(user).not_to be_valid
        expect(user.errors[:password_confirmation]).to include("doesn't match Password")
      end
    end
  end

  describe 'defaults' do
    it 'sets verified to false by default' do
      user = User.new
      user.valid?
      expect(user.verified).to be false
    end

    it 'sets reputation_score to 0 by default' do
      user = User.new
      user.valid?
      expect(user.reputation_score).to eq(0)
    end

    it 'sets contact_preference to email by default' do
      user = User.new
      user.valid?
      expect(user.contact_preference).to eq('email')
    end

    it 'sets profile_visibility to public by default' do
      user = User.new
      user.valid?
      expect(user.profile_visibility).to eq('public')
    end

    it 'sets last_active_at to current time by default' do
      user = User.new
      user.valid?
      expect(user.last_active_at).to be_within(1.minute).of(Time.current)
    end
  end

  describe 'Active Storage' do
    let(:user) { create(:user) }

    it 'has one attached profile photo' do
      expect(user).to respond_to(:profile_photo)
    end

    it 'can attach a profile photo' do
      file = fixture_file_upload('test_image.jpg', 'image/jpeg')
      user.profile_photo.attach(file)
      expect(user.profile_photo).to be_attached
    end

    it 'can detach a profile photo' do
      file = fixture_file_upload('test_image.jpg', 'image/jpeg')
      user.profile_photo.attach(file)
      user.profile_photo.purge
      expect(user.profile_photo).not_to be_attached
    end
  end
end
