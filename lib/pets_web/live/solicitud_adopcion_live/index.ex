defmodule PetsWeb.SolicitudAdopcionLive.Index do
  use PetsWeb, :live_view

  alias Pets.Adopciones
  import Pets.Adopciones.SolicitudAdopcion

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Solicitudes de Adopción
      </.header>

      <%= if "refugio" in @current_scope.usuario.roles do %>
        <.table
          id="solicitudes_adopcion"
          rows={@streams.solicitudes_adopcion}
          row_click={
            fn {_id, solicitud_adopcion} ->
              JS.navigate(~p"/solicitudes-adopcion/#{solicitud_adopcion}")
            end
          }
        >
          <:col :let={{_id, solicitud_adopcion}} label="Estado de Solicitud">
            {humanize_estado(solicitud_adopcion.estado)}
          </:col>
          <:col :let={{_id, solicitud_adopcion}} label="Fecha de Solicitud">
            {solicitud_adopcion.fecha_solicitud}
          </:col>
          <:col :let={{_id, solicitud_adopcion}} label="Fecha de Revisión">
            {if solicitud_adopcion.fecha_revision,
              do: solicitud_adopcion.fecha_revision,
              else: "Solicitud Pendiente de Revisión"}
          </:col>
          <:col :let={{_id, solicitud_adopcion}} label="Adoptante">
            {solicitud_adopcion.adoptante.email}
          </:col>
          <:col :let={{_id, solicitud_adopcion}} label="Mascota">
            {solicitud_adopcion.mascota.nombre}
          </:col>
          <:action :let={{_id, solicitud_adopcion}}>
            <div class="sr-only">
              <.link navigate={~p"/solicitudes-adopcion/#{solicitud_adopcion}"}>Ver</.link>
            </div>
          </:action>
        </.table>
      <% else %>
        <.table
          id="solicitudes_adopcion"
          rows={@streams.solicitudes_adopcion}
          row_click={
            fn {_id, solicitud_adopcion} ->
              JS.navigate(~p"/solicitudes-adopcion/#{solicitud_adopcion}")
            end
          }
        >
          <:col :let={{_id, solicitud_adopcion}} label="Estado de Solicitud">
            {humanize_estado(solicitud_adopcion.estado)}
          </:col>
          <:col :let={{_id, solicitud_adopcion}} label="Fecha de Solicitud">
            {solicitud_adopcion.fecha_solicitud}
          </:col>
          <:col :let={{_id, solicitud_adopcion}} label="Fecha de Revisión">
            {if solicitud_adopcion.fecha_revision,
              do: solicitud_adopcion.fecha_revision,
              else: "Solicitud Pendiente de Revisión"}
          </:col>
          <:col :let={{_id, solicitud_adopcion}} label="Mascota">
            {solicitud_adopcion.mascota.nombre}
          </:col>
          <:action :let={{_id, solicitud_adopcion}}>
            <div class="sr-only">
              <.link navigate={~p"/solicitudes-adopcion/#{solicitud_adopcion}"}>Ver</.link>
            </div>
          </:action>

          <:action :let={{id, solicitud_adopcion}}>
            <.link
              phx-click={JS.push("delete", value: %{id: solicitud_adopcion.id}) |> hide("##{id}")}
              data-confirm="¿Desea borrar esta solicitud?"
            >
              Borrar
            </.link>
          </:action>
        </.table>
      <% end %>
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
     |> assign(:page_title, "Solicitudes de Adopción")
     |> stream(:solicitudes_adopcion, list_solicitudes_adopcion(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    solicitud_adopcion = Adopciones.get_solicitud_adopcion!(socket.assigns.current_scope, id)

    {:ok, _} =
      Adopciones.delete_solicitud_adopcion(socket.assigns.current_scope, solicitud_adopcion)

    {:noreply, stream_delete(socket, :solicitudes_adopcion, solicitud_adopcion)}
  end

  @impl true
  def handle_info({type, %Pets.Adopciones.SolicitudAdopcion{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(
       socket,
       :solicitudes_adopcion,
       list_solicitudes_adopcion(socket.assigns.current_scope),
       reset: true
     )}
  end

  defp list_solicitudes_adopcion(current_scope) do
    if "refugio" not in current_scope.usuario.roles do
      Adopciones.list_solicitudes_adopcion_adoptante(current_scope)
    else
      Adopciones.list_solicitudes_adopcion_refugio(current_scope)
    end
  end
end
