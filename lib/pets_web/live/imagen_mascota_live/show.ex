defmodule PetsWeb.ImagenMascotaLive.Show do
  use PetsWeb, :live_view

  alias Pets.Mascotas

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Imagen mascota {@imagen_mascota.id}
        <:subtitle>This is a imagen_mascota record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/imagenes_mascotas"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/imagenes_mascotas/#{@imagen_mascota}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit imagen_mascota
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Url">{@imagen_mascota.url}</:item>
        <:item title="Mascota">{@imagen_mascota.mascota_id}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Mascotas.subscribe_imagenes_mascotas(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Imagen mascota")
     |> assign(:imagen_mascota, Mascotas.get_imagen_mascota!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Pets.Mascotas.ImagenMascota{id: id} = imagen_mascota},
        %{assigns: %{imagen_mascota: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :imagen_mascota, imagen_mascota)}
  end

  def handle_info(
        {:deleted, %Pets.Mascotas.ImagenMascota{id: id}},
        %{assigns: %{imagen_mascota: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "La imagen de mascota fue eliminada.")
     |> push_navigate(to: ~p"/imagenes_mascotas")}
  end

  def handle_info({type, %Pets.Mascotas.ImagenMascota{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
