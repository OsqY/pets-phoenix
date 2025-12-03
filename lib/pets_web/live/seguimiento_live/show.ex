defmodule PetsWeb.SeguimientoLive.Show do
  use PetsWeb, :live_view

  alias Pets.Adopciones

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Seguimiento #{@seguimiento.id}
        <:subtitle>Información del seguimiento registrado.</:subtitle>
        <:actions>
          <.button navigate={~p"/solicitudes-adopcion/#{@seguimiento.solicitud_id}"}>
            <.icon name="hero-arrow-left" /> Volver a solicitud
          </.button>
          <%= if "refugio" in @current_scope.usuario.roles do %>
            <.button variant="primary" navigate={~p"/seguimientos/#{@seguimiento.id}/editar?return_to=show"}>
              <.icon name="hero-pencil-square" /> Editar seguimiento
            </.button>
          <% end %>
        </:actions>
      </.header>

      <.list>
        <:item title="Fecha">{Calendar.strftime(@seguimiento.fecha, "%d/%m/%Y")}</:item>
        <:item title="Notas">{@seguimiento.notas}</:item>
        <:item title="Mascota">{@seguimiento.solicitud.mascota.nombre}</:item>
        <:item title="Adoptante">{@seguimiento.solicitud.adoptante.email}</:item>
        <:item title="Estado de solicitud">{Pets.Adopciones.SolicitudAdopcion.humanize_estado(@seguimiento.solicitud.estado)}</:item>
        <:item title="Responsable">{@seguimiento.responsable.email}</:item>
        <:item title="Registrado el">{Calendar.strftime(@seguimiento.inserted_at, "%d/%m/%Y %H:%M")}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Adopciones.subscribe_seguimientos(socket.assigns.current_scope)
    end

    seguimiento =
      Adopciones.get_seguimiento!(socket.assigns.current_scope, id)
      |> Pets.Repo.preload([:responsable, solicitud: [:mascota, :adoptante]])

    {:ok,
     socket
     |> assign(:page_title, "Ver Seguimiento")
     |> assign(:seguimiento, seguimiento)}
  end

  @impl true
  def handle_info(
        {:updated, %Pets.Adopciones.Seguimiento{id: id} = seguimiento},
        %{assigns: %{seguimiento: %{id: id}}} = socket
      ) do
    seguimiento = Pets.Repo.preload(seguimiento, [:responsable, solicitud: [:mascota, :adoptante]])
    {:noreply, assign(socket, :seguimiento, seguimiento)}
  end

  def handle_info(
        {:deleted, %Pets.Adopciones.Seguimiento{id: id}},
        %{assigns: %{seguimiento: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "El seguimiento fue eliminado.")
     |> push_navigate(to: ~p"/seguimientos")}
  end

  def handle_info({type, %Pets.Adopciones.Seguimiento{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
