# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
  post 'redshares/redshares', :to => 'redshares#redshare', :as => 'redshare'
  delete 'redshares/redshares', :to => 'redshares#unredshare'
  get 'redshares/new', :to => 'redshares#new'
  post 'redshares', :to => 'redshares#create'
  post 'redshares/append', :to => 'redshares#append'
  delete 'redshares', :to => 'redshares#destroy'
  get 'redshares/autocomplete_for_user', :to => 'redshares#autocomplete_for_user'