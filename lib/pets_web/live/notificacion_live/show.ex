defmodule PetsWeb.NotificacionLive.Show do
  use PetsWeb, :live_view

  alias Pets.Chats

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Notificacion {@notificacion.id}
        <:subtitle>This is a notificacion record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/notificaciones"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/notificaciones/#{@notificacion}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit notificacion
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Contenido">{@notificacion.contenido}</:item>
        <:item title="Fehca">{@notificacion.fehca}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Chats.subscribe_notificaciones(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Notificacion")
     |> assign(:notificacion, Chats.get_notificacion!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Pets.Chats.Notificacion{id: id} = notificacion},
        %{assigns: %{notificacion: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :notificacion, notificacion)}
  end

  def handle_info(
        {:deleted, %Pets.Chats.Notificacion{id: id}},
        %{assigns: %{notificacion: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current notificacion was deleted.")
     |> push_navigate(to: ~p"/notificaciones")}
  end

  def handle_info({type, %Pets.Chats.Notificacion{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
