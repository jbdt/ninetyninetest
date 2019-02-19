Rails.application.routes.draw do
  root to: 'visitors#index'

  namespace :api do
    namespace :v1 do
      resources :company, only: [:index, :show]
      resources :time_series, only: [:index, :show]
    end
  end

  get '*path' => redirect('/')

end
