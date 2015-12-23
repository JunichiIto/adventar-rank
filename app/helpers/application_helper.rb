module ApplicationHelper
  def page_title
    title = "#{@adventar_info.title} - " if @adventar_info.present?
    "#{title} Adventar Rank"
  end

  def twitter_tweet(url: request.original_url)
    html = <<-EOF
<a href="https://twitter.com/share" class="twitter-share-button" data-url="#{url}">Tweet</a>
<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>
    EOF
    html.html_safe
  end

  def hatena_bookmark(url: request.original_url)
    html = <<-EOF
<a href="http://b.hatena.ne.jp/entry/#{url}" class="hatena-bookmark-button" data-hatena-bookmark-title="#{page_title}" data-hatena-bookmark-layout="simple-balloon" title="このエントリーをはてなブックマークに追加"><img src="https://b.hatena.ne.jp/images/entry-button/button-only@2x.gif" alt="このエントリーをはてなブックマークに追加" width="20" height="20" style="border: none;" /></a><script type="text/javascript" src="https://b.hatena.ne.jp/js/bookmark_button.js" charset="utf-8" async="async"></script>
    EOF
    html.html_safe
  end
end
