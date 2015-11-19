Rails.application.routes.draw do

    get 'password_resets/new'
  
    get 'password_resets/edit'
  
    get 'sessions/new'
  
    get 'users/new'
  
    get 'users/new'
  
    root 'static_pages#home'
  
    get 'about' =>  'static_pages#about'
  
    get 'contact' => 'static_pages#contact'
  
    get 'help'    => 'static_pages#help'
  
    get 'signup'  => 'users#new'
    get    'login'   => 'sessions#new'
    post   'login'   => 'sessions#create'
    delete 'logout'  => 'sessions#destroy'

    post 'pusher/auth'
   
    resources :users do
      member do
        post 'reactivate'
      end
    end
    resources :sessions
    resources :video_sessions do
      member do
        get 'edit/callback', to: 'video_sessions#callback'
        get 'edit/message', to: 'video_sessions#message'
        get 'edit/feedback', to: 'video_sessions#feedback'
        get 'edit/notes', to: 'video_sessions#notes'
        patch 'finish', to: 'video_sessions#finish'
        patch 'update/callback', to: 'video_sessions#update_callback'
        patch 'update/message', to: 'video_sessions#update_message'
        patch 'update/feedback', to: 'video_sessions#update_feedback'
        patch 'update/notes', to: 'video_sessions#update_notes'

        resources :call_backs, only: [:new, :create]
      end
    end
    resources :call_backs, only: [:edit, :update, :destroy]
    resources :account_activations, only: [:edit]
    resources :password_resets,     only: [:new, :create, :edit, :update]
    
  get '/change_locale/:locale', to: 'settings#change_locale', as: :change_locale


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
