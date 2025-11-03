defmodule PetsWeb.EspecieLive.Index do
  use PetsWeb, :live_view

  alias Pets.Mascotas

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Especies
        <:actions>
          <.button variant="primary" navigate={~p"/admin/especies/crear"}>
            <.icon name="hero-plus" /> New Especie
          </.button>
        </:actions>
      </.header>

      <.table
        id="especies"
        rows={@streams.especies}
        row_click={fn {_id, especie} -> JS.navigate(~p"/admin/especies/#{especie}") end}
      >
        <:col :let={{_id, especie}} label="Nombre">{especie.nombre}</:col>
        <:action :let={{_id, especie}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/especies/#{especie}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/especies/#{especie}/editar"}>Edit</.link>
        </:action>
        <:action :let={{id, especie}}>
          <.link
            phx-click={JS.push("delete", value: %{id: especie.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Mascotas.subscribe_especies(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Mostrando especies")
     |> stream(:especies, list_especies(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    especie = Mascotas.get_especie!(socket.assigns.current_scope, id)
    {:ok, _} = Mascotas.delete_especie(socket.assigns.current_scope, especie)

    {:noreply, stream_delete(socket, :especies, especie)}
  end

  @impl true
  def handle_info({type, %Pets.Mascotas.Especie{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :especies, list_especies(socket.assigns.current_scope), reset: true)}
  end

  defp list_especies(current_scope) do
    Mascotas.list_especies(current_scope)
  end
end
