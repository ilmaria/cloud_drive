defmodule CloudDrive.Router do
  use CloudDrive.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", CloudDrive do
    pipe_through :browser

    get "/", HomeController, :index
  end

  scope "/auth", CloudDrive do
    get "/google/", AuthController, :request
    get "/google/callback", AuthController, :callback
    post "/logout", AuthController, :logout
  end

  scope "/shared", CloudDrive do
    pipe_through :browser
  end
end
