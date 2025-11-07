defmodule PetsWeb.MascotaLive.Show do
  use PetsWeb, :live_view

  alias Pets.Mascotas

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@mascota.nombre}
        <:subtitle>{@mascota.descripcion}</:subtitle>
        <:actions>
          <.button navigate={~p"/mascotas"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <%= if @current_scope.usuario.id == @mascota.usuario_id do %>
            <.button variant="primary" navigate={~p"/mascotas/#{@mascota}/editar?return_to=show"}>
              <.icon name="hero-pencil-square" /> Editar mascota
            </.button>
          <% end %>
        </:actions>
      </.header>

      <.list>
        <:item title="Edad">{@mascota.edad}</:item>
        <:item title="Sexo">{@mascota.sexo}</:item>
        <:item title="Tamaño">{@mascota.tamanio}</:item>
        <:item title="Peso">{@mascota.peso}</:item>
        <:item title="Color">{@mascota.color.nombre}</:item>
        <:item title="Usuario">{@mascota.usuario.email}</:item>
        <:item title="Especie">{@mascota.especie.nombre}</:item>
        <:item title="Raza">{@mascota.raza.nombre}</:item>
        <:item title="Estado">{@mascota.estado}</:item>
        <:item title="Energía">{@mascota.energia}</:item>
        <:item title="¿Es amigable con otras mascotas?">
          <%= if @mascota.sociable_mascotas do %>
            <.icon name="hero-check-circle" class="text-green-500" /> Sí
          <% else %>
            <.icon name="hero-x-circle" class="text-red-500" /> No
          <% end %>
        </:item>
      </.list>

      <%= if can_adopt?(@current_scope, @mascota) do %>
        <.button navigate={
          ~p"/solicitudes/crear?mascota_id=#{@mascota.id}&mascota_nombre=#{@mascota.nombre}"
        }>
          Crear Solicitud de Adopción
        </.button>
      <% end %>
    </Layouts.app>
    """
  end

  defp can_adopt?(nil, _), do: false

  defp can_adopt?(scope, mascota) do
    mascota.estado == :EnAdopcion && "refugio" not in scope.usuario.roles
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Mascotas.subscribe_mascotas(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Ver Mascota")
     |> assign(:mascota, Mascotas.get_mascota_for_show!(socket.assigns.current_scope, id))}
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
