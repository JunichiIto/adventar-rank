class RankingController < ApplicationController
  def new
  end

  def collect
    @adventar_info = BookmarkCollector.new(params[:url]).collect_adventar_info
    render 'new'
  end
end