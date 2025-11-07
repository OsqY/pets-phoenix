defmodule PetsWeb.SolicitudAdopcionLive.Show do
  use PetsWeb, :live_view

  alias Pets.Adopciones

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Solicitud adopcion {@solicitud_adopcion.id}
        <:subtitle>This is a solicitud_adopcion record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/solicitudes_adopcion"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/solicitudes_adopcion/#{@solicitud_adopcion}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit solicitud_adopcion
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Estado">{@solicitud_adopcion.estado}</:item>
        <:item title="Fecha solicitud">{@solicitud_adopcion.fecha_solicitud}</:item>
        <:item title="Fecha revision">{@solicitud_adopcion.fecha_revision}</:item>
        <:item title="Adoptante">{@solicitud_adopcion.adoptante_id}</:item>
        <:item title="Mascota">{@solicitud_adopcion.mascota_id}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Adopciones.subscribe_solicitudes_adopcion(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Solicitud adopcion")
     |> assign(:solicitud_adopcion, Adopciones.get_solicitud_adopcion!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Pets.Adopciones.SolicitudAdopcion{id: id} = solicitud_adopcion},
        %{assigns: %{solicitud_adopcion: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :solicitud_adopcion, solicitud_adopcion)}
  end

  def handle_info(
        {:deleted, %Pets.Adopciones.SolicitudAdopcion{id: id}},
        %{assigns: %{solicitud_adopcion: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current solicitud_adopcion was deleted.")
     |> push_navigate(to: ~p"/solicitudes_adopcion")}
  end

  def handle_info({type, %Pets.Adopciones.SolicitudAdopcion{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
