defmodule PetsWeb.DonacionDineroLive.Show do
  use PetsWeb, :live_view

  alias Pets.Refugios

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Donacion dinero {@donacion_dinero.id}
        <:subtitle>This is a donacion_dinero record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/donaciones_dinero"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/donaciones_dinero/#{@donacion_dinero}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit donacion_dinero
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Monto">{@donacion_dinero.monto}</:item>
        <:item title="Descripcion">{@donacion_dinero.descripcion}</:item>
        <:item title="Fecha">{@donacion_dinero.fecha}</:item>
        <:item title="Donantes">{@donacion_dinero.donantes}</:item>
        <:item title="Refugio">{@donacion_dinero.refugio_id}</:item>
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
     |> assign(:page_title, "Show Donacion dinero")
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
     |> put_flash(:error, "The current donacion_dinero was deleted.")
     |> push_navigate(to: ~p"/donaciones_dinero")}
  end

  def handle_info({type, %Pets.Refugios.DonacionDinero{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
