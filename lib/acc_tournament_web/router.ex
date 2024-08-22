defmodule AccTournamentWeb.Router do
  use AccTournamentWeb, :router

  import AccTournamentWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AccTournamentWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  live_session(:default, on_mount: {AccTournamentWeb.UserAuth, :mount_current_user}) do
    scope "/", AccTournamentWeb do
      pipe_through :browser

      get "/", PageController, :home

      live "/profile/:id", ProfileLive, :view

      scope "/qualifiers" do
        live "/", QualifierLeaderboardLive
        live "/map_leaderboard/:id", MapLeaderboardLive
      end

      scope "/map_pools" do
        get "/", MapPoolsController, :pool_listing
        get "/:id", MapPoolsController, :map_listing
      end
    end
  end

  # Other scopes may use custom stacks.
  scope "/api", AccTournamentWeb do
    pipe_through :api

    scope "/map_pools" do
      get "/", MapPoolsController, :pool_listing
      get "/categories", MapPoolsController, :category_listing
      get "/:id/maps", MapPoolsController, :map_listing
      get "/:id/playlist", MapPoolsController, :playlist
      get "/:id/:category/playlist", MapPoolsController, :cat_playlist
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:acc_tournament, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AccTournamentWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", AccTournamentWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{AccTournamentWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", AccTournamentWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{AccTournamentWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/auth", AccTournamentWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/callback/beatleader", OAuthLoginController, :beatleader
  end

  scope "/", AccTournamentWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{AccTournamentWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
