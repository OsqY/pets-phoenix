defmodule PetsWeb.EspecieLive.Show do
  use PetsWeb, :live_view

  alias Pets.Mascotas

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Especie {@especie.id}
        <:subtitle>Información de la especie registrada.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/especies"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/especies/#{@especie}/editar?return_to=show"}>
            <.icon name="hero-pencil-square" /> Editar especie
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Nombre">{@especie.nombre}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Mascotas.subscribe_especies(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Ver Especie")
     |> assign(:especie, Mascotas.get_especie!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Pets.Mascotas.Especie{id: id} = especie},
        %{assigns: %{especie: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :especie, especie)}
  end

  def handle_info(
        {:deleted, %Pets.Mascotas.Especie{id: id}},
        %{assigns: %{especie: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "La especie fue eliminada.")
     |> push_navigate(to: ~p"/especies")}
  end

  def handle_info({type, %Pets.Mascotas.Especie{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
