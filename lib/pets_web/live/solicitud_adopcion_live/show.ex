defmodule PetsWeb.SolicitudAdopcionLive.Show do
  import Pets.Adopciones.SolicitudAdopcion
  use PetsWeb, :live_view

  alias Pets.Adopciones

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Solicitud de Adopción para {@solicitud_adopcion.mascota.nombre}
        <:subtitle>Solicitud de Adopción de {@solicitud_adopcion.adoptante.email}</:subtitle>
        <:actions>
          <.button navigate={~p"/solicitudes-adopcion"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button navigate={~p"/solicitudes-adopcion/#{@solicitud_adopcion}/seguimientos"}>
            Ver Seguimientos <.icon name="hero-arrow-right" />
          </.button>

          <%= if "refugio" in @current_scope.usuario.roles do %>
            <.button
              variant="primary"
              navigate={
                ~p"/solicitudes-adopcion/#{@solicitud_adopcion}/seguimientos/crear?solicitud-id=#{@solicitud_adopcion.id}&adoptante-id=#{@solicitud_adopcion.adoptante.id}"
              }
            >
              Crear Seguimiento
            </.button>
          <% end %>
        </:actions>
      </.header>
      <.list>
        <:item title="Estado de Solicitud">{humanize_estado(@solicitud_adopcion.estado)}</:item>
        <:item title="Fecha de Solicitud">{@solicitud_adopcion.fecha_solicitud}</:item>
        <:item title="Fecha de Revisión">
          {if @solicitud_adopcion.fecha_revision,
            do: @solicitud_adopcion.fecha_revision,
            else: "Su Solicitud no ha sido revisada."}
        </:item>
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
     |> assign(:page_title, "Ver Solicitud")
     |> assign(
       :solicitud_adopcion,
       Adopciones.get_solicitud_adopcion!(socket.assigns.current_scope, id)
     )}
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
     |> put_flash(:error, "Esta solicitud ha sido eliminada.")
     |> push_navigate(to: ~p"/solicitudes-adopcion")}
  end

  def handle_info({type, %Pets.Adopciones.SolicitudAdopcion{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end

  @impl true
  def handle_event("create_seguimiento", unsigned_params, socket) do
  end
end
