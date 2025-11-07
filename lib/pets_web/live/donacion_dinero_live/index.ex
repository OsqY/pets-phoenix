defmodule PetsWeb.DonacionDineroLive.Index do
  use PetsWeb, :live_view

  alias Pets.Refugios

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Donaciones Monetarias
        <:actions>
          <.button variant="primary" navigate={~p"/refugio/donacion-dinero/crear"}>
            <.icon name="hero-plus" /> Registrar Donación Monetaria
          </.button>
        </:actions>
      </.header>

      <.table
        id="donaciones_dinero"
        rows={@streams.donaciones_dinero}
        row_click={
          fn {_id, donacion_dinero} ->
            JS.navigate(~p"/refugio/donacion-dinero/#{donacion_dinero}")
          end
        }
      >
        <:col :let={{_id, donacion_dinero}} label="Monto">{donacion_dinero.monto}</:col>
        <:col :let={{_id, donacion_dinero}} label="Descripcion">{donacion_dinero.descripcion}</:col>
        <:col :let={{_id, donacion_dinero}} label="Fecha">{donacion_dinero.fecha}</:col>
        <:col :let={{_id, donacion_dinero}} label="Donantes">{donacion_dinero.donantes}</:col>
        <:action :let={{_id, donacion_dinero}}>
          <div class="sr-only">
            <.link navigate={~p"/refugio/donaciones-dinero/#{donacion_dinero}"}>Ver</.link>
          </div>
          <.link navigate={~p"/refugio/donaciones-dinero/#{donacion_dinero}/edit"}>Editar</.link>
        </:action>
        <:action :let={{id, donacion_dinero}}>
          <.link
            phx-click={JS.push("delete", value: %{id: donacion_dinero.id}) |> hide("##{id}")}
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
      Refugios.subscribe_donaciones_dinero(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Donaciones Monetarias")
     |> stream(:donaciones_dinero, list_donaciones_dinero(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    donacion_dinero = Refugios.get_donacion_dinero!(socket.assigns.current_scope, id)
    {:ok, _} = Refugios.delete_donacion_dinero(socket.assigns.current_scope, donacion_dinero)

    {:noreply, stream_delete(socket, :donaciones_dinero, donacion_dinero)}
  end

  @impl true
  def handle_info({type, %Pets.Refugios.DonacionDinero{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :donaciones_dinero, list_donaciones_dinero(socket.assigns.current_scope),
       reset: true
     )}
  end

  defp list_donaciones_dinero(current_scope) do
    Refugios.list_donaciones_dinero(current_scope)
  end
end
