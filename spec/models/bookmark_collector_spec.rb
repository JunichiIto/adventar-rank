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
          ["京から江戸へ（あるいは島原の乱が再び起こったら） #ruraladvent - この国では犬がコードを書いています", 3],
          ["新潟へIターンしてWEBエンジニアをしている話 - yuw27b’s blog", 3],
          ["北海道札幌市在住の地方プログラマーが年収を公開しつつ地方の給料モデルを紹介 - North-Geek", 2],
          ["岩手と栃木でエンジニアしてた所感 - seri::diary", 2],
          ["私が地方フリーランスプログラマーとして働くまで | システム屋まそお", 1],
          ["岡山駅から広島駅へ通勤する日常について - One day at a time", 1],
          ["岩手で起業してリモートで仕事しています - ganezaのブログ", 1],
          ["家族で東京からベトナムに移り住んだエンジニアの話 - The longest day in my life", 0],
          [nil, 0],
          ["すだちの国のエンジニア(未完) #ruraladvent - 鎌玉のよしなしごと", 0],
          ["福山市のITエンジニア事情 | オブジェクト思考型ライフ", 0],
          ["\n青森県三沢市で起業して考えてること | Takuya  Tachibana | note\n", 0],
          ["千葉県は房総地方にUターンして東京と行ったり来たりしてるWEBエンジニアの話 #ruraladvent [C!]", 0],
          ["和歌山でITエンジニア(地方在住ITエンジニア・アドベントカレンダー2015) - vaguely", 0]
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
      end
    end
  end

  context 'Japanese in URL' do
    it 'collects data' do
      url = 'http://www.adventar.org/calendars/853'
      collector = BookmarkCollector.new(url)
      VCR.use_cassette 'models/bookmarks_collector/collect_adventar_info_with_jp_url' do
        adventar_info = collector.collect_adventar_info
        expect(adventar_info).to be_present
      end
    end
  end
end