defmodule PetsWeb.SeguimientoLive.Show do
  use PetsWeb, :live_view

  alias Pets.Adopciones

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Seguimiento {@seguimiento.id}
        <:subtitle>This is a seguimiento record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/seguimientos"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/seguimientos/#{@seguimiento}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit seguimiento
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Fecha">{@seguimiento.fecha}</:item>
        <:item title="Notas">{@seguimiento.notas}</:item>
        <:item title="Solicitud">{@seguimiento.solicitud_id}</:item>
        <:item title="Responsable">{@seguimiento.responsable_id}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Adopciones.subscribe_seguimientos(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Seguimiento")
     |> assign(:seguimiento, Adopciones.get_seguimiento!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Pets.Adopciones.Seguimiento{id: id} = seguimiento},
        %{assigns: %{seguimiento: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :seguimiento, seguimiento)}
  end

  def handle_info(
        {:deleted, %Pets.Adopciones.Seguimiento{id: id}},
        %{assigns: %{seguimiento: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current seguimiento was deleted.")
     |> push_navigate(to: ~p"/seguimientos")}
  end

  def handle_info({type, %Pets.Adopciones.Seguimiento{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
