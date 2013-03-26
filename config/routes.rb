Bitfun::Application.routes.draw do

  root :to => 'funs#index'

  resources :funs do
    resources :likes, only: [:index, :create], controller: 'funs/likes' do
      delete '' => 'funs/likes#destroy', as: :delete, on: :collection
    end
    resources :reposts, only: [:index, :create], controller: 'funs/reposts'
  end

  post 'vk/comments/:id', to: 'vk_widgets#comments', as: :vk_comments_callback

  get   'search',            to: 'funs#index',                 as: :search_tags, defaults: { search: true }
  post  'get_tags',           to: 'funs#autocomplete_tags',     as: :autocomplete_tags

  get 'feed' => 'funs#feed'

  get 'new' => 'funs#index', as: :new
  get 'hot' => 'funs#index', defaults: {sort: 'cached_votes_total'}, as: :hot
  get 'discuss' => 'funs#index', defaults: {sort: 'comments_counter'}, as: :discuss
  get 'sandbox' => 'funs#index', defaults: {sandbox: true, sort: 'created_at'}, as: :sandbox

  devise_for :users, :controllers => {:registrations => "registrations", :sessions => "sessions", :omniauth_callbacks => "users/omniauth_callbacks"}

  devise_scope :user do
    get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'
  end

  resources :users do
    resources :follows, only: [:create], controller: 'users/follows' do
      delete '' => 'users/follows#destroy', as: :delete, on: :collection
    end
    resources :avatars, only: [:create, :update], controller: 'users/avatars' do
      delete '' => 'users/avatars#destroy', as: :delete, on: :collection
    end
    member do
      get 'following' => 'users/follows#index', defaults: {type: 'following'}
      get 'followers' => 'users/follows#index', defaults: {type: 'followers'}
      get 'likes'
    end
  end


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
