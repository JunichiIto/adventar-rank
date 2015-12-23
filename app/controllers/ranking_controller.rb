class RankingController < ApplicationController
  def new
  end

  def collect
    @adventar_info = BookmarkCollector.new(params[:url]).collect_adventar_info
    render 'new'
  rescue => e
    message = e.message.force_encoding("utf-8").truncate(50)
    Rails.logger.error message
    Rails.logger.error e.backtrace.join("\n")
    flash.now[:alert] = "エラーが発生しました。（#{message}）"
    render 'new', status: :internal_server_error
  end
end