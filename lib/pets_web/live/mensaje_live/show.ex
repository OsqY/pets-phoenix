defmodule PetsWeb.MensajeLive.Show do
  use PetsWeb, :live_view

  alias Pets.Chats

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Mensaje {@mensaje.id}
        <:subtitle>This is a mensaje record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/mensajes"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/mensajes/#{@mensaje}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit mensaje
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Contenido">{@mensaje.contenido}</:item>
        <:item title="Imagen">{@mensaje.imagen}</:item>
        <:item title="Fecha hora">{@mensaje.fecha_hora}</:item>
        <:item title="Emisor">{@mensaje.emisor_id}</:item>
        <:item title="Conversacion">{@mensaje.conversacion_id}</:item>
        <:item title="Leido">{@mensaje.leido}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Chats.subscribe_mensajes(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Mensaje")
     |> assign(:mensaje, Chats.get_mensaje!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Pets.Chats.Mensaje{id: id} = mensaje},
        %{assigns: %{mensaje: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :mensaje, mensaje)}
  end

  def handle_info(
        {:deleted, %Pets.Chats.Mensaje{id: id}},
        %{assigns: %{mensaje: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current mensaje was deleted.")
     |> push_navigate(to: ~p"/mensajes")}
  end

  def handle_info({type, %Pets.Chats.Mensaje{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
