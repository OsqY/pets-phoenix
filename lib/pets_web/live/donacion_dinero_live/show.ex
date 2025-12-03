defmodule PetsWeb.DonacionDineroLive.Show do
  use PetsWeb, :live_view

  alias Pets.Refugios

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Donación Monetaria {@donacion_dinero.id}
        <:subtitle>Información del registro de donación monetaria.</:subtitle>
        <:actions>
          <.button navigate={~p"/refugio/donacion-dinero"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/refugio/donacion-dinero/#{@donacion_dinero}/editar?return_to=show"}>
            <.icon name="hero-pencil-square" /> Editar donación
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Monto">{format_lempiras(@donacion_dinero.monto)}</:item>
        <:item title="Descripción">{@donacion_dinero.descripcion}</:item>
        <:item title="Fecha">{@donacion_dinero.fecha}</:item>
        <:item title="Donante">{@donacion_dinero.donante || "Anónimo"}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Refugios.subscribe_donaciones_dinero(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Ver Donación Monetaria")
     |> assign(:donacion_dinero, Refugios.get_donacion_dinero!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Pets.Refugios.DonacionDinero{id: id} = donacion_dinero},
        %{assigns: %{donacion_dinero: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :donacion_dinero, donacion_dinero)}
  end

  def handle_info(
        {:deleted, %Pets.Refugios.DonacionDinero{id: id}},
        %{assigns: %{donacion_dinero: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "La donación fue eliminada.")
     |> push_navigate(to: ~p"/refugio/donacion-dinero")}
  end

  def handle_info({type, %Pets.Refugios.DonacionDinero{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
