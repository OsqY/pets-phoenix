defmodule PetsWeb.HistorialMedicoLive.Index do
  use PetsWeb, :live_view

  alias Pets.Mascotas

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Historiales medicos
        <:actions>
          <.button variant="primary" navigate={~p"/historiales_medicos/new"}>
            <.icon name="hero-plus" /> New Historial medico
          </.button>
        </:actions>
      </.header>

      <.table
        id="historiales_medicos"
        rows={@streams.historiales_medicos}
        row_click={fn {_id, historial_medico} -> JS.navigate(~p"/historiales_medicos/#{historial_medico}") end}
      >
        <:col :let={{_id, historial_medico}} label="Fecha">{historial_medico.fecha}</:col>
        <:col :let={{_id, historial_medico}} label="Tipo">{historial_medico.tipo}</:col>
        <:col :let={{_id, historial_medico}} label="Mascota">{historial_medico.mascota_id}</:col>
        <:action :let={{_id, historial_medico}}>
          <div class="sr-only">
            <.link navigate={~p"/historiales_medicos/#{historial_medico}"}>Show</.link>
          </div>
          <.link navigate={~p"/historiales_medicos/#{historial_medico}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, historial_medico}}>
          <.link
            phx-click={JS.push("delete", value: %{id: historial_medico.id}) |> hide("##{id}")}
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
      Mascotas.subscribe_historiales_medicos(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Historiales medicos")
     |> stream(:historiales_medicos, list_historiales_medicos(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    historial_medico = Mascotas.get_historial_medico!(socket.assigns.current_scope, id)
    {:ok, _} = Mascotas.delete_historial_medico(socket.assigns.current_scope, historial_medico)

    {:noreply, stream_delete(socket, :historiales_medicos, historial_medico)}
  end

  @impl true
  def handle_info({type, %Pets.Mascotas.HistorialMedico{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :historiales_medicos, list_historiales_medicos(socket.assigns.current_scope), reset: true)}
  end

  defp list_historiales_medicos(current_scope) do
    Mascotas.list_historiales_medicos(current_scope)
  end
end
