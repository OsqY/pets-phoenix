defmodule PetsWeb.ChatSideBar do
  use Phoenix.LiveComponent
  use PetsWeb, :html

  alias Pets.Cuentas
  alias Pets.Chats

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:usuarios, [])
     |> assign(:current_chat, nil)
     |> assign(:usuario_new_chat, nil)
     |> assign(:search_query, "")
     |> assign(:chats, [])
     |> assign(:mensajes, [])
     |> assign(:message_form, to_form(%{"mensaje_data" => ""}))}
  end

  @impl true
  def update(assigns, socket) do
    chats = Chats.list_conversaciones(assigns.current_scope)

    {:ok,
     socket
     |> assign(:current_scope, assigns.current_scope)
     |> assign(:chats, chats)
     |> assign_new(:form, fn -> to_form(%{"query" => ""}) end)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col h-full bg-white dark:bg-gray-900">
      <%= if @usuario_new_chat || @current_chat do %>
        <div class="flex flex-col h-full">
          <div class="flex items-center gap-3 px-4 py-3 bg-gray-50 dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700">
            <button
              type="button"
              phx-click="back_to_list"
              phx-target={@myself}
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
                <p class="font-semibold text-gray-900 dark:text-gray-100 text-sm">
                  {get_chat_user_email(assigns)}
                </p>
                <p class="text-xs text-green-500">En línea</p>
              </div>
            </div>
          </div>

          <div
            id="chat-messages"
            class="flex-1 overflow-y-auto px-4 py-3 space-y-3 bg-gray-50 dark:bg-gray-900"
            phx-hook="ScrollToBottom"
          >
            <%= if @mensajes == [] do %>
              <div class="flex flex-col items-center justify-center h-full text-gray-400 dark:text-gray-500">
                <.icon name="hero-chat-bubble-left-right" class="w-10 h-10 mb-2" />
                <p class="text-sm">No hay mensajes</p>
                <p class="text-xs">¡Envía el primer mensaje!</p>
              </div>
            <% else %>
              <%= for mensaje <- @mensajes do %>
                <div
                  id={"msg-#{mensaje.id}"}
                  class={[
                    "flex",
                    if(mensaje.emisor_id == @current_scope.usuario.id, do: "justify-end", else: "justify-start")
                  ]}
                >
                  <div class={[
                    "max-w-[80%] rounded-2xl px-3 py-2 shadow-sm",
                    if(mensaje.emisor_id == @current_scope.usuario.id,
                      do: "bg-indigo-600 text-white rounded-br-sm",
                      else: "bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 rounded-bl-sm border border-gray-100 dark:border-gray-700"
                    )
                  ]}>
                    <p class="text-sm whitespace-pre-wrap break-words">{mensaje.contenido}</p>
                    <p class={[
                      "text-xs mt-1",
                      if(mensaje.emisor_id == @current_scope.usuario.id,
                        do: "text-indigo-200 text-right",
                        else: "text-gray-400 dark:text-gray-500"
                      )
                    ]}>
                      {format_time(mensaje.inserted_at)}
                    </p>
                  </div>
                </div>
              <% end %>
            <% end %>
          </div>

          <div class="px-3 py-3 bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700">
            <form phx-submit="send_mensaje" phx-target={@myself} class="flex items-center gap-2">
              <input
                type="text"
                name="mensaje_data"
                placeholder="Escribe un mensaje..."
                autocomplete="off"
                class="flex-1 px-4 py-2 bg-gray-100 dark:bg-gray-700 border-0 rounded-full text-sm text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400 focus:ring-2 focus:ring-indigo-500"
              />
              <button
                type="submit"
                class="p-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-full transition-colors"
              >
                <.icon name="hero-paper-airplane" class="w-5 h-5" />
              </button>
            </form>
          </div>
        </div>
      <% else %>
        <div class="flex flex-col h-full">
          <div class="p-4 border-b border-gray-200 dark:border-gray-700">
            <h2 class="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-3">Mensajes</h2>
            <form phx-change="search_user" phx-target={@myself} class="relative">
              <.icon
                name="hero-magnifying-glass"
                class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400"
              />
              <input
                type="text"
                name="query"
                value={@search_query}
                placeholder="Buscar usuario..."
                autocomplete="off"
                phx-debounce="300"
                class="w-full pl-10 pr-4 py-2 bg-gray-100 dark:bg-gray-800 border-0 rounded-full text-sm text-gray-900 dark:text-gray-100 placeholder-gray-500 focus:ring-2 focus:ring-indigo-500"
              />
            </form>
          </div>

          <%= if @usuarios != [] do %>
            <div class="px-4 py-2 bg-gray-50 dark:bg-gray-800/50">
              <p class="text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                Resultados de búsqueda
              </p>
            </div>
            <div class="divide-y divide-gray-100 dark:divide-gray-800">
              <%= for usuario <- @usuarios do %>
                <button
                  type="button"
                  phx-click="create_chat"
                  phx-value-usuario-id={usuario.id}
                  phx-target={@myself}
                  class="w-full flex items-center gap-3 px-4 py-3 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors text-left"
                >
                  <div class="w-10 h-10 bg-green-100 dark:bg-green-900/50 rounded-full flex items-center justify-center flex-shrink-0">
                    <span class="text-sm font-bold text-green-600 dark:text-green-300">
                      {String.first(usuario.email) |> String.upcase()}
                    </span>
                  </div>
                  <div class="flex-1 min-w-0">
                    <p class="text-sm font-medium text-gray-900 dark:text-gray-100 truncate">
                      {usuario.email}
                    </p>
                    <p class="text-xs text-gray-500 dark:text-gray-400">
                      Iniciar conversación
                    </p>
                  </div>
                  <.icon name="hero-chat-bubble-left-ellipsis" class="w-5 h-5 text-gray-400" />
                </button>
              <% end %>
            </div>
          <% end %>

          <div class="flex-1 overflow-y-auto">
            <%= if @chats == [] && @usuarios == [] do %>
              <div class="flex flex-col items-center justify-center h-full text-gray-400 dark:text-gray-500 px-4">
                <.icon name="hero-chat-bubble-left-right" class="w-12 h-12 mb-3" />
                <p class="text-sm font-medium">No tienes conversaciones</p>
                <p class="text-xs text-center mt-1">Busca un usuario para iniciar un chat</p>
              </div>
            <% else %>
              <%= if @chats != [] do %>
                <div class="px-4 py-2 bg-gray-50 dark:bg-gray-800/50">
                  <p class="text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                    Conversaciones
                  </p>
                </div>
                <div class="divide-y divide-gray-100 dark:divide-gray-800">
                  <%= for chat <- @chats do %>
                    <% usuario = get_other_user(chat, @current_scope) %>
                    <button
                      type="button"
                      phx-click="init_chat"
                      phx-value-id={chat.id}
                      phx-target={@myself}
                      class="w-full flex items-center gap-3 px-4 py-3 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors text-left"
                    >
                      <div class="w-12 h-12 bg-indigo-100 dark:bg-indigo-900/50 rounded-full flex items-center justify-center flex-shrink-0">
                        <span class="text-base font-bold text-indigo-600 dark:text-indigo-300">
                          {String.first(usuario.email) |> String.upcase()}
                        </span>
                      </div>
                      <div class="flex-1 min-w-0">
                        <div class="flex items-center justify-between">
                          <p class="text-sm font-medium text-gray-900 dark:text-gray-100 truncate">
                            {usuario.email}
                          </p>
                          <span class="text-xs text-gray-400 dark:text-gray-500">
                            {format_date(chat.updated_at)}
                          </span>
                        </div>
                        <p class="text-xs text-gray-500 dark:text-gray-400 truncate mt-0.5">
                          Haz clic para ver la conversación
                        </p>
                      </div>
                    </button>
                  <% end %>
                </div>
              <% end %>
            <% end %>
          </div>
        </div>
      <% end %>
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

  defp get_other_user(chat, current_scope) do
    if chat.emisor_id == current_scope.usuario.id do
      chat.receptor
    else
      chat.emisor
    end
  end

  defp format_time(datetime) do
    Calendar.strftime(datetime, "%H:%M")
  end

  defp format_date(datetime) do
    today = Date.utc_today()
    date = DateTime.to_date(datetime)

    cond do
      date == today ->
        format_time(datetime)

      Date.diff(today, date) == 1 ->
        "Ayer"

      Date.diff(today, date) < 7 ->
        Calendar.strftime(datetime, "%a")

      true ->
        Calendar.strftime(datetime, "%d/%m/%y")
    end
  end

  @impl true
  def handle_event("search_user", %{"query" => query}, socket) do
    query = String.trim(query)

    usuarios =
      if query != "" do
        Cuentas.search_users(socket.assigns.current_scope, query)
      else
        []
      end

    {:noreply,
     socket
     |> assign(:search_query, query)
     |> assign(:usuarios, usuarios)}
  end

  @impl true
  def handle_event("create_chat", %{"usuario-id" => usuario_id}, socket) do
    usuario = Cuentas.get_usuario!(usuario_id)

    {:noreply,
     socket
     |> assign(:usuario_new_chat, usuario)
     |> assign(:usuarios, [])
     |> assign(:search_query, "")
     |> assign(:mensajes, [])}
  end

  @impl true
  def handle_event("init_chat", %{"id" => id}, socket) do
    chat_id = String.to_integer(id)
    chat = Enum.find(socket.assigns.chats, &(&1.id == chat_id))

    if chat do
      # Load messages
      mensajes = Chats.list_mensajes(chat)

      {:noreply,
       socket
       |> assign(:current_chat, chat)
       |> assign(:usuario_new_chat, nil)
       |> assign(:mensajes, mensajes)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("back_to_list", _params, socket) do
    {:noreply,
     socket
     |> assign(:current_chat, nil)
     |> assign(:usuario_new_chat, nil)
     |> assign(:mensajes, [])}
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

  defp send_to_existing_chat(socket, chat, mensaje_data) do
    case Chats.create_mensaje(socket.assigns.current_scope, %{
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
         |> assign(:mensajes, socket.assigns.mensajes ++ [mensaje])}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  defp create_new_chat_and_send(socket, mensaje_data) do
    with {:ok, conversacion} <-
           Chats.create_conversacion(socket.assigns.current_scope, %{
             emisor_id: socket.assigns.current_scope.usuario.id,
             receptor_id: socket.assigns.usuario_new_chat.id
           }),
         {:ok, mensaje} <-
           Chats.create_mensaje(socket.assigns.current_scope, %{
             emisor_id: socket.assigns.current_scope.usuario.id,
             conversacion_id: conversacion.id,
             contenido: mensaje_data
           }) do
      Phoenix.PubSub.broadcast(
        Pets.PubSub,
        "conversacion:#{conversacion.id}",
        %{event: :new_mensaje, payload: mensaje}
      )

      # Reload chats to include new one
      chats = Chats.list_conversaciones(socket.assigns.current_scope)
      new_chat = Enum.find(chats, &(&1.id == conversacion.id))

      {:noreply,
       socket
       |> assign(:current_chat, new_chat)
       |> assign(:usuario_new_chat, nil)
       |> assign(:chats, chats)
       |> assign(:mensajes, [mensaje])}
    else
      {:error, _changeset} ->
        {:noreply, socket}
    end
  end
end
