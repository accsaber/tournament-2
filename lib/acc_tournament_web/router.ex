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

  pipeline :overlay do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AccTournamentWeb.Layouts, :overlay_root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]

    plug Plug.Parsers,
      parsers: [:urlencoded, :json],
      json_decoder: Jason
  end

  pipeline :api_authenticated do
    plug :fetch_session
    plug :fetch_current_user
    plug :fetch_user_from_auth_header
    plug :require_authenticated_user, redirect: false
  end

  import Phoenix.LiveDashboard.Router

  scope "/", AccTournamentWeb do
    pipe_through [:browser, :require_admin_user]

    live_session(:admin, on_mount: {AccTournamentWeb.UserAuth, :mount_current_user}) do
      live "/rules/new", RulebookAdminLive, :new
      live "/rules/new/:slug", RulebookAdminLive, :new
      live "/rules/:slug/edit", RulebookAdminLive, :edit
    end

    scope "/admin" do
      live "/users", AdminUserDirectory
      live "/map_pools/:map_pool_id/add_map", AdminAddMapLive
      live "/coordinator/matches", Coordinator.MatchMgmtLive
      live "/coordinator/match/:match_id", Coordinator.MatchAdminLive
      live "/coordinator/pick/:pick_id", Coordinator.PickAdminLive
      live "/stream", Coordinator.StreamAdminLive
      live_dashboard "/dashboard", metrics: AccTournamentWeb.Telemetry
    end
  end

  scope "/overlay", AccTournamentWeb do
    pipe_through [:overlay]

    live "/picks", PicksBansLive
    live "/header", HeaderOnlyLive
    live "/cam/:id", PlayerCamLive
    live "/ingame", InGameLive
    live "/countdown", Overlay.IntroLive
    live "/player_intro", Overlay.PlayerIntroLive
  end

  live_session(:default, on_mount: {AccTournamentWeb.UserAuth, :mount_current_user}) do
    scope "/", AccTournamentWeb do
      pipe_through :browser

      get "/health", HealthController, :index

      live "/", RulebookLive, :show
      live "/rules", RulebookLive, :show
      live "/rules/:slug", RulebookLive, :show

      live "/profile/:id", ProfileLive, :view
      live "/profile/:id/@:friendly_name", ProfileLive, :view

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

    get "/qualifiers/leaderboard/:hash/:difficulty", QualifierScoreController, :leaderboard

    scope "/qualifiers" do
      pipe_through :api_authenticated
      get "/whoami", ApiUserController, :whoami
      get "/attempts/:map_id", QualifierScoreController, :list_attempts

      get "/remaining-attempts/:hash/:difficulty", QualifierScoreController, :remaining_attempts

      post "/create_attempt", QualifierScoreController, :create_attempt
      post "/submit_attempt", QualifierScoreController, :submit_attempt
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:acc_tournament, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).

    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

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

  scope "/users/", AccTournamentWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/download_qualifier_key", PluginDownloadController, :download

    live_session :require_authenticated_user,
      on_mount: [{AccTournamentWeb.UserAuth, :ensure_authenticated}] do
      live "/settings", UserSettingsLive, :edit
      live "/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/auth/callback/", AccTournamentWeb do
    pipe_through [:browser]
    get "/beatleader", OAuthLoginController, :beatleader
  end

  scope "/auth/callback/", AccTournamentWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/discord", OAuthLoginController, :discord
    get "/twitch", OAuthLoginController, :twitch
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
