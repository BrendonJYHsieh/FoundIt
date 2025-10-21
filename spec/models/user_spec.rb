require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = User.new(
        email: 'test1@columbia.edu',
        uni: 'ts1235',
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
        password: 'password123',
        password_confirmation: 'password123'
      )
      
      user = User.new(uni: 'ts1237')
      expect(user).not_to be_valid
      expect(user.errors[:uni]).to include('has already been taken')
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
  end
end
