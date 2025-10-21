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

    it 'is invalid without verification_questions' do
      lost_item = LostItem.new(
        item_type: 'phone',
        description: 'iPhone 13 Pro with blue case',
        location: 'Butler Library',
        lost_date: Date.current,
        verification_questions: nil
      )
      # Skip the set_defaults callback for this test
      lost_item.define_singleton_method(:set_defaults) { }
      expect(lost_item).not_to be_valid
      expect(lost_item.errors[:verification_questions]).to include("can't be blank")
    end
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

    describe '#verification_questions_array' do
      it 'returns parsed verification questions' do
        questions = lost_item.verification_questions_array
        expect(questions).to be_an(Array)
        expect(questions.first).to have_key('question')
        expect(questions.first).to have_key('answer')
      end
    end

    describe '#verification_questions_array=' do
      it 'sets verification questions from array' do
        questions = [{ 'question' => 'Test?', 'answer' => 'Yes' }]
        lost_item.verification_questions_array = questions
        expect(lost_item.verification_questions).to eq(questions.to_json)
      end
    end

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
      expect(lost_item.verification_questions).to eq('[]')
      expect(lost_item.photos).to eq('[]')
    end

    it 'triggers match finding after creation' do
      expect(FindMatchesJob).to receive(:perform_later)
      create(:lost_item)
    end
  end
end
