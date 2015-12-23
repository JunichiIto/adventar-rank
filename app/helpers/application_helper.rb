module ApplicationHelper
  def bookmark_url(entry_url)
    "http://b.hatena.ne.jp/entry/#{entry_url.gsub(/https?:\/\//, '')}"
  end
end
