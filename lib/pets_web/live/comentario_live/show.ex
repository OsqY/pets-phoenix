defmodule PetsWeb.ComentarioLive.Show do
  use PetsWeb, :live_view

  alias Pets.Posts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Comentario {@comentario.id}
        <:subtitle>This is a comentario record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/comentarios"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/comentarios/#{@comentario}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit comentario
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Contenido">{@comentario.contenido}</:item>
        <:item title="Usuario">{@comentario.usuario_id}</:item>
        <:item title="Likes">{@comentario.likes}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Posts.subscribe_comentarios(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Comentario")
     |> assign(:comentario, Posts.get_comentario!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Pets.Posts.Comentario{id: id} = comentario},
        %{assigns: %{comentario: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :comentario, comentario)}
  end

  def handle_info(
        {:deleted, %Pets.Posts.Comentario{id: id}},
        %{assigns: %{comentario: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current comentario was deleted.")
     |> push_navigate(to: ~p"/comentarios")}
  end

  def handle_info({type, %Pets.Posts.Comentario{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
