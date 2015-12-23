module ApplicationHelper
  def bookmark_url(entry_url)
    s_prefix = 's/' if entry_url =~ /\Ahttps/
    "http://b.hatena.ne.jp/entry/#{s_prefix}#{entry_url.gsub(/\Ahttps?:\/\//, '')}"
  end
end
