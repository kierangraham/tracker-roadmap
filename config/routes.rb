TrackerRoadmap::Application.routes.draw do
  root :to => "main#index"

  match '/workstream' => "main#workstream", :as => :workstream, :via => :get
end
