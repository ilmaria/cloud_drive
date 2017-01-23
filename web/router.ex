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
    pipe_through [:browser, :authenticate]

    get "/", HomeController, :index
    get "/google/callback", HomeController, :auth_callback
    post "/logout", HomeController, :logout
  end

  scope "/login" CloudDrive do
    pipe_through :browser
  end

  scope "/shared", CloudDrive do
    pipe_through :browser
  end
end
