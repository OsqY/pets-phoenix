defmodule PetsWeb.RazaLive.Index do
  use PetsWeb, :live_view

  alias Pets.Mascotas

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Razas
        <:actions>
          <.button variant="primary" navigate={~p"/admin/razas/crear"}>
            <.icon name="hero-plus" /> New Raza
          </.button>
        </:actions>
      </.header>

      <.table
        id="razas"
        rows={@streams.razas}
        row_click={fn {_id, raza} -> JS.navigate(~p"/admin/razas/#{raza}") end}
      >
        <:col :let={{_id, raza}} label="Nombre">{raza.nombre}</:col>
        <:action :let={{_id, raza}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/razas/#{raza}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/razas/#{raza}/editar"}>Edit</.link>
        </:action>
        <:action :let={{id, raza}}>
          <.link
            phx-click={JS.push("delete", value: %{id: raza.id}) |> hide("##{id}")}
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
      Mascotas.subscribe_razas(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Razas")
     |> stream(:razas, list_razas(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    raza = Mascotas.get_raza!(socket.assigns.current_scope, id)
    {:ok, _} = Mascotas.delete_raza(socket.assigns.current_scope, raza)

    {:noreply, stream_delete(socket, :razas, raza)}
  end

  @impl true
  def handle_info({type, %Pets.Mascotas.Raza{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :razas, list_razas(socket.assigns.current_scope), reset: true)}
  end

  defp list_razas(current_scope) do
    Mascotas.list_razas(current_scope)
  end
end
