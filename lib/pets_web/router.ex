defmodule PetsWeb.Router do
  alias MascotaLive
  alias MascotaLive
  alias EspecieLive
  alias ColorLive
  alias RazaLive
  use PetsWeb, :router

  import PetsWeb.UsuarioAuth
  import Phoenix.LiveView.Router

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
      on_mount: [
        {
          PetsWeb.UsuarioAuth,
          :mount_current_scope
        },
        {PetsWeb.UsuarioAuth, :require_authenticated}
      ] do
      live "/usuario/settings", UsuarioLive.Settings, :edit
      live "/usuario/settings/confirm-email/:token", UsuarioLive.Settings, :confirm_email
      live "/posts/crear", PostLive.Form, :new
      live "/posts/:id/editar", PostLive.Form, :edit
      live "/comentarios/crear", ComentarioLive.Form, :new
      live "/comentarios/:id/editar", ComentarioLive.Form, :edit
      live "/mascotas/crear", MascotaLive.Form, :new
      live "/mascotas/:id/editar", MascotaLive.Form, :edit
      live "/solicitudes-adopcion", SolicitudAdopcionLive.Index, :index
      live "/solicitudes-adopcion/crear", SolicitudAdopcionLive.Form, :new
      live "/solicitudes-adopcion/:id/editar", SolicitudAdopcionLive.Form, :edit
      live "/solicitudes-adopcion/:id", SolicitudAdopcionLive.Show, :show
      live "/solicitudes-adopcion/:id/seguimientos", SeguimientoLive.Index, :index
      live "/solicitudes-adopcion/:id/seguimientos/crear", SeguimientoLive.Form, :new
      live "/solicitudes-adopcion/:id/seguimientos/:id/editar", SeguimientoLive.Form, :edit
      live "/solicitudes-adopcion/:id/seguimientos/:id", SeguimientoLive.Index, :show
      live "/chat", ChatLive, :index
    end

    post "/usuario/update-password", UsuarioSessionController, :update_password
  end

  scope "/", PetsWeb do
    pipe_through [:browser, :require_authenticated_usuario]

    live_session :require_admin,
      on_mount: [
        {
          PetsWeb.UsuarioAuth,
          :mount_current_scope
        },
        {PetsWeb.UsuarioAuth, :require_admin}
      ] do
      live "/admin/razas", RazaLive.Index, :index
      live "/admin/razas/crear", RazaLive.Form, :new
      live "/admin/razas/:id/editar", RazaLive.Form, :edit
      live "/admin/razas/:id", RazaLive.Show, :show
      live "/admin/colores", ColorLive.Index, :index
      live "/admin/colores/crear", ColorLive.Form, :new
      live "/admin/colores/:id", ColorLive.Show, :show
      live "/admin/colores/:id/editar", ColorLive.Form, :edit
      live "/admin/especies", EspecieLive.Index, :index
      live "/admin/especies/crear", EspecieLive.Form, :new
      live "/admin/especies/:id", EspecieLive.Show, :show
      live "/admin/especies/:id/editar", EspecieLive.Form, :edit
    end

    live_session :require_refugio,
      on_mount: [
        {PetsWeb.UsuarioAuth, :mount_current_scope},
        {PetsWeb.UsuarioAuth, :require_refugio}
      ] do
      live "/refugio/inventario", ItemInventarioLive.Index, :index
      live "/refugio/inventario/crear-item", ItemInventarioLive.Form, :new
      live "/refugio/inventario/:id/editar-item", ItemInventarioLive.Form, :edit
      live "/refugio/inventario/:id", ItemInventarioLive.Show, :show
      live "/refugio/donacion-dinero", DonacionDineroLive.Index, :index
      live "/refugio/donacion-dinero/crear", DonacionDineroLive.Form, :new
      live "/refugio/donacion-dinero/:id/editar", DonacionDineroLive.Form, :edit
      live "/refugio/donacion-dinero/:id", DonacionDineroLive.Show, :show
      live "/refugio/donacion-inventario", DonacionInventarioLive.Index, :index
      live "/refugio/donacion-inventario/crear", DonacionInventarioLive.Form, :new
      live "/refugio/donacion-inventario/:id/editar", DonacionInventarioLive.Form, :edit
      live "/refugio/donacion-inventario/:id", DonacionInventarioLive.Show, :show
    end
  end

  scope "/", PetsWeb do
    pipe_through [:browser]

    live_session :current_usuario,
      on_mount: [{PetsWeb.UsuarioAuth, :mount_current_scope}] do
      live "/usuario/register", UsuarioLive.Registration, :new
      live "/usuario/log-in", UsuarioLive.Login, :new
      live "/usuario/log-in/:token", UsuarioLive.Confirmation, :new
      live "/posts", PostLive.Index, :index
      live "/posts/:id", PostLive.Show, :show
      live "/mascotas", MascotaLive.Index, :index, as: :mascota_index
      live "/mascotas/:id", MascotaLive.Show, :show, as: :show_mascota
      live "/comentarios", ComentarioLive.Index, :index
      live "/comentarios/:id", ComentarioLive.Show, :show
    end

    post "/usuario/log-in", UsuarioSessionController, :create
    delete "/usuario/log-out", UsuarioSessionController, :delete
  end
end
