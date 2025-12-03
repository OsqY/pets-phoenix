defmodule PetsWeb.ColorLive.Index do
  use PetsWeb, :live_view

  alias Pets.Mascotas

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Lista de Colores
        <:actions>
          <.button variant="primary" navigate={~p"/admin/colores/crear"}>
            <.icon name="hero-plus" /> Nuevo Color
          </.button>
        </:actions>
      </.header>

      <.table
        id="colores"
        rows={@streams.colores}
        row_click={fn {_id, color} -> JS.navigate(~p"/admin/colores/#{color}") end}
      >
        <:col :let={{_id, color}} label="Nombre">{color.nombre}</:col>
        <:col :let={{_id, color}} label="Especie">
          <%= if color.especie do %>
            {color.especie.nombre}
          <% else %>
          <% end %>
        </:col>
        <:action :let={{_id, color}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/colores/#{color}"}>Ver</.link>
          </div>
          <.link navigate={~p"/admin/colores/#{color}/editar"}>Editar</.link>
        </:action>
        <:action :let={{id, color}}>
          <.link
            phx-click={JS.push("delete", value: %{id: color.id}) |> hide("##{id}")}
            data-confirm="¿Estás seguro?"
          >
            Eliminar
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Mascotas.subscribe_colores(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Lista de Colores")
     |> stream(:colores, list_colores(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    color = Mascotas.get_color!(socket.assigns.current_scope, id)
    {:ok, _} = Mascotas.delete_color(socket.assigns.current_scope, color)

    {:noreply, stream_delete(socket, :colores, color)}
  end

  @impl true
  def handle_info({type, %Pets.Mascotas.Color{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :colores, list_colores(socket.assigns.current_scope), reset: true)}
  end

  defp list_colores(current_scope) do
    Mascotas.list_colores(current_scope)
  end
end
