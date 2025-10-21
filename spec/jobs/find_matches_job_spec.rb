require 'rails_helper'

RSpec.describe FindMatchesJob, type: :job do
  describe '#perform' do
    context 'with a lost item' do
      let(:user) { create(:user) }
      let(:lost_item) { create(:lost_item, user: user) }

      it 'finds matches for lost item' do
        finder = create(:user, email: 'finder@columbia.edu')
        found_item = create(:found_item, 
          user: finder,
          item_type: lost_item.item_type,
          location: lost_item.location,
          found_date: lost_item.lost_date
        )

        expect { FindMatchesJob.perform_now(lost_item) }.to change { Match.count }.by(1)
        
        match = Match.last
        expect(match.lost_item).to eq(lost_item)
        expect(match.found_item).to eq(found_item)
        expect(match.similarity_score).to be >= 0.5
      end

      it 'does not create matches below threshold' do
        finder = create(:user, email: 'finder@columbia.edu')
        found_item = create(:found_item, 
          user: finder,
          item_type: 'laptop', # Different type
          location: 'Different Location', # Different location
          found_date: lost_item.lost_date + 10.days # Different date
        )

        expect { FindMatchesJob.perform_now(lost_item) }.not_to change { Match.count }
      end

      it 'limits matches to 5 per lost item' do
        finder = create(:user, email: 'finder@columbia.edu')
        6.times do |i|
          create(:found_item, 
            user: finder,
            item_type: lost_item.item_type,
            location: lost_item.location,
            found_date: lost_item.lost_date,
            description: "Found item number #{i} with detailed description"
          )
        end

        FindMatchesJob.perform_now(lost_item)
        expect(Match.where(lost_item: lost_item).count).to eq(5)
      end
    end

    context 'with a found item' do
      let(:user) { create(:user) }
      let(:found_item) { create(:found_item, user: user) }

      it 'finds matches for found item' do
        loser = create(:user, email: 'loser@columbia.edu')
        lost_item = create(:lost_item, 
          user: loser,
          item_type: found_item.item_type,
          location: found_item.location,
          lost_date: found_item.found_date
        )

        expect { FindMatchesJob.perform_now(found_item) }.to change { Match.count }.by(1)
        
        match = Match.last
        expect(match.lost_item).to eq(lost_item)
        expect(match.found_item).to eq(found_item)
        expect(match.similarity_score).to be >= 0.5
      end
    end
  end

  describe 'similarity calculation' do
    let(:job) { FindMatchesJob.new }
    let(:lost_item) { create(:lost_item, item_type: 'phone', location: 'Butler Library', lost_date: Date.current) }
    let(:found_item) { create(:found_item, item_type: 'phone', location: 'Butler Library', found_date: Date.current) }

    it 'calculates high similarity for exact matches' do
      similarity = job.send(:calculate_similarity, lost_item, found_item)
      expect(similarity).to be >= 0.9
    end

    it 'calculates lower similarity for different types' do
      found_item.update!(item_type: 'laptop')
      similarity = job.send(:calculate_similarity, lost_item, found_item)
      expect(similarity).to be < 0.9
    end

    it 'calculates lower similarity for different locations' do
      found_item.update!(location: 'Lerner Hall')
      similarity = job.send(:calculate_similarity, lost_item, found_item)
      expect(similarity).to be < 0.9
    end

    it 'calculates lower similarity for different dates' do
      found_item.update!(found_date: Date.current + 10.days)
      similarity = job.send(:calculate_similarity, lost_item, found_item)
      expect(similarity).to be < 0.9
    end
  end

  describe 'text similarity' do
    let(:job) { FindMatchesJob.new }

    it 'calculates similarity for similar descriptions' do
      text1 = "iPhone 13 Pro with blue case"
      text2 = "iPhone 13 Pro with blue case"
      similarity = job.send(:calculate_text_similarity, text1, text2)
      expect(similarity).to eq(1.0)
    end

    it 'calculates lower similarity for different descriptions' do
      text1 = "iPhone 13 Pro with blue case"
      text2 = "Samsung Galaxy with red case"
      similarity = job.send(:calculate_text_similarity, text1, text2)
      expect(similarity).to be < 1.0
    end
  end

  describe 'location similarity' do
    let(:job) { FindMatchesJob.new }

    it 'returns true for identical locations' do
      expect(job.send(:similar_locations?, "Butler Library", "Butler Library")).to be true
    end

    it 'returns true for locations with common words' do
      expect(job.send(:similar_locations?, "Butler Library 3rd floor", "Butler Library")).to be true
    end

    it 'returns false for completely different locations' do
      expect(job.send(:similar_locations?, "Butler Library", "Lerner Hall")).to be false
    end
  end
end
