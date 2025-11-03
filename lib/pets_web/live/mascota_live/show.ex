defmodule PetsWeb.MascotaLive.Show do
  use PetsWeb, :live_view

  alias Pets.Mascotas

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Mascota {@mascota.id}
        <:subtitle>This is a mascota record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/mascotas"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/mascotas/#{@mascota}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit mascota
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Nombre">{@mascota.nombre}</:item>
        <:item title="Descripcion">{@mascota.descripcion}</:item>
        <:item title="Edad">{@mascota.edad}</:item>
        <:item title="Sexo">{@mascota.sexo}</:item>
        <:item title="Tamanio">{@mascota.tamanio}</:item>
        <:item title="Peso">{@mascota.peso}</:item>
        <:item title="Color">{@mascota.color_id}</:item>
        <:item title="Usuario">{@mascota.usuario_id}</:item>
        <:item title="Especie">{@mascota.especie_id}</:item>
        <:item title="Raza">{@mascota.raza_id}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Mascotas.subscribe_mascotas(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Mascota")
     |> assign(:mascota, Mascotas.get_mascota!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Pets.Mascotas.Mascota{id: id} = mascota},
        %{assigns: %{mascota: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :mascota, mascota)}
  end

  def handle_info(
        {:deleted, %Pets.Mascotas.Mascota{id: id}},
        %{assigns: %{mascota: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current mascota was deleted.")
     |> push_navigate(to: ~p"/mascotas")}
  end

  def handle_info({type, %Pets.Mascotas.Mascota{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
