defmodule PetsWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
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
              <%= if has_user_admin?(@current_scope) do %>
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

      <div class="drawer-side z-50">
        <label for="chat-drawer-toggle" aria-label="close sidebar" class="drawer-overlay"></label>

        <aside class="w-96 min-h-full bg-base-100 p-4">
          <.chat_sidebar />
        </aside>
      </div>
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

  def chat_sidebar(assigns) do
    ~H"""
    <div class="flex flex-col h-full">
      <h3 class="text-xl font-semibold mb-4 border-b border-base-300 pb-2">
        Mensajes
      </h3>

      <div class="mb-4">
        <h4 class="text-sm font-bold text-gray-500 uppercase mb-2">Contactos</h4>
        <ul class="menu p-0">
          <li>
            <a class="active">
              <div class="avatar online">
                <div class="w-8 rounded-full">
                  <img src="https://ui-avatars.com/api/?name=Ana+Lopez&background=random" />
                </div>
              </div>
              Ana López
            </a>
          </li>
          <li>
            <a>
              <div class="avatar offline">
                <div class="w-8 rounded-full">
                  <img src="https://ui-avatars.com/api/?name=Juan+Perez&background=random" />
                </div>
              </div>
              Juan Pérez
            </a>
          </li>
          <li>
            <a>
              <div class="avatar online">
                <div class="w-8 rounded-full">
                  <img src="https://ui-avatars.com/api/?name=Maria+G&background=random" />
                </div>
              </div>
              Maria G.
            </a>
          </li>
        </ul>
      </div>

      <div class="divider m-0"></div>

      <div class="flex-1 overflow-y-auto my-4 p-2 bg-base-200 rounded-box">
        <div class="chat chat-start">
          <div class="chat-header text-xs opacity-50">Ana López</div>
          <div class="chat-bubble">¡Hola! ¿Cómo estás?</div>
        </div>
        <div class="chat chat-end">
          <div class="chat-bubble chat-bubble-primary">¡Hola Ana! Todo bien, ¿y tú?</div>
        </div>
        <div class="chat chat-start">
          <div class="chat-header text-xs opacity-50">Ana López</div>
          <div class="chat-bubble">¡Genial!</div>
        </div>
      </div>

      <form class="flex space-x-2">
        <input type="text" placeholder="Escribe un mensaje..." class="input input-bordered flex-1" />
        <button type-="submit" class="btn btn-primary">
          <.icon name="hero-paper-airplane" class="size-4" />
        </button>
      </form>
    </div>
    """
  end

  attr :id, :string, default: "shelter-dropdown"

  def shelter_dropdown(assigns) do
    ~H"""
    <div class="dropdown dropdown-end" id={@id}>
      <div tabindex="0" role="button" class="btn btn-ghost m-1">
        <span>Administración</span>
        <.icon name="hero-chevron-down" class="size-4" />
      </div>

      <ul tabindex="0" class="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-64">
        <li><a href={~p"/refugio/inventario"}><.icon name="hero-shopping-bag" />Inventario</a></li>
        <li><a href={~p"/admin/visitas"}><.icon name="hero-users" />Visitas</a></li>
        <li><a href={~p"/admin/donaciones"}><.icon name="hero-home" />Donaciones</a></li>
      </ul>
    </div>
    """
  end

  defp has_user_admin?(%{usuario: %{roles: roles}}) when is_list(roles) do
    "admin"
  end

  defp has_user_admin?(_), do: false

  def has_user_shelter?(%{usuario: %{roles: roles}}) when is_list(roles) do
    "shelter"
  end

  defp has_user_shelter?(), do: false
end
