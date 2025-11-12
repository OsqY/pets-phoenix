defmodule PetsWeb.SeguimientoLive.Index do
  use PetsWeb, :live_view

  alias Pets.Adopciones

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Seguimientos
      </.header>

      <.table
        id="seguimientos"
        rows={@streams.seguimientos}
        row_click={fn {_id, seguimiento} -> JS.navigate(~p"/seguimientos/#{seguimiento}") end}
      >
        <:col :let={{_id, seguimiento}} label="Fecha">{seguimiento.fecha}</:col>
        <:col :let={{_id, seguimiento}} label="Notas">{seguimiento.notas}</:col>
        <:col :let={{_id, seguimiento}} label="Solicitud">{seguimiento.solicitud_id}</:col>
        <:col :let={{_id, seguimiento}} label="Responsable">{seguimiento.responsable_id}</:col>
        <:action :let={{_id, seguimiento}}>
          <div class="sr-only">
            <.link navigate={~p"/seguimientos/#{seguimiento}"}>Ver</.link>
          </div>
          <%= if "refugio" in @current_scope.usuario.roles do %>
            <.link navigate={~p"/seguimientos/#{seguimiento}/edit"}>Editar</.link>
          <% end %>
        </:action>
        <:action :let={{id, seguimiento}}>
          <%= if "refugio" in @current_scope.usuario.roles do %>
            <.link
              phx-click={JS.push("delete", value: %{id: seguimiento.id}) |> hide("##{id}")}
              data-confirm="¿Desea eliminar este seguimiento?"
            >
              Borrar
            </.link>
          <% end %>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Adopciones.subscribe_seguimientos(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Seguimientos")
     |> stream(:seguimientos, list_seguimientos(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    seguimiento = Adopciones.get_seguimiento!(socket.assigns.current_scope, id)
    {:ok, _} = Adopciones.delete_seguimiento(socket.assigns.current_scope, seguimiento)

    {:noreply, stream_delete(socket, :seguimientos, seguimiento)}
  end

  @impl true
  def handle_info({type, %Pets.Adopciones.Seguimiento{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :seguimientos, list_seguimientos(socket.assigns.current_scope), reset: true)}
  end

  defp list_seguimientos(current_scope) do
    if "refugio" in current_scope.usuario.roles do
      Adopciones.list_seguimientos(current_scope)
    else
      Adopciones.list_seguimientos_adoptante(current_scope)
    end
  end
end
