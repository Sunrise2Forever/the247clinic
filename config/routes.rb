Rails.application.routes.draw do

    get 'password_resets/new'
  
    get 'password_resets/edit'
  
    get 'sessions/new'
  
    get 'users/new'
  
    get 'users/new'
  
    root 'home#index'
  
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
      collection do
        get 'favorites'
      end
    end
    resources :doctors, only: :index do
      collection do
        get 'favorite'
      end
    end
    resources :sessions
    resources :video_sessions do
      member do
        get 'edit/feedback', to: 'video_sessions#feedback'
        get 'edit/notes', to: 'video_sessions#notes'
        patch 'finish', to: 'video_sessions#finish'
        patch 'update/feedback', to: 'video_sessions#update_feedback'
        patch 'update/notes', to: 'video_sessions#update_notes'

        resources :call_backs, only: [:new, :create]
        resources :messages, only: [:new, :create]
      end
    end
    resources :call_backs, only: [:edit, :update, :destroy, :show]
    resources :messages, only: [:show, :index, :update] do
      member do
        resources :answers, only: [:create]
      end
    end
    resources :photos, only: :create
    resources :history_video_sessions, only: [:index, :show]
    resources :clinics do
      collection do
        get 'favorite'
      end
    end
    resources :favorite_clinics, only: :create do
      collection do
        post 'remove'
      end
    end
    resources :favorite_doctors, only: :create do
      collection do
        post 'remove'
      end
    end
    resources :appointments do
      member do
        post 'cancel'
      end
    end
    resources :not_working_dates, only: [:new, :create, :destroy]

    resources :account_activations, only: [:edit]
    resources :password_resets,     only: [:new, :create, :edit, :update]
    
    get '/change_locale/:locale', to: 'settings#change_locale', as: :change_locale

    namespace :api do
      namespace :v1 do
        resources :users, only: [:create, :update] do
          collection do
            post 'sign_in' => 'sessions#create'
          end
        end
        resources :video_sessions
        resources :appointments
        resources :clinics
        resources :doctors
        resources :messages
        resources :call_backs
      end
    end


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
