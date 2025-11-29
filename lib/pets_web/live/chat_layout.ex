defmodule PetsWeb.ChatLayout do
  use PetsWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    socket =
      socket
      |> assign(:current_chat, session["current_chat"])
      |> assign(:usuario_new_chat, session["usuario_new_chat"])
      |> assign(:current_scope, session["current_scope"])

    if current_chat = socket.assigns.current_chat do
      PetsWeb.Endpoint.subscribe("conversacion:#{current_chat.id}")

      mensajes = Pets.Chats.list_mensajes(current_chat)

      {:ok,
       socket
       |> stream(:mensajes, mensajes)
       |> assign(:form, to_form(%{"mensaje_data" => ""}))}
    else
      {:ok,
       socket
       |> stream(:mensajes, [])
       |> assign(:form, to_form(%{"mensaje_data" => ""}))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col h-full bg-gray-50 dark:bg-gray-900">
      <div class="flex items-center gap-3 px-4 py-3 bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 shadow-sm">
        <button
          type="button"
          phx-click="remove_chat"
          class="p-2 text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-full transition-colors"
        >
          <.icon name="hero-arrow-left" class="w-5 h-5" />
        </button>

        <div class="flex items-center gap-3 flex-1">
          <div class="w-10 h-10 bg-indigo-100 dark:bg-indigo-900/50 rounded-full flex items-center justify-center">
            <span class="text-sm font-bold text-indigo-600 dark:text-indigo-300">
              {get_chat_user_initial(assigns)}
            </span>
          </div>
          <div>
            <p class="font-semibold text-gray-900 dark:text-gray-100">
              {get_chat_user_email(assigns)}
            </p>
            <p class="text-xs text-gray-500 dark:text-gray-400">
              En línea
            </p>
          </div>
        </div>
      </div>

      <div
        id="messages-container"
        phx-update="stream"
        phx-hook="ScrollToBottom"
        class="flex-1 overflow-y-auto px-4 py-4 space-y-3"
      >
        <div class="hidden only:flex flex-col items-center justify-center h-full text-gray-400 dark:text-gray-500">
          <.icon name="hero-chat-bubble-left-right" class="w-12 h-12 mb-2" />
          <p class="text-sm">No hay mensajes aún</p>
          <p class="text-xs">¡Envía el primer mensaje!</p>
        </div>

        <div
          :for={{dom_id, mensaje} <- @streams.mensajes}
          id={dom_id}
          class={[
            "flex",
            if(mensaje.emisor_id == @current_scope.usuario.id, do: "justify-end", else: "justify-start")
          ]}
        >
          <div class={[
            "max-w-[75%] rounded-2xl px-4 py-2 shadow-sm",
            if(mensaje.emisor_id == @current_scope.usuario.id,
              do: "bg-indigo-600 text-white rounded-br-md",
              else: "bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 rounded-bl-md border border-gray-100 dark:border-gray-700"
            )
          ]}>
            <p class="text-sm whitespace-pre-wrap break-words">{mensaje.contenido}</p>
            <div class={[
              "flex items-center gap-1 mt-1",
              if(mensaje.emisor_id == @current_scope.usuario.id,
                do: "justify-end",
                else: "justify-start"
              )
            ]}>
              <span class={[
                "text-xs",
                if(mensaje.emisor_id == @current_scope.usuario.id,
                  do: "text-indigo-200",
                  else: "text-gray-400 dark:text-gray-500"
                )
              ]}>
                {format_time(mensaje.inserted_at)}
              </span>
              <%= if mensaje.emisor_id == @current_scope.usuario.id do %>
                <.icon
                  name={if mensaje.leido, do: "hero-check-circle", else: "hero-check"}
                  class="w-3.5 h-3.5 text-indigo-200"
                />
              <% end %>
            </div>
          </div>
        </div>
      </div>

      <div class="px-4 py-3 bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700">
        <.form
          for={@form}
          id="message-form"
          phx-submit="send_mensaje"
          class="flex items-center gap-2"
        >
          <div class="flex-1 relative">
            <input
              type="text"
              name="mensaje_data"
              value={@form[:mensaje_data].value}
              placeholder="Escribe un mensaje..."
              autocomplete="off"
              class="w-full px-4 py-2.5 bg-gray-100 dark:bg-gray-700 border-0 rounded-full text-sm text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400 focus:ring-2 focus:ring-indigo-500 dark:focus:ring-indigo-400"
            />
          </div>
          <button
            type="submit"
            class="p-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 dark:focus:ring-offset-gray-800"
          >
            <.icon name="hero-paper-airplane" class="w-5 h-5" />
          </button>
        </.form>
      </div>
    </div>
    """
  end

  defp get_chat_user_email(assigns) do
    cond do
      assigns.usuario_new_chat ->
        assigns.usuario_new_chat.email

      assigns.current_chat && assigns.current_chat.emisor_id == assigns.current_scope.usuario.id ->
        assigns.current_chat.receptor.email

      assigns.current_chat ->
        assigns.current_chat.emisor.email

      true ->
        "Usuario"
    end
  end

  defp get_chat_user_initial(assigns) do
    email = get_chat_user_email(assigns)
    String.first(email) |> String.upcase()
  end

  defp format_time(datetime) do
    Calendar.strftime(datetime, "%H:%M")
  end

  @impl true
  def handle_event("send_mensaje", %{"mensaje_data" => mensaje_data}, socket) do
    mensaje_data = String.trim(mensaje_data)

    if mensaje_data == "" do
      {:noreply, socket}
    else
      cond do
        chat = socket.assigns.current_chat ->
          send_to_existing_chat(socket, chat, mensaje_data)

        socket.assigns.usuario_new_chat ->
          create_new_chat_and_send(socket, mensaje_data)

        true ->
          {:noreply, socket}
      end
    end
  end

  @impl true
  def handle_event("remove_chat", _params, socket) do
    send(self(), {:remove_chat})
    {:noreply, socket}
  end

  defp send_to_existing_chat(socket, chat, mensaje_data) do
    case Pets.Chats.create_mensaje(socket.assigns.current_scope, %{
           emisor_id: socket.assigns.current_scope.usuario.id,
           conversacion_id: chat.id,
           contenido: mensaje_data
         }) do
      {:ok, mensaje} ->
        Phoenix.PubSub.broadcast(
          Pets.PubSub,
          "conversacion:#{chat.id}",
          %{event: :new_mensaje, payload: mensaje}
        )

        {:noreply,
         socket
         |> stream_insert(:mensajes, mensaje)
         |> assign(:form, to_form(%{"mensaje_data" => ""}))}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Error al enviar mensaje")}
    end
  end

  defp create_new_chat_and_send(socket, mensaje_data) do
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

      # Notify parent to update state
      send(self(), {:chat_created, conversacion})

      {:noreply,
       socket
       |> assign(:current_chat, conversacion)
       |> assign(:usuario_new_chat, nil)
       |> stream_insert(:mensajes, mensaje)
       |> assign(:form, to_form(%{"mensaje_data" => ""}))}
    else
      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Error al crear conversación")}
    end
  end

  @impl true
  def handle_info(%{event: :new_mensaje, payload: mensaje}, socket) do
    # Only add if not already the sender (to avoid duplicates)
    if mensaje.emisor_id != socket.assigns.current_scope.usuario.id do
      {:noreply, stream_insert(socket, :mensajes, mensaje)}
    else
      {:noreply, socket}
    end
  end
end
