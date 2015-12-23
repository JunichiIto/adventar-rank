Rails.application.routes.draw do
  root to: 'ranking#new'
  get '/ranking', to: 'ranking#collect'
end
