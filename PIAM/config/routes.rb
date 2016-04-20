PIAM::Application.routes.draw do

  get "receptor_types/new"

  get "receptor_types/create"

  get "receptor_types/destroy"

  #---------------------- login routes ----------------------------------------------------------------------

  get 'admin' => 'admin#index'

  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout' => :destroy
  end

  resources :targets, :except => [:update, :edit] do
    resources :prepare_receptors 
  end
  
  resources :receptor_types

  resources :cycles

  #---------------------- assay routes ----------------------------------------------------------------------

  resources :assays

  controller :assays do
    get 'assays/:id/compounds' => :compounds, :as => :assays_compounds
    get 'assays/:id/data_table' => :data_table , :as => :assay_data_table
    get 'assays/:id/download' => :download, :as => :assay_download
  end


  #---------------------- compound routes -------------------------------------------------------------------

  resources :compounds

  #---------------------- search routes ----------------------------------------------------------------------

  controller :compounds do
	get 'compounds/:id/download' => :download, :as => :compound_download
    post 'compounds/search' => :search, :as => :search_compound
  end



  #---------------------- query routes ----------------------------------------------------------------------
  resources :users, :except => :index do
    resources :queries
  end

  #----------------------- docking routes --------------------------------------------------------------

  controller :users do
    get 'users/:id/docking' => :docking, :as => :docking_user
    get 'users/:id/docking/:target_id/docking_notification' => :docking_notification, :as => :docking_notification_user
    get 'users/:id/docking/:target_id/docking_progress' => :docking_progress, :as => :docking_progress_user
    get 'users/:target_id/compound_ranking/filter_one/:filter_one/filter_two/:filter_two/filter_tree/:filter_tree' => :compound_ranking, :as => :compound_ranking_user
    get 'user/:id/docking/:target_id/stop' => :stop_docking, :as => :stop_docking_user
    post 'users/compound_rank' => :compound_rank, :as => :compound_rank_user
    post 'users/:id/start_docking' => :start_docking, :as => :start_docking_user
    post 'users/:target_id/:cid/:receptor/download_conformer' => :download_conformer, :as => :download_conformer_user
  end

  #---------------------- download routes ---------------------------------------------------------------------

  controller :queries do
    get 'queries/:id/schedule_notification' => :schedule_notification, :as => :schedule_notification_query
    get 'queries/:id/download_notification' => :download_notification, :as => :download_notification_query
    get 'queries/:id/start' => :start, :as => :start_query
    get 'queries/:id/stop' => :stop, :as => :stop_query
    get 'queries/:id/unschedule' => :unschedule, :as => :unschedule_query
  end




  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:

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
  root :to => "home#index", :as => "home"

  #---------------------- errors routes ---------------------------------------------------------------------

  controller :home do
    get 'help' => :help
    get 'errors', :errors, :as => :errors
  end
  
  # Any other routes are handled here (as ActionDispatch prevents RoutingError from hitting ApplicationController::rescue_action).
  match "*path", :to => "application#routing_error"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
