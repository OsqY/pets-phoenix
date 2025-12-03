defmodule PetsWeb.ColorLive.Show do
  use PetsWeb, :live_view

  alias Pets.Mascotas

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Color {@color.id}
        <:subtitle>Información del color registrado.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/colores"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/colores/#{@color}/editar?return_to=show"}>
            <.icon name="hero-pencil-square" /> Editar color
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Nombre">{@color.nombre}</:item>
        <:item title="Especie">{@color.especie_id}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Mascotas.subscribe_colores(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Ver Color")
     |> assign(:color, Mascotas.get_color!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Pets.Mascotas.Color{id: id} = color},
        %{assigns: %{color: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :color, color)}
  end

  def handle_info(
        {:deleted, %Pets.Mascotas.Color{id: id}},
        %{assigns: %{color: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "El color fue eliminado.")
     |> push_navigate(to: ~p"/colores")}
  end

  def handle_info({type, %Pets.Mascotas.Color{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
