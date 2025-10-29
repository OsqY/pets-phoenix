defmodule PetsWeb.Router do
  alias PostController
  alias UserController
  use PetsWeb, :router

  import PetsWeb.UsuarioAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PetsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_usuario
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PetsWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/mascotas", MascotaController, :index
    get "/posts", PostController, :index

  end

  # Other scopes may use custom stacks.
  # scope "/api", PetsWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:pets, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PetsWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", PetsWeb do
    pipe_through [:browser, :require_authenticated_usuario]

    live_session :require_authenticated_usuario,
      on_mount: [{PetsWeb.UsuarioAuth, :require_authenticated}] do
      live "/usuario/settings", UsuarioLive.Settings, :edit
      live "/usuario/settings/confirm-email/:token", UsuarioLive.Settings, :confirm_email
    end

    post "/usuario/update-password", UsuarioSessionController, :update_password

    get "/mascotas/crear", MascotaController, :new
    get "/mascotas/:id", MascotaController, :show
    post "/mascotas", MascotaController, :create
    get "/mascotas/:id/edit", MascotaController, :edit
    put "/mascotas/:id", MascotaController, :update
    delete "/mascotas/:id", MascotaController, :delete

    get "/posts/crear", PostController, :new
    post "/posts", PostController, :create
    get "/posts/:id/edit", PostController, :edit
    put "/posts/:id", PostController, :update
    delete "/posts/:id", PostController, :delete
  end

  scope "/", PetsWeb do
    pipe_through [:browser]

    live_session :current_usuario,
      on_mount: [{PetsWeb.UsuarioAuth, :mount_current_scope}] do
      live "/usuario/register", UsuarioLive.Registration, :new
      live "/usuario/log-in", UsuarioLive.Login, :new
      live "/usuario/log-in/:token", UsuarioLive.Confirmation, :new
    end

    post "/usuario/log-in", UsuarioSessionController, :create
    delete "/usuario/log-out", UsuarioSessionController, :delete
  end
end
