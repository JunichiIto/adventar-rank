class RankingController < ApplicationController
  caches_action :rank, if: ->(c){ c.params[:url].present? }, cache_path: ->(c){ c.params[:url] }, expires_in: 10.minutes

  def rank
    if params[:url].present?
      @adventar_info = BookmarkCollector.new(params[:url]).collect_adventar_info
    end
  rescue => e
    message = e.message.force_encoding("utf-8").truncate(50)
    Rails.logger.error message
    Rails.logger.error e.backtrace.join("\n")
    flash.now[:alert] = "エラーが発生しました。（#{message}）"
    render 'rank', status: :internal_server_error
  end
end