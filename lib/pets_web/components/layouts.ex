defmodule PetsWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use PetsWeb, :live_view
  use PetsWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.
  ...
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    assigns = assign(assigns, :form, to_form(%{query: ""}))

    ~H"""
    <div class="drawer drawer-end">
      <input id="chat-drawer-toggle" type="checkbox" class="drawer-toggle" />

      <div class="drawer-content flex flex-col min-h-screen">
        <header class="navbar px-4 sm:px-6 lg:px-8">
          <div class="flex-1">
            <a href="/" class="flex-1 flex w-fit items-center gap-2">
              <img src={~p"/images/logo.svg"} width="36" />
              <span class="text-sm font-semibold">v{Application.spec(:phoenix, :vsn)}</span>
            </a>
          </div>
          <div class="flex-none">
            <ul class="flex flex-column px-1 space-x-4 items-center">
              <li>
                <.social_dropdown />
              </li>
              <%= if @current_scope do %>
                <li>
                  <.adopciones_dropdown />
                </li>
              <% end %>
              <%= if @current_scope && has_user_shelter?(@current_scope) do %>
                <li>
                  <.shelter_dropdown />
                </li>
              <% end %>
              <%= if @current_scope && has_user_admin?(@current_scope) do %>
                <li>
                  <.admin_dropdown />
                </li>
              <% end %>
              <li>
                <.theme_toggle />
              </li>

              <li>
                <label for="chat-drawer-toggle" class="btn btn-ghost btn-circle">
                  <.icon name="hero-chat-bubble-left-right" class="size-6" />
                </label>
              </li>
            </ul>
          </div>
        </header>

        <main class="flex-1 px-4 py-10 sm:px-6 lg:px-8">
          <div class="mx-auto max-w-4xl space-y-4">
            {render_slot(@inner_block)}
          </div>
        </main>
      </div>

      <%= if @current_scope do %>
        <div class="drawer-side z-50">
          <label for="chat-drawer-toggle" aria-label="close sidebar" class="drawer-overlay"></label>

          <aside class="w-96 min-h-full bg-base-100 p-4">
            <.live_component
              module={PetsWeb.ChatSideBar}
              id="chat-sidebar"
              current_scope={@current_scope}
            />
          </aside>
        </div>
      <% end %>
    </div>
    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.
  ...
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.
  ...
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end

  attr :id, :string, default: "admin-dropdown"

  def admin_dropdown(assigns) do
    ~H"""
    <div class="dropdown dropdown-end" id={@id}>
      <div tabindex="0" role="button" class="btn btn-ghost m-1">
        <span>Administración</span>
        <.icon name="hero-chevron-down" class="size-4" />
      </div>

      <ul tabindex="0" class="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-64">
        <li><a href={~p"/admin/colores"}><.icon name="hero-shopping-bag" />Colores</a></li>
        <li><a href={~p"/admin/especies"}><.icon name="hero-users" />Especies</a></li>
        <li><a href={~p"/admin/razas"}><.icon name="hero-home" />Razas</a></li>
      </ul>
    </div>
    """
  end

  attr :id, :string, default: "shelter-dropdown"

  def shelter_dropdown(assigns) do
    ~H"""
    <div class="dropdown dropdown-end" id={@id}>
      <div tabindex="0" role="button" class="btn btn-ghost m-1">
        <span>Gestión de Refugio</span>
        <.icon name="hero-chevron-down" class="size-4" />
      </div>

      <ul tabindex="0" class="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-64">
        <li><a href={~p"/refugio/inventario"}><.icon name="hero-shopping-bag" />Inventario</a></li>
        <li>
          <a href={~p"/refugio/donacion-dinero"}><.icon name="hero-users" />Donaciones Dinero</a>
        </li>
        <li>
          <a href={~p"/refugio/donacion-inventario"}>
            <.icon name="hero-users" />Donaciones Inventario
          </a>
        </li>
      </ul>
    </div>
    """
  end

  attr :id, :string, default: "social-dropdown"

  def social_dropdown(assigns) do
    ~H"""
    <div class="dropdown dropdown-end" id={@id}>
      <div tabindex="0" role="button" class="btn btn-ghost m-1">
        <span>Social</span>
        <.icon name="hero-chevron-down" class="size-4" />
      </div>

      <ul tabindex="0" class="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-64">
        <li><a href={~p"/mascotas"}><.icon name="hero-shopping-bag" />Mascotas</a></li>
        <li><a href={~p"/posts"}><.icon name="hero-users" />Publicaciones</a></li>
      </ul>
    </div>
    """
  end

  attr :id, :string, default: "adopciones-dropdown"

  def adopciones_dropdown(assigns) do
    ~H"""
    <div class="dropdown dropdown-end" id={@id}>
      <div tabindex="0" role="button" class="btn btn-ghost m-1">
        <span>Adopciones</span>
        <.icon name="hero-chevron-down" class="size-4" />
      </div>

      <ul tabindex="0" class="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-64">
        <li>
          <a href={~p"/solicitudes-adopcion"}>
            <.icon name="hero-shopping-bag" />Solicitudes de Adopción
          </a>
        </li>
      </ul>
    </div>
    """
  end

  defp has_user_admin?(%{usuario: %{roles: roles}}) when is_list(roles) do
    "admin" in roles
  end

  defp has_user_admin?(_), do: false

  defp has_user_shelter?(%{usuario: %{roles: roles}}) when is_list(roles) do
    "refugio" in roles
  end

  defp has_user_shelter?(_), do: false
end
