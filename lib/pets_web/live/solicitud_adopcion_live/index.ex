defmodule PetsWeb.SolicitudAdopcionLive.Index do
  use PetsWeb, :live_view

  alias Pets.Adopciones

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Solicitudes adopcion
        <:actions>
          <.button variant="primary" navigate={~p"/solicitudes_adopcion/new"}>
            <.icon name="hero-plus" /> New Solicitud adopcion
          </.button>
        </:actions>
      </.header>

      <.table
        id="solicitudes_adopcion"
        rows={@streams.solicitudes_adopcion}
        row_click={fn {_id, solicitud_adopcion} -> JS.navigate(~p"/solicitudes_adopcion/#{solicitud_adopcion}") end}
      >
        <:col :let={{_id, solicitud_adopcion}} label="Estado">{solicitud_adopcion.estado}</:col>
        <:col :let={{_id, solicitud_adopcion}} label="Fecha solicitud">{solicitud_adopcion.fecha_solicitud}</:col>
        <:col :let={{_id, solicitud_adopcion}} label="Fecha revision">{solicitud_adopcion.fecha_revision}</:col>
        <:col :let={{_id, solicitud_adopcion}} label="Adoptante">{solicitud_adopcion.adoptante_id}</:col>
        <:col :let={{_id, solicitud_adopcion}} label="Mascota">{solicitud_adopcion.mascota_id}</:col>
        <:action :let={{_id, solicitud_adopcion}}>
          <div class="sr-only">
            <.link navigate={~p"/solicitudes_adopcion/#{solicitud_adopcion}"}>Show</.link>
          </div>
          <.link navigate={~p"/solicitudes_adopcion/#{solicitud_adopcion}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, solicitud_adopcion}}>
          <.link
            phx-click={JS.push("delete", value: %{id: solicitud_adopcion.id}) |> hide("##{id}")}
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
      Adopciones.subscribe_solicitudes_adopcion(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Solicitudes adopcion")
     |> stream(:solicitudes_adopcion, list_solicitudes_adopcion(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    solicitud_adopcion = Adopciones.get_solicitud_adopcion!(socket.assigns.current_scope, id)
    {:ok, _} = Adopciones.delete_solicitud_adopcion(socket.assigns.current_scope, solicitud_adopcion)

    {:noreply, stream_delete(socket, :solicitudes_adopcion, solicitud_adopcion)}
  end

  @impl true
  def handle_info({type, %Pets.Adopciones.SolicitudAdopcion{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :solicitudes_adopcion, list_solicitudes_adopcion(socket.assigns.current_scope), reset: true)}
  end

  defp list_solicitudes_adopcion(current_scope) do
    Adopciones.list_solicitudes_adopcion(current_scope)
  end
end
