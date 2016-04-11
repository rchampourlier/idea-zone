defmodule IdeaZone.Router do
  use IdeaZone.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admin do
    plug IdeaZone.Plugs.EnsureAdmin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", IdeaZone do
    pipe_through :browser # Use the default browser stack

    resources "/contents", ContentController, only: [:index, :show, :new, :create]
    get "/", ContentController, :index
    get "/admin/login", Admin.SessionController, :new
  end

  scope "/admin", IdeaZone.Admin, as: :admin do
    pipe_through :browser
    resources "/sessions", SessionController, only: [:new, :create]
  end

  scope "/admin", IdeaZone.Admin, as: :admin do
    pipe_through [:browser, :admin]

    get "/logout", SessionController, :delete
    resources "/contents", ContentController
    resources "/content_statuses", ContentStatusController
    resources "/content_types", ContentTypeController
  end

  # Other scopes may use custom stacks.
  # scope "/api", IdeaZone do
  #   pipe_through :api
  # end
end
