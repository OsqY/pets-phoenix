defmodule PetsWeb.DonacionInventarioLive.Show do
  use PetsWeb, :live_view

  alias Pets.Refugios

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Donación de Inventario {@donacion_inventario.id}
        <:subtitle>Información del registro de donación de inventario.</:subtitle>
        <:actions>
          <.button navigate={~p"/refugio/donacion-inventario"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/refugio/donacion-inventario/#{@donacion_inventario}/editar?return_to=show"}>
            <.icon name="hero-pencil-square" /> Editar donación
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Cantidad">{@donacion_inventario.cantidad}</:item>
        <:item title="Descripción">{@donacion_inventario.descripcion}</:item>
        <:item title="Fecha">{@donacion_inventario.fecha}</:item>
        <:item title="Donante">{@donacion_inventario.donante || "Anónimo"}</:item>
        <:item title="Medida">{@donacion_inventario.medida}</:item>
        <:item title="Tipo">{@donacion_inventario.tipo}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Refugios.subscribe_donaciones_inventario(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Ver Donación de Inventario")
     |> assign(:donacion_inventario, Refugios.get_donacion_inventario!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Pets.Refugios.DonacionInventario{id: id} = donacion_inventario},
        %{assigns: %{donacion_inventario: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :donacion_inventario, donacion_inventario)}
  end

  def handle_info(
        {:deleted, %Pets.Refugios.DonacionInventario{id: id}},
        %{assigns: %{donacion_inventario: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "La donación de inventario fue eliminada.")
     |> push_navigate(to: ~p"/refugio/donacion-inventario")}
  end

  def handle_info({type, %Pets.Refugios.DonacionInventario{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
