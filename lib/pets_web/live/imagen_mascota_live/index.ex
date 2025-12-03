defmodule PetsWeb.ImagenMascotaLive.Index do
  use PetsWeb, :live_view

  alias Pets.Mascotas

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Lista de Imágenes de Mascotas
        <:actions>
          <.button variant="primary" navigate={~p"/imagenes_mascotas/new"}>
            <.icon name="hero-plus" /> Nueva Imagen
          </.button>
        </:actions>
      </.header>

      <.table
        id="imagenes_mascotas"
        rows={@streams.imagenes_mascotas}
        row_click={fn {_id, imagen_mascota} -> JS.navigate(~p"/imagenes_mascotas/#{imagen_mascota}") end}
      >
        <:col :let={{_id, imagen_mascota}} label="Url">{imagen_mascota.url}</:col>
        <:col :let={{_id, imagen_mascota}} label="Mascota">{imagen_mascota.mascota_id}</:col>
        <:action :let={{_id, imagen_mascota}}>
          <div class="sr-only">
            <.link navigate={~p"/imagenes_mascotas/#{imagen_mascota}"}>Ver</.link>
          </div>
          <.link navigate={~p"/imagenes_mascotas/#{imagen_mascota}/edit"}>Editar</.link>
        </:action>
        <:action :let={{id, imagen_mascota}}>
          <.link
            phx-click={JS.push("delete", value: %{id: imagen_mascota.id}) |> hide("##{id}")}
            data-confirm="¿Estás seguro?"
          >
            Eliminar
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Mascotas.subscribe_imagenes_mascotas(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Lista de Imágenes de Mascotas")
     |> stream(:imagenes_mascotas, list_imagenes_mascotas(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    imagen_mascota = Mascotas.get_imagen_mascota!(socket.assigns.current_scope, id)
    {:ok, _} = Mascotas.delete_imagen_mascota(socket.assigns.current_scope, imagen_mascota)

    {:noreply, stream_delete(socket, :imagenes_mascotas, imagen_mascota)}
  end

  @impl true
  def handle_info({type, %Pets.Mascotas.ImagenMascota{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :imagenes_mascotas, list_imagenes_mascotas(socket.assigns.current_scope), reset: true)}
  end

  defp list_imagenes_mascotas(current_scope) do
    Mascotas.list_imagenes_mascotas(current_scope)
  end
end
