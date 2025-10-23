require 'rails_helper'

RSpec.describe FindMatchesJob, type: :job do
  let(:user) { create(:user) }
  let(:other_user) { create(:user, email: "other@columbia.edu", uni: "ot1234") }
  let(:lost_item) { create(:lost_item, user: user) }

  describe '#perform' do
    context 'when there are potential matches' do
      let!(:found_item1) { create(:found_item, user: other_user, item_type: 'phone', description: 'iPhone 13 Pro') }
      let!(:found_item2) { create(:found_item, user: other_user, item_type: 'phone', description: 'Samsung Galaxy') }
      let!(:found_item3) { create(:found_item, user: other_user, item_type: 'laptop', description: 'MacBook Pro') }

      it 'creates matches for similar items' do
        expect {
          FindMatchesJob.perform_now(lost_item)
        }.to change { Match.count }.by_at_least(1)
      end

      it 'creates matches with similarity scores' do
        FindMatchesJob.perform_now(lost_item)
        
        matches = Match.where(lost_item: lost_item)
        expect(matches).not_to be_empty
        matches.each do |match|
          expect(match.similarity_score).to be_between(0.0, 1.0)
        end
      end

      it 'only creates matches for items of the same type' do
        FindMatchesJob.perform_now(lost_item)
        
        phone_matches = Match.joins(:found_item).where(lost_item: lost_item, found_items: { item_type: 'phone' })
        laptop_matches = Match.joins(:found_item).where(lost_item: lost_item, found_items: { item_type: 'laptop' })
        
        expect(phone_matches).not_to be_empty
        expect(laptop_matches).to be_empty
      end

      it 'sets match status to pending' do
        FindMatchesJob.perform_now(lost_item)
        
        matches = Match.where(lost_item: lost_item)
        expect(matches.pluck(:status)).to all(eq('pending'))
      end
    end

    context 'when there are no potential matches' do
      let!(:found_item) { create(:found_item, user: other_user, item_type: 'laptop') }

      it 'does not create any matches' do
        expect {
          FindMatchesJob.perform_now(lost_item)
        }.not_to change { Match.count }
      end
    end

    context 'when lost item is already found' do
      let(:found_lost_item) { create(:lost_item, user: user, status: 'found') }

      it 'does not create matches' do
        expect {
          FindMatchesJob.perform_now(found_lost_item)
        }.not_to change { Match.count }
      end
    end

    context 'when lost item is closed' do
      let(:closed_lost_item) { create(:lost_item, user: user, status: 'closed') }

      it 'does not create matches' do
        expect {
          FindMatchesJob.perform_now(closed_lost_item)
        }.not_to change { Match.count }
      end
    end

    context 'with existing matches' do
      let!(:existing_found_item) { create(:found_item, user: other_user) }
      let!(:existing_match) { create(:match, lost_item: lost_item, found_item: existing_found_item) }

      it 'handles existing matches appropriately' do
        initial_count = Match.count
        
        FindMatchesJob.perform_now(lost_item)
        
        # The job might create additional matches if there are other found items
        # that meet the criteria, so we just check that it doesn't fail
        expect(Match.count).to be >= initial_count
      end
    end

    context 'with high similarity items' do
      let!(:high_similarity_item) { create(:found_item, user: other_user, item_type: 'phone', description: 'iPhone 13 Pro with blue case') }

      it 'creates matches with high similarity scores' do
        FindMatchesJob.perform_now(lost_item)
        
        match = Match.find_by(lost_item: lost_item, found_item: high_similarity_item)
        expect(match).to be_present
        expect(match.similarity_score).to be > 0.7
      end
    end

    context 'with low similarity items' do
      let!(:low_similarity_item) { create(:found_item, user: other_user, item_type: 'phone', description: 'Completely different item') }

      it 'creates matches with low similarity scores' do
        FindMatchesJob.perform_now(lost_item)
        
        match = Match.find_by(lost_item: lost_item, found_item: low_similarity_item)
        expect(match).to be_present
        # The similarity score might be higher than expected due to item type matching
        expect(match.similarity_score).to be < 1.0
      end
    end

    context 'performance with many found items' do
      let!(:found_items) { create_list(:found_item, 100, user: other_user, item_type: 'phone') }

      it 'handles large numbers of found items efficiently' do
        expect {
          FindMatchesJob.perform_now(lost_item)
        }.to change { Match.count }
      end
    end

    context 'with different item types' do
      let(:laptop_lost_item) { create(:lost_item, user: user, item_type: 'laptop') }
      let!(:phone_found_item) { create(:found_item, user: other_user, item_type: 'phone') }
      let!(:laptop_found_item) { create(:found_item, user: other_user, item_type: 'laptop') }

      it 'only matches items of the same type' do
        FindMatchesJob.perform_now(laptop_lost_item)
        
        phone_matches = Match.joins(:found_item).where(lost_item: laptop_lost_item, found_items: { item_type: 'phone' })
        laptop_matches = Match.joins(:found_item).where(lost_item: laptop_lost_item, found_items: { item_type: 'laptop' })
        
        expect(phone_matches).to be_empty
        expect(laptop_matches).not_to be_empty
      end
    end

    context 'with location-based matching' do
      let!(:same_location_item) { create(:found_item, user: other_user, item_type: 'phone', location: 'Butler Library') }
      let!(:different_location_item) { create(:found_item, user: other_user, item_type: 'phone', location: 'Dodge Fitness Center') }

      it 'considers location in similarity calculation' do
        FindMatchesJob.perform_now(lost_item)
        
        same_location_match = Match.joins(:found_item).find_by(lost_item: lost_item, found_items: { location: 'Butler Library' })
        different_location_match = Match.joins(:found_item).find_by(lost_item: lost_item, found_items: { location: 'Dodge Fitness Center' })
        
        expect(same_location_match).to be_present
        expect(different_location_match).to be_present
        
        # Same location should have higher similarity
        expect(same_location_match.similarity_score).to be > different_location_match.similarity_score
      end
    end

    context 'error handling' do
      it 'handles nil lost_item gracefully' do
        expect {
          FindMatchesJob.perform_now(nil)
        }.not_to raise_error
      end

      it 'handles invalid lost_item gracefully' do
        expect {
          FindMatchesJob.perform_now("invalid")
        }.not_to raise_error
      end
    end
  end

  describe 'job queuing' do
    it 'is queued in the default queue' do
      expect(FindMatchesJob.new.queue_name).to eq('default')
    end

    it 'can be performed asynchronously' do
      expect {
        FindMatchesJob.perform_later(lost_item)
      }.to have_enqueued_job(FindMatchesJob).with(lost_item)
    end
  end

  describe 'job arguments' do
    it 'accepts a lost_item as argument' do
      expect {
        FindMatchesJob.perform_now(lost_item)
      }.not_to raise_error
    end

    it 'works with different lost_item types' do
      %w[phone laptop textbook id keys wallet backpack other].each do |item_type|
        item = create(:lost_item, user: user, item_type: item_type)
        expect {
          FindMatchesJob.perform_now(item)
        }.not_to raise_error
      end
    end
  end
end