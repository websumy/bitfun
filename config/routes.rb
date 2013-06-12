Bitfun::Application.routes.draw do

  root to: 'funs#index'

  resources :funs do
    resources :likes, only: [:index, :create], controller: 'funs/likes' do
      delete '' => 'funs/likes#destroy', as: :delete, on: :collection
    end
    resources :reposts, only: [:index, :create], controller: 'funs/reposts'
  end

  post 'vk/comments/:id', to: 'vk_widgets#comments', as: :vk_comments_callback

  get   'search', to: 'funs#index', as: :search_tags, defaults: { search: true }
  post  'get_tags', to: 'funs#autocomplete_tags', as: :autocomplete_tags
  get  'get_rating', to: 'users#rating_table_block', as: :get_rating

  get 'feed' => 'funs#feed'

  get 'new' => 'funs#index', as: :new
  get 'hot' => 'funs#index', defaults: { sort: 'cached_votes_total' }, as: :hot
  get 'discuss' => 'funs#index', defaults: { sort: 'comments_counter' }, as: :discuss
  get 'sandbox' => 'funs#index', defaults: { sandbox: true, sort: 'created_at' }, as: :sandbox

  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions', omniauth_callbacks: 'users/omniauth_callbacks', passwords: 'users/passwords' }

  devise_scope :user do
    get '/users/unbind/:provider' => 'users/omniauth_callbacks#unbind_identity', as: :unbind_identity
  end

  resources :users do
    resources :follows, only: [:create], controller: 'users/follows' do
      delete '' => 'users/follows#destroy', as: :delete, on: :collection
    end
    resources :avatars, only: [:create, :update], controller: 'users/avatars' do
      delete '' => 'users/avatars#destroy', as: :delete, on: :collection
    end
    member do
      get 'following' => 'users/follows#index', defaults: { type: 'following' }
      get 'followers' => 'users/follows#index', defaults: { type: 'followers' }
      get 'likes'
    end
  end

  get '/:id.html' => 'high_voltage/pages#show', as: :static, via: :get
end
