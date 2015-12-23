require 'rails_helper'

describe BookmarkCollector do
  describe '#collect_adventar_info' do
    it 'collects data' do
      url = 'http://www.adventar.org/calendars/867'
      collector = BookmarkCollector.new(url)
      VCR.use_cassette 'models/bookmarks_collector/collect_adventar_info' do
        adventar_info = collector.collect_adventar_info
        expect(adventar_info).to be_present
      end
    end
  end
end