defmodule PetsWeb.ConversacionLive.Show do
  use PetsWeb, :live_view

  alias Pets.Chats

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Conversacion {@conversacion.id}
        <:subtitle>This is a conversacion record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/conversaciones"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/conversaciones/#{@conversacion}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit conversacion
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Emisor">{@conversacion.emisor_id}</:item>
        <:item title="Receptor">{@conversacion.receptor_id}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Chats.subscribe_conversaciones(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Conversacion")
     |> assign(:conversacion, Chats.get_conversacion!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Pets.Chats.Conversacion{id: id} = conversacion},
        %{assigns: %{conversacion: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :conversacion, conversacion)}
  end

  def handle_info(
        {:deleted, %Pets.Chats.Conversacion{id: id}},
        %{assigns: %{conversacion: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current conversacion was deleted.")
     |> push_navigate(to: ~p"/conversaciones")}
  end

  def handle_info({type, %Pets.Chats.Conversacion{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
