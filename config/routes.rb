ActionController::Routing::Routes.draw do |map|
  map.resources :node_classes

  map.resources :nodes
  map.resources :services do |service|
    service.resources :nodes, :member => { :disconnect => :get, :connect => :get }
  end
  
  map.root :controller => :nodes, :action => :index

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
