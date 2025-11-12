defmodule PetsWeb.ChatSideBar do
  alias Pets.Cuentas
  use Phoenix.LiveComponent
  use PetsWeb, :live_view
  import Phoenix.HTML.Form

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    chats = Pets.Chats.list_conversaciones(assigns.current_scope)

    {:ok,
     socket
     |> assign(:current_scope, assigns.current_scope)
     |> assign_new(:form, fn -> to_form(%{"query" => ""}) end)
     |> assign_new(:usuarios, fn -> [] end)
     |> assign_new(:current_chat, fn -> nil end)
     |> assign_new(:usuario_new_chat, fn -> nil end)
     |> assign_new(:chats, fn -> chats end)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col h-full bg-base-200 p-4">
      <%= if @usuario_new_chat || @current_chat do %>
        {live_render(
          @socket,
          PetsWeb.ChatLayout,
          id: "chat-layout",
          session: %{
            "current_chat" => @current_chat,
            "usuario_new_chat" => @usuario_new_chat,
            "current_scope" => @current_scope
          }
        )}
      <% else %>
        <.form
          for={@form}
          phx-change="search_user"
          phx-target={@myself}
          class="flex items-center"
          phx-debounce="500"
        >
          <.input field={@form[:query]} type="text" placeholder="Buscar Usuario" />
        </.form>
        <div class="my-4">
          Usuarios Encontrados
        </div>

        <div class="my-4" id="user-list">
          <%= for usuario <- @usuarios do %>
            <div class="flex items-center">
              <div class="flex-1">
                <p class="text-xs text-gray-500">{usuario.email}</p>
                <.button
                  phx-click="create_chat"
                  phx-value-usuario-id={usuario.id}
                  phx-target={@myself}
                >
                  <.icon name="hero-arrow-right" />
                </.button>
              </div>
            </div>
          <% end %>
        </div>
      <% end %>
      <h2 class="text-lg font-semibold mb-4">Mensajes</h2>

      <div class="mt-4">
        Chats
      </div>

      <div class="my-4" id="chat-list">
        <%= for chat <- @chats do %>
          <% usuario =
            if chat.emisor_id == @current_scope.usuario.id, do: chat.receptor, else: chat.emisor %>
          <div class="flex items-center">
            <div class="flex-1">
              <.button
                phx-click="init_chat"
                phx-value-id={chat.id}
                phx-target={@myself}
                class="text-left w-full p-2 hover:bg-base-300 rounded"
              >
                <p class="text-sm font-medium">{usuario.email}</p>
              </.button>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event(
        "search_user",
        %{"_target" => ["query"], "query" => query},
        socket
      ) do
    form = to_form(%{query: query})
    usuarios = Cuentas.search_users(socket.assigns.current_scope, query)

    {:noreply,
     socket
     |> assign(:form, form)
     |> assign(:usuarios, usuarios)}
  end

  @impl true
  def handle_event("create_chat", %{"usuario-id" => usuario_id}, socket) do
    usuario = Cuentas.get_usuario!(usuario_id)
    {:noreply, socket |> assign(:usuario_new_chat, usuario)}
  end

  @impl true
  def handle_event("init_chat", %{"id" => id}, socket) do
    chat_id = String.to_integer(id)
    chat = Enum.find(socket.assigns.chats, &(&1.id == chat_id))

    {:noreply,
     socket
     |> assign(:current_chat, chat)
     |> assign(:usuario_new_chat, nil)}
  end

  @impl true
  def handle_event("defer_chat", %{}, socket) do
    {:noreply, socket |> assign(:current_chat, nil)}
  end

  @impl true
  def handle_event("remove_chat", _params, socket) do
    {:noreply,
     socket
     |> assign(:current_chat, nil)
     |> assign(:usuario_new_chat, nil)}
  end
end
