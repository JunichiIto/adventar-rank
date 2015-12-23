require 'rails_helper'

feature 'Collect bookmarks' do
  scenario 'success' do
    visit root_url
    fill_in 'URL', with: 'http://www.adventar.org/calendars/867'
    VCR.use_cassette 'features/collect_bookmarks/success' do
      click_button '送信'
      expect(page).to have_selector 'h2', text: '地方在住ITエンジニア（元・地方在住も可） Advent Calendar 2015'
      expect(page).to have_link 'プログラマの僕が東京ではなく田舎に住む理由 #ruraladvent - give IT a try', href: 'http://blog.jnito.com/entry/2015/12/01/093509'
      expect(page).to have_link '家族で東京からベトナムに移り住んだエンジニアの話 - The longest day in my life', href: 'http://detham.tumblr.com/post/134844924754/%E5%AE%B6%E6%97%8F%E3%81%A7%E6%9D%B1%E4%BA%AC%E3%81%8B%E3%82%89%E3%83%99%E3%83%88%E3%83%8A%E3%83%A0%E3%81%AB%E7%A7%BB%E3%82%8A%E4%BD%8F%E3%82%93%E3%81%A0%E3%82%A8%E3%83%B3%E3%82%B8%E3%83%8B%E3%82%A2%E3%81%AE%E8%A9%B1'
    end
  end

  scenario 'not found URL' do
    visit root_url
    fill_in 'URL', with: 'http://www.adventar.org/calendars/999999999'

    VCR.use_cassette 'features/collect_bookmarks/not_found' do
      expect(Rails.logger).to receive(:error).twice
      click_button '送信'
      expect(page).to have_content 'エラーが発生しました。'
      expect(page).to have_http_status 500
    end
  end
end