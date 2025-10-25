require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:uni) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_uniqueness_of(:uni) }
    it { should validate_length_of(:first_name).is_at_least(2).is_at_most(50) }
    it { should validate_length_of(:last_name).is_at_least(2).is_at_most(50) }
    it { should validate_numericality_of(:reputation_score).is_greater_than_or_equal_to(0) }

    it 'validates Columbia email format' do
      user = build(:user, email: 'test@gmail.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
    end

    it 'validates UNI format' do
      user = build(:user, uni: 'invalid123')
      expect(user).not_to be_valid
      expect(user.errors[:uni]).to include('is invalid')
    end

    it 'validates phone format when present' do
      user = build(:user, phone: 'invalid-phone')
      expect(user).not_to be_valid
      expect(user.errors[:phone]).to include('must be a valid phone number')
    end

    it 'allows blank phone' do
      user = build(:user, phone: '')
      expect(user).to be_valid
    end
  end

  describe 'associations' do
    it { should have_many(:lost_items).dependent(:destroy) }
    it { should have_many(:found_items).dependent(:destroy) }
    # Match associations skipped - functionality not implemented yet
    # it { should have_many(:matches_as_loser).through(:lost_items).source(:matches) }
    # it { should have_many(:matches_as_finder).through(:found_items).source(:matches) }
    it { should have_one_attached(:profile_photo) }
  end

  describe 'scopes' do
    let!(:verified_user) { create(:user, verified: true) }
    let!(:unverified_user) { create(:user, verified: false) }

    it 'returns only verified users' do
      expect(User.verified).to include(verified_user)
      expect(User.verified).not_to include(unverified_user)
    end
  end

  describe 'methods' do
    let(:user) { create(:user) }

    describe '#columbia_email?' do
      it 'returns true for Columbia email' do
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

    describe '#full_name' do
      it 'returns first and last name combined' do
        expect(user.full_name).to eq("#{user.first_name} #{user.last_name}")
      end

    it 'handles missing names gracefully' do
      user.first_name = nil
      user.last_name = nil
      user.save(validate: false)
      expect(user.full_name).to eq('')
    end
    end

    describe '#display_name' do
      it 'returns full name when available' do
        expect(user.display_name).to eq(user.full_name)
      end

    it 'returns email prefix when no name' do
      user.first_name = nil
      user.last_name = nil
      user.save(validate: false)
      expect(user.display_name).to eq(user.email.split('@').first.titleize)
    end
    end

    describe '#profile_complete?' do
      it 'returns true when all required fields are present' do
        user.update!(bio: 'Test bio')
        expect(user.profile_complete?).to be true
      end

      it 'returns false when missing required fields' do
        expect(user.profile_complete?).to be false
      end
    end

    describe '#profile_completion_percentage' do
      it 'calculates completion percentage correctly' do
        user.update!(bio: 'Test bio')
        expect(user.profile_completion_percentage).to eq(60)
      end

      it 'includes photo bonus in calculation' do
        user.update!(bio: 'Test bio')
        user.profile_photo.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'test_image.jpg')), filename: 'test.jpg')
        expect(user.profile_completion_percentage).to be > 60
      end
    end

    describe '#total_items_posted' do
      it 'returns sum of lost and found items' do
        create(:lost_item, user: user)
        create(:found_item, user: user)
        expect(user.total_items_posted).to eq(2)
      end
    end

    describe '#successful_matches' do
      it 'returns count of approved matches' do
        # Skip match-related tests for now
        skip "Match functionality not implemented yet"
      end
    end

    describe '#items_returned' do
      it 'returns count of found lost items' do
        create(:lost_item, user: user, status: 'found')
        expect(user.items_returned).to eq(1)
      end
    end

    describe '#member_since' do
      it 'returns formatted creation date' do
        expect(user.member_since).to eq(user.created_at.strftime('%B %Y'))
      end
    end

    describe '#last_active_display' do
    it 'returns "Never" when last_active_at is nil' do
      user_without_last_active = create(:user, last_active_at: nil)
      expect(user_without_last_active.last_active_display).to eq('Never')
    end

      it 'returns "Active now" for recent activity' do
        user.update!(last_active_at: Time.current)
        expect(user.last_active_display).to eq('Active now')
      end

      it 'returns hours ago for recent activity' do
        user.update!(last_active_at: 2.hours.ago)
        expect(user.last_active_display).to include('hours ago')
      end
    end

    describe '#trust_level' do
      it 'returns "New Member" for low reputation' do
        user.update!(reputation_score: 2)
        expect(user.trust_level).to eq('New Member')
      end

      it 'returns "Trusted Member" for medium reputation' do
        user.update!(reputation_score: 8)
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
        
        user.update!(reputation_score: 8)
        expect(user.trust_level_color).to eq('text-blue-500')
        
        user.update!(reputation_score: 15)
        expect(user.trust_level_color).to eq('text-green-500')
        
        user.update!(reputation_score: 25)
        expect(user.trust_level_color).to eq('text-purple-500')
      end
    end
  end

  describe 'password validation' do
    it 'does not require password for existing records when blank' do
      user = create(:user)
      user.password = ''
      user.password_confirmation = ''
      expect(user).to be_valid
    end

    it 'requires password confirmation when password is provided' do
      user = build(:user, password: 'newpassword', password_confirmation: '')
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end
  end

  describe 'Active Storage' do
    let(:user) { create(:user) }

    it 'has one attached profile photo' do
      expect(user).to respond_to(:profile_photo)
    end

    it 'can attach a profile photo' do
      user.profile_photo.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'test_image.jpg')), filename: 'test.jpg')
      expect(user.profile_photo).to be_attached
    end

    it 'can detach a profile photo' do
      user.profile_photo.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'test_image.jpg')), filename: 'test.jpg')
      user.profile_photo.purge
      expect(user.profile_photo).not_to be_attached
    end
  end
end
