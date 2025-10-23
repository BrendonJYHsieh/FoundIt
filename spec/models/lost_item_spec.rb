require 'rails_helper'

RSpec.describe LostItem, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      lost_item = build(:lost_item)
      expect(lost_item).to be_valid
    end

    it 'is invalid without item_type' do
      lost_item = build(:lost_item, item_type: nil)
      expect(lost_item).not_to be_valid
      expect(lost_item.errors[:item_type]).to include("can't be blank")
    end

    it 'is invalid with invalid item_type' do
      lost_item = build(:lost_item, item_type: 'invalid_type')
      expect(lost_item).not_to be_valid
      expect(lost_item.errors[:item_type]).to include('is not included in the list')
    end

    it 'is invalid without description' do
      lost_item = build(:lost_item, description: nil)
      expect(lost_item).not_to be_valid
      expect(lost_item.errors[:description]).to include("can't be blank")
    end

    it 'is invalid with description too short' do
      lost_item = build(:lost_item, description: 'short')
      expect(lost_item).not_to be_valid
      expect(lost_item.errors[:description]).to include('is too short (minimum is 10 characters)')
    end

    it 'is invalid with description too long' do
      lost_item = build(:lost_item, description: 'a' * 501)
      expect(lost_item).not_to be_valid
      expect(lost_item.errors[:description]).to include('is too long (maximum is 500 characters)')
    end

    it 'is invalid without location' do
      lost_item = build(:lost_item, location: nil)
      expect(lost_item).not_to be_valid
      expect(lost_item.errors[:location]).to include("can't be blank")
    end

    it 'is invalid without lost_date' do
      lost_item = build(:lost_item, lost_date: nil)
      expect(lost_item).not_to be_valid
      expect(lost_item.errors[:lost_date]).to include("can't be blank")
    end

    # Note: verification_questions validation removed for MVP
  end

  describe 'associations' do
    let(:lost_item) { create(:lost_item) }

    it 'belongs to a user' do
      expect(lost_item).to respond_to(:user)
    end

    it 'has many matches' do
      expect(lost_item).to respond_to(:matches)
    end

    it 'has many found_items through matches' do
      expect(lost_item).to respond_to(:found_items)
    end
  end

  describe 'scopes' do
    let!(:active_item) { create(:lost_item, status: 'active') }
    let!(:found_item) { create(:lost_item, :found) }
    let!(:closed_item) { create(:lost_item, :closed) }
    let!(:phone_item) { create(:lost_item, item_type: 'phone') }
    let!(:laptop_item) { create(:lost_item, :laptop) }
    let!(:recent_item) { create(:lost_item, lost_date: 1.day.ago) }
    let!(:old_item) { create(:lost_item, lost_date: 35.days.ago) }

    describe '.active' do
      it 'returns only active items' do
        expect(LostItem.active).to include(active_item)
        expect(LostItem.active).not_to include(found_item, closed_item)
      end
    end

    describe '.by_type' do
      it 'returns items of specified type' do
        expect(LostItem.by_type('phone')).to include(phone_item)
        expect(LostItem.by_type('phone')).not_to include(laptop_item)
      end
    end

    describe '.recent' do
      it 'returns items lost within 30 days' do
        expect(LostItem.recent).to include(recent_item)
        expect(LostItem.recent).not_to include(old_item)
      end
    end
  end

  describe 'methods' do
    let(:lost_item) { create(:lost_item) }

    # Note: verification_questions methods removed for MVP

    describe '#photos_array' do
      it 'returns parsed photos' do
        photos = lost_item.photos_array
        expect(photos).to be_an(Array)
      end
    end

    describe '#photos_array=' do
      it 'sets photos from array' do
        photos = ['photo1.jpg', 'photo2.jpg']
        lost_item.photos_array = photos
        expect(lost_item.photos).to eq(photos.to_json)
      end
    end

    describe '#mark_as_found!' do
      it 'updates status to found' do
        expect { lost_item.mark_as_found! }.to change { lost_item.status }.to('found')
      end

      it 'cancels pending matches' do
        match = create(:match, lost_item: lost_item, status: 'pending')
        lost_item.mark_as_found!
        expect(match.reload.status).to eq('cancelled')
      end
    end

    describe '#close!' do
      it 'updates status to closed' do
        expect { lost_item.close! }.to change { lost_item.status }.to('closed')
      end
    end
  end

  describe 'callbacks' do
    it 'sets default values on validation' do
      lost_item = LostItem.new
      lost_item.valid?
      expect(lost_item.status).to eq('active')
      expect(lost_item.photos).to eq('[]')
    end

    it 'triggers match finding after creation' do
      expect(FindMatchesJob).to receive(:perform_later)
      create(:lost_item)
    end
  end

  describe 'status transitions' do
    let(:lost_item) { create(:lost_item) }

    describe '#mark_as_found!' do
      it 'changes status from active to found' do
        expect { lost_item.mark_as_found! }.to change { lost_item.status }.from('active').to('found')
      end

      it 'cancels all pending matches' do
        match1 = create(:match, lost_item: lost_item, status: 'pending')
        match2 = create(:match, lost_item: lost_item, status: 'pending')
        
        lost_item.mark_as_found!
        
        expect(match1.reload.status).to eq('cancelled')
        expect(match2.reload.status).to eq('cancelled')
      end

      it 'does not affect approved matches' do
        approved_match = create(:match, lost_item: lost_item, status: 'approved')
        
        lost_item.mark_as_found!
        
        expect(approved_match.reload.status).to eq('approved')
      end
    end

    describe '#close!' do
      it 'changes status from active to closed' do
        expect { lost_item.close! }.to change { lost_item.status }.from('active').to('closed')
      end

      it 'does not affect match statuses' do
        match = create(:match, lost_item: lost_item, status: 'pending')
        
        lost_item.close!
        
        expect(match.reload.status).to eq('pending')
      end
    end
  end

  describe 'photo management' do
    let(:lost_item) { create(:lost_item) }

    describe '#photos_array' do
      it 'returns empty array when no photos' do
        expect(lost_item.photos_array).to eq([])
      end

      it 'returns parsed photos when photos exist' do
        lost_item.update!(photos: '["photo1.jpg", "photo2.jpg"]')
        expect(lost_item.photos_array).to eq(['photo1.jpg', 'photo2.jpg'])
      end
    end

    describe '#photos_array=' do
      it 'sets photos from array' do
        photos = ['photo1.jpg', 'photo2.jpg']
        lost_item.photos_array = photos
        expect(lost_item.photos).to eq(photos.to_json)
      end

      it 'handles empty array' do
        lost_item.photos_array = []
        expect(lost_item.photos).to eq('[]')
      end
    end
  end

  describe 'verification questions' do
    let(:lost_item) { create(:lost_item) }

    describe '#verification_questions_array' do
      it 'returns empty array when no questions' do
        lost_item.update!(verification_questions: nil)
        expect(lost_item.verification_questions_array).to eq([])
      end

      it 'returns parsed questions when questions exist' do
        questions = [{"question" => "What color?", "answer" => "Blue"}]
        lost_item.update!(verification_questions: questions.to_json)
        expect(lost_item.verification_questions_array).to eq(questions)
      end
    end

    describe '#verification_questions_array=' do
      it 'sets questions from array' do
        questions = [{"question" => "What color?", "answer" => "Blue"}]
        lost_item.verification_questions_array = questions
        expect(lost_item.verification_questions).to eq(questions.to_json)
      end
    end
  end

  describe 'scopes with complex queries' do
    let!(:phone_library) { create(:lost_item, item_type: 'phone', location: 'Butler Library', lost_date: 1.day.ago) }
    let!(:laptop_gym) { create(:lost_item, item_type: 'laptop', location: 'Dodge Fitness Center', lost_date: 2.days.ago) }
    let!(:phone_gym) { create(:lost_item, item_type: 'phone', location: 'Dodge Fitness Center', lost_date: 1.day.ago) }
    let!(:old_phone) { create(:lost_item, item_type: 'phone', location: 'Butler Library', lost_date: 35.days.ago) }

    describe 'chained scopes' do
      it 'filters by type and location' do
        results = LostItem.by_type('phone').by_location('Butler Library')
        expect(results).to include(phone_library)
        expect(results).to include(old_phone)  # old_phone is also a phone at Butler Library
        expect(results).not_to include(laptop_gym)
        expect(results).not_to include(phone_gym)
      end

      it 'filters by type and recent date' do
        results = LostItem.by_type('phone').recent
        expect(results).to include(phone_library, phone_gym)
        expect(results).not_to include(old_phone)
      end

      it 'combines all scopes' do
        results = LostItem.active.by_type('phone').by_location('Butler Library').recent
        expect(results).to include(phone_library)
        expect(results).not_to include(laptop_gym, phone_gym, old_phone)
      end
    end
  end

  describe 'associations with matches' do
    let(:lost_item) { create(:lost_item) }
    let(:found_item1) { create(:found_item) }
    let(:found_item2) { create(:found_item) }

    it 'has many matches' do
      match1 = create(:match, lost_item: lost_item, found_item: found_item1)
      match2 = create(:match, lost_item: lost_item, found_item: found_item2)
      
      expect(lost_item.matches).to include(match1, match2)
    end

    it 'has many found_items through matches' do
      create(:match, lost_item: lost_item, found_item: found_item1)
      create(:match, lost_item: lost_item, found_item: found_item2)
      
      expect(lost_item.found_items).to include(found_item1, found_item2)
    end

    it 'destroys matches when lost_item is destroyed' do
      match = create(:match, lost_item: lost_item, found_item: found_item1)
      
      expect { lost_item.destroy }.to change { Match.count }.by(-1)
    end
  end

  describe 'item type validations' do
    it 'accepts valid item types' do
      %w[phone laptop textbook id keys wallet backpack other].each do |type|
        lost_item = build(:lost_item, item_type: type)
        expect(lost_item).to be_valid
      end
    end

    it 'rejects invalid item types' do
      lost_item = build(:lost_item, item_type: 'invalid_type')
      expect(lost_item).not_to be_valid
      expect(lost_item.errors[:item_type]).to include('is not included in the list')
    end
  end

  describe 'description validations' do
    it 'accepts descriptions within length limits' do
      lost_item = build(:lost_item, description: 'A' * 10)
      expect(lost_item).to be_valid
      
      lost_item = build(:lost_item, description: 'A' * 500)
      expect(lost_item).to be_valid
    end

    it 'rejects descriptions that are too short' do
      lost_item = build(:lost_item, description: 'A' * 9)
      expect(lost_item).not_to be_valid
      expect(lost_item.errors[:description]).to include('is too short (minimum is 10 characters)')
    end

    it 'rejects descriptions that are too long' do
      lost_item = build(:lost_item, description: 'A' * 501)
      expect(lost_item).not_to be_valid
      expect(lost_item.errors[:description]).to include('is too long (maximum is 500 characters)')
    end
  end

  describe 'status validations' do
    it 'accepts valid statuses' do
      %w[active found closed].each do |status|
        lost_item = build(:lost_item, status: status)
        expect(lost_item).to be_valid
      end
    end

    it 'rejects invalid statuses' do
      lost_item = build(:lost_item, status: 'invalid_status')
      expect(lost_item).not_to be_valid
      expect(lost_item.errors[:status]).to include('is not included in the list')
    end
  end
end
