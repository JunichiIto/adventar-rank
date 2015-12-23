require 'net/http'
require 'uri'
require 'json'

class BookmarkCollector
  attr_reader :url
  def initialize(url)
    @url = url
  end

  def collect_adventar_info
    adventar_info = fetch_adventar_info
    bookmark_counts = fetch_bookmark_counts(adventar_info[:entries])
    adventar_info[:entries].each_with_index do |entry, i|
      entry.bookmark_count = detect_bookmark_count(bookmark_counts, entry.url)
    end
    adventar_info[:entries].sort_by!(&:bookmark_count).reverse!
    adventar_info
  end

  private

  def fetch_adventar_info
    return @adventar_info if @adventar_info

    uri = URI.parse(json_url)
    json = Net::HTTP.get(uri)
    @adventar_info = Hashie::Mash.new(JSON.parse(json))
  end

  def fetch_bookmark_counts(entries)
    # http://api.b.st-hatena.com/entry.counts?url=http%3A%2F%2Fwww.hatena.ne.jp%2F&url=http%3A%2F%2Fb.hatena.ne.jp%2F
    urls = entries.map{|e| e.url}.map{|s| escape_url(s)}.join('&url=')
    hatena_url = "http://api.b.st-hatena.com/entry.counts?url=#{urls}"
    uri = URI.parse(hatena_url)
    json = Net::HTTP.get(uri)
    JSON.parse(json)
  end

  def escape_url(str)
    str.gsub(':', '%3A').gsub('/', '%2F')
  end

  def json_url
    "#{url}.json"
  end

  def detect_bookmark_count(bookmark_counts, entry_url)
    count = bookmark_counts[entry_url]
    return count if count
    found = bookmark_counts.find do |url, _|
      ascii_url = url[/^http[[:ascii:]]+/]
      entry_url.include?(ascii_url)
    end
    if found
      found.last.tap do |count|
        puts "[INFO] Bookmark count detected: #{entry_url} / #{count}"
      end
    else
      puts "[WARN] Bookmark missing: #{entry_url}"
      nil
    end
  end
end