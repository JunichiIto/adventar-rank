require 'rails_helper'

describe BookmarkCollector do
  describe '#collect_adventar_info' do
    let(:expected_bookmark_count) do
      [
          ["プログラマの僕が東京ではなく田舎に住む理由 #ruraladvent - give IT a try", 154],
          ["福岡Iターン勢として、東京からの移住を検討する皆様の質問にお答えします · GitHub", 84],
          ["愛知県民ってなにしてんのって話 #ruraladvent - おふとんの中から", 11],
          ["地方在住記 - portal shit!", 10],
          ["大卒の元ニートが明石でプログラマをやっていた頃の話 #ruraladvent  - by shigemk2", 10],
          ["兵庫県の独学個人事業エンジニアの話", 7],
          ["新潟へIターンしてWEBエンジニアをしている話 - yuw27b’s blog", 3],
          ["京から江戸へ（あるいは島原の乱が再び起こったら） #ruraladvent - この国では犬がコードを書いています", 3],
          ["岩手と栃木でエンジニアしてた所感 - seri::diary", 2],
          ["北海道札幌市在住の地方プログラマーが年収を公開しつつ地方の給料モデルを紹介 - North-Geek", 2],
          ["Webエンジニアの僕が東京=>名古屋で働くことになって4年経ち思うことをつらつらと。 - masayuki5160's diary", 1],
          ["岡山駅から広島駅へ通勤する日常について - One day at a time", 1],
          ["岩手で起業してリモートで仕事しています - ganezaのブログ", 1],
          ["私が地方フリーランスプログラマーとして働くまで | システム屋まそお", 1],
          [nil, 0],
          ["\n青森県三沢市で起業して考えてること | Takuya  Tachibana | note\n", 0],
          ["すだちの国のエンジニア(未完) #ruraladvent - 鎌玉のよしなしごと", 0],
          ["千葉県は房総地方にUターンして東京と行ったり来たりしてるWEBエンジニアの話 #ruraladvent [C!]", 0],
          ["和歌山でITエンジニア(地方在住ITエンジニア・アドベントカレンダー2015) - vaguely", 0],
          ["福山市のITエンジニア事情 | オブジェクト思考型ライフ", 0],
          ["家族で東京からベトナムに移り住んだエンジニアの話 - The longest day in my life", 0]
      ]
    end

    it 'collects data' do
      url = 'http://www.adventar.org/calendars/867'
      collector = BookmarkCollector.new(url)
      VCR.use_cassette 'models/bookmarks_collector/collect_adventar_info' do
        adventar_info = collector.collect_adventar_info
        expect(adventar_info).to be_present
        bookmark_counts = adventar_info[:entries].map{|e| [e.title, e.bookmark_count]}
        expect(bookmark_counts).to eq expected_bookmark_count

        # 短縮URLが展開されていることを検証する
        shorten_url_entry = adventar_info[:entries].find{|e| e.date == '2015-12-14' }
        expect(shorten_url_entry.url).to eq 'http://nekomimi-taicho.com/?p=24969'
        # 本来は下記のようになるべきだが、パフォーマンス面で不安があるのでredirectを繰り返すのは諦める
        # expect(shorten_url_entry.url).to eq 'http://nekomimi-taicho.com/archives/24969/'
      end
    end

    context 'Medium in entries' do
      it 'collects data' do
        url = 'http://www.adventar.org/calendars/866'
        collector = BookmarkCollector.new(url)
        VCR.use_cassette 'models/bookmarks_collector/collect_adventar_info_with_medium_url' do
          adventar_info = collector.collect_adventar_info
          expect(adventar_info).to be_present
          medium_entry = adventar_info[:entries].find{|e| e.title == 'プログラマの3大美徳と子育て — Medium'}
          expect(medium_entry.bookmark_count).to eq 16
        end
      end
    end

    context 'Too long URL' do
      it 'collects data' do
        url = 'http://www.adventar.org/calendars/855'
        collector = BookmarkCollector.new(url)
        VCR.use_cassette 'models/bookmarks_collector/collect_adventar_info_with_too_long_url' do
          adventar_info = collector.collect_adventar_info
          expect(adventar_info).to be_present
          medium_entry = adventar_info[:entries].find{|e| e.title == '改善を続けるSonicGardenの中途採用におけるRailsの技術力の教育プロセスをご紹介 - Small Start'}
          expect(medium_entry.bookmark_count).to eq 27
        end
      end
    end
  end

  describe '::convert_medium_url' do
    it 'converts URL' do
      url = 'https://medium.com/@elgehelge/the-5-most-important-python-data-science-advancements-of-2015-a136482da89b#.v389x5a5s'
      expect(BookmarkCollector.convert_medium_url(url)).to eq 'https://medium.com/@elgehelge/a136482da89b'
      url = 'https://medium.com/@lestrrat/%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%9E%E3%81%AE3%E5%A4%A7%E7%BE%8E%E5%BE%B3%E3%81%A8%E5%AD%90%E8%82%B2%E3%81%A6-d180497dd759'
      expect(BookmarkCollector.convert_medium_url(url)).to eq 'https://medium.com/@lestrrat/d180497dd759'
    end
  end
end