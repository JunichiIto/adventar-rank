require 'net/http'
require 'uri'
require 'json'
require 'embiggen'

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
    adventar_info[:entries].sort!{|a, b|
      ret = a.bookmark_count <=> b.bookmark_count
      ret.zero? ? b.date <=> a.date : ret
    }.reverse!
    adventar_info
  end

  MEDIUM_URL_REGEX = /https?:\/\/medium.com\/@\w+\//
  def self.convert_medium_url(entry_url)
    return entry_url unless entry_url =~ MEDIUM_URL_REGEX
    root_url = entry_url[MEDIUM_URL_REGEX]
    entry_path = entry_url.gsub(MEDIUM_URL_REGEX, '')
    entry_id = entry_path.split('-').last.split('#').first
    "#{root_url}#{entry_id}"
  end

  def self.bookmark_url_trimmer(url)
    url.size > 255 ? url[0..254].gsub(/%\w?\z/, '') : url
  end

  private

  def fetch_adventar_info
    uri = URI.parse(json_url)
    logger.info "[INFO] Fetching #{uri}"
    json = Retryable.retryable do
      Net::HTTP.get(uri)
    end
    Hashie::Mash.new(JSON.parse(json)).tap do |info|
      info[:entries].each do |entry|
        expanded_url = safely_expand_url(entry.url)
        entry.url = self.class.convert_medium_url(expanded_url)
      end
    end
  end

  def safely_expand_url(url)
    Embiggen::URI(url).expand(redirects: 10).to_s
  rescue => e
    logger.warn "[WARN] Failed to expand URL: #{url} / #{e.message}"
    url
  end

  def fetch_bookmark_counts(entries)
    # http://api.b.st-hatena.com/entry.counts?url=http%3A%2F%2Fwww.hatena.ne.jp%2F&url=http%3A%2F%2Fb.hatena.ne.jp%2F
    urls = entries.map{|e| e.url}.map{|s| build_bookmark_search_url(s) }.join('&url=')
    hatena_url = "http://api.b.st-hatena.com/entry.counts?url=#{urls}"
    uri = URI.parse(hatena_url)
    logger.info "[INFO] Fetching #{uri}"
    json = Retryable.retryable do
      Net::HTTP.get(uri)
    end
    JSON.parse(json)
  end

  def build_bookmark_search_url(str)
    escape_url(self.class.bookmark_url_trimmer(jp_to_ascii(str)))
  end

  def jp_to_ascii(str)
    str =~ /\A[[:ascii:]]+\Z/ ? str : URI.escape(str)
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
        logger.info "[INFO] Bookmark count detected: #{entry_url} / #{count}"
      end
    else
      logger.warn "[WARN] Bookmark missing: #{entry_url}"
      nil
    end
  end

  def logger
    Rails.logger
  end
end