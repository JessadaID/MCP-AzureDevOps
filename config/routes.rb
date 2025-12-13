Rails.application.routes.draw do
  resources :posts
# Model Context Protocol
post "/mcp", to: "mcp#handle"
get  "/mcp", to: "mcp#handle"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
