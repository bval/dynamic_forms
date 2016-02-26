Dummy::Application.routes.draw do
  namespace :dynamic_forms do
    resources :form_submissions, :only => [:index, :show, :new, :create]
    resources :forms
  end
end
