defmodule PetsWeb.DonacionInventarioLive.Index do
  use PetsWeb, :live_view

  alias Pets.Refugios

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Donaciones
        <:actions>
          <.button variant="primary" navigate={~p"/refugio/donacion-inventario/crear"}>
            <.icon name="hero-plus" /> Registrar Donación
          </.button>
        </:actions>
      </.header>

      <.table
        id="donaciones_inventario"
        rows={@streams.donaciones_inventario}
        row_click={
          fn {_id, donacion_inventario} ->
            JS.navigate(~p"/refugio/donacion-inventario/#{donacion_inventario}")
          end
        }
      >
        <:col :let={{_id, donacion_inventario}} label="Cantidad">{donacion_inventario.cantidad}</:col>
        <:col :let={{_id, donacion_inventario}} label="Descripcion">
          {donacion_inventario.descripcion}
        </:col>
        <:col :let={{_id, donacion_inventario}} label="Fecha">{donacion_inventario.fecha}</:col>
        <:col :let={{_id, donacion_inventario}} label="Donante">{donacion_inventario.donante}</:col>
        <:col :let={{_id, donacion_inventario}} label="Medida">{donacion_inventario.medida}</:col>
        <:col :let={{_id, donacion_inventario}} label="Tipo">{donacion_inventario.tipo}</:col>
        <:action :let={{_id, donacion_inventario}}>
          <div class="sr-only">
            <.link navigate={~p"/refugio/donacion-inventario/#{donacion_inventario}"}>Ver</.link>
          </div>
          <.link navigate={~p"/refugio/donacion-inventario/#{donacion_inventario}/editar"}>
            Editar
          </.link>
        </:action>
        <:action :let={{id, donacion_inventario}}>
          <.link
            phx-click={JS.push("delete", value: %{id: donacion_inventario.id}) |> hide("##{id}")}
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
      Refugios.subscribe_donaciones_inventario(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Donaciones")
     |> stream(:donaciones_inventario, list_donaciones_inventario(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    donacion_inventario = Refugios.get_donacion_inventario!(socket.assigns.current_scope, id)

    {:ok, _} =
      Refugios.delete_donacion_inventario(socket.assigns.current_scope, donacion_inventario)

    {:noreply, stream_delete(socket, :donaciones_inventario, donacion_inventario)}
  end

  @impl true
  def handle_info({type, %Pets.Refugios.DonacionInventario{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(
       socket,
       :donaciones_inventario,
       list_donaciones_inventario(socket.assigns.current_scope),
       reset: true
     )}
  end

  defp list_donaciones_inventario(current_scope) do
    Refugios.list_donaciones_inventario(current_scope)
  end
end
