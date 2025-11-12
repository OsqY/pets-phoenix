defmodule PetsWeb.ChatLayout do
  use PetsWeb, :live_view
  import Phoenix.HTML.Form

  @impl true
  def mount(_params, session, socket) do
    socket =
      socket
      |> assign(current_chat: session["current_chat"])
      |> assign(usuario_new_chat: session["usuario_new_chat"])
      |> assign(current_scope: session["current_scope"])

    if current_chat = socket.assigns.current_chat do
      PetsWeb.Endpoint.subscribe("conversacion:#{current_chat.id}")

      mensajes = Pets.Chats.list_mensajes(current_chat)

      {:ok,
       socket
       |> assign(:mensajes, mensajes)
       |> assign_new(:form, fn -> to_form(%{"mensaje_data" => ""}) end)}
    else
      {:ok,
       socket
       |> assign(:current_chat, nil)
       |> assign(:mensajes, [])
       |> assign_new(:form, fn -> to_form(%{"mensaje_data" => ""}) end)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col h-full bg-base-200 p-4">
      <.button phx-click="remove_chat">
        <.icon name="hero-arrow-left" />
      </.button>
      <h2 class="text-lg font-semibold mb-4">
        Chat con
        <%= if @usuario_new_chat  do %>
          {@usuario_new_chat.email}
        <% else %>
          <% if @current_chat && @current_chat.emisor_id == @current_scope.usuario.id do %>
            {@current_chat.receptor.email}
          <% else %>
            {@current_chat.emisor.email}
          <% end %>
        <% end %>
      </h2>

      <div
        id="messages-container"
        class="flex-grow overflow-y-auto my-4 space-y-4"
        phx-update="append"
      >
        <%= for mensaje <- @mensajes do %>
          <% is_sender = mensaje.emisor_id == @current_scope.usuario.id %>
          <div
            id={"mensaje-#{mensaje.id}"}
            class={"chat #{if is_sender, do: "chat-end", else: "chat-start"}"}
          >
            <div class="chat-bubble">
              {mensaje.contenido}
            </div>
          </div>
        <% end %>
      </div>
      <.form
        for={@form}
        class="flex items-center"
        phx-submit="send_mensaje"
        phx-debounce="500"
      >
        <.input field={@form["mensaje_data"]} type="text" placeholder="Enviar Mensaje" />
        <.button>
          <.icon name="hero-arrow-right" />
        </.button>
      </.form>
    </div>
    """
  end

  @impl true
  def handle_event("send_mensaje", %{"mensaje_data" => mensaje_data}, socket) do
    cond do
      chat = socket.assigns.current_chat ->
        with {:ok, mensaje} <-
               Pets.Chats.create_mensaje(socket.assigns.current_scope, %{
                 emisor_id: socket.assigns.current_scope.usuario.id,
                 conversacion_id: chat.id,
                 contenido: mensaje_data
               }) do
          Phoenix.PubSub.broadcast(
            Pets.PubSub,
            "conversacion:#{chat.id}",
            %{event: :new_mensaje, payload: mensaje}
          )

          {:noreply, reset_form(socket)}
        else
          {:error, _changeset} ->
            {:noreply, socket}
        end

      socket.assigns.usuario_new_chat ->
        with {:ok, conversacion} <-
               Pets.Chats.create_conversacion(socket.assigns.current_scope, %{
                 emisor_id: socket.assigns.current_scope.usuario.id,
                 receptor_id: socket.assigns.usuario_new_chat.id
               }),
             {:ok, mensaje} <-
               Pets.Chats.create_mensaje(socket.assigns.current_scope, %{
                 emisor_id: socket.assigns.current_scope.usuario.id,
                 conversacion_id: conversacion.id,
                 contenido: mensaje_data
               }) do
          PetsWeb.Endpoint.subscribe("conversacion:#{conversacion.id}")

          Phoenix.PubSub.broadcast(
            Pets.PubSub,
            "conversacion:#{conversacion.id}",
            %{event: :new_mensaje, payload: mensaje}
          )

          {:noreply,
           socket
           |> assign(:current_chat, conversacion)
           |> assign(:usuario_new_chat, nil)
           |> reset_form()}
        else
          {:error, _changeset} ->
            {:noreply, socket}
        end

      true ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info(%{event: "new_mensaje", payload: mensaje}, socket) do
    {:noreply, socket |> assign(:mensajes, socket.assigns.mensajes ++ [mensaje])}
  end

  defp reset_form(socket) do
    assign(socket, :form, to_form(%{"mensaje_data" => ""}))
  end
end
