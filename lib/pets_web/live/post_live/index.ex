defmodule PetsWeb.PostLive.Index do
  use PetsWeb, :live_view

  alias Pets.Posts
  alias Pets.Repo

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        <.icon name="hero-chat-bubble-left-right" class="w-8 h-8 mr-2 text-pink-500" /> Publicaciones
        <:actions>
          <.button
            variant="primary"
            navigate={~p"/posts/crear"}
            class="bg-gradient-to-r from-pink-500 to-purple-600 hover:from-pink-600 hover:to-purple-700 p-4 rounded-lg"
          >
            <.icon name="hero-plus" class="w-5 h-5 mr-1" /> Nueva Publicación
          </.button>
        </:actions>
      </.header>

      <div
        id="posts"
        phx-update="stream"
        class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8 flex flex-col gap-6"
      >
        <div
          :for={{id, post} <- @streams.posts}
          id={id}
          class="bg-white dark:bg-slate-800 rounded-2xl shadow-lg dark:shadow-2xl border border-zinc-200 dark:border-slate-700 overflow-hidden"
        >
          <div class="flex items-center justify-between p-4 border-b border-zinc-200 dark:border-slate-700">
            <div>
              <span class="font-semibold text-zinc-800 dark:text-gray-100">
                {post.usuario.email}
              </span>
              <span class="block text-sm text-zinc-500 dark:text-gray-400">
                <%!-- Para: {post.mascota.nombre} --%>
              </span>
            </div>
            <span class="text-sm text-zinc-500 dark:text-gray-400">
              {post.fecha}
            </span>
          </div>

          <div class="p-4">
            <p class="text-zinc-700 dark:text-gray-300 whitespace-pre-wrap">{post.content}</p>
          </div>

          <div class="flex items-center justify-end gap-2 p-3 bg-zinc-50 dark:bg-slate-800/50 border-t border-zinc-200 dark:border-slate-700">
            <.link
              navigate={~p"/posts/#{post}/editar"}
              class="p-2 text-sm font-medium text-blue-600 dark:text-blue-400 hover:text-blue-500 dark:hover:text-blue-300 hover:bg-blue-100 dark:hover:bg-blue-900/50 rounded-lg transition-colors duration-200"
            >
              <.icon name="hero-pencil-square" class="w-4 h-4" />
            </.link>
            <.link
              phx-click={JS.push("delete", value: %{id: post.id}) |> hide("##{id}")}
              data-confirm="¿Estás seguro de que quieres eliminar esta publicación?"
              class="p-2 text-sm font-medium text-red-600 dark:text-red-400 hover:text-red-500 dark:hover:text-red-300 hover:bg-red-100 dark:hover:bg-red-900/50 rounded-lg transition-colors duration-200"
            >
              <.icon name="hero-trash" class="w-4 h-4" />
            </.link>
          </div>
        </div>

        <div
          :if={map_size(@streams.posts) == 0}
          class="text-center py-16 bg-white dark:bg-slate-800 rounded-2xl border-2 border-dashed border-zinc-200 dark:border-slate-700"
        >
          <.icon name="hero-inbox" class="w-20 h-20 text-zinc-400 dark:text-slate-600 mx-auto mb-6" />
          <h3 class="text-2xl font-bold text-zinc-800 dark:text-gray-100 mb-3">
            ¡Aún no hay publicaciones!
          </h3>
          <p class="text-zinc-600 dark:text-gray-400 mb-6 max-w-md mx-auto leading-relaxed">
            Comienza creando tu primera publicación para una mascota.
          </p>
          <.button
            variant="primary"
            navigate={~p"/posts/crear"}
            class="bg-gradient-to-r from-pink-500 to-purple-600 hover:from-pink-600 hover:to-purple-700 shadow-lg hover:shadow-xl transition-all duration-300"
          >
            <.icon name="hero-plus" class="w-5 h-5 mr-2" /> Agregar primera publicación
          </.button>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Posts.subscribe_posts(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Posts")
     |> stream(:posts, list_posts())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Posts.get_post!(socket.assigns.current_scope, id)
    {:ok, _} = Posts.delete_post(socket.assigns.current_scope, post)

    {:noreply, stream_delete(socket, :posts, post)}
  end

  @impl true
  def handle_info({type, %Pets.Posts.Post{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :posts, list_posts(), reset: true)}
  end

  defp list_posts() do
    Posts.list_posts()
    |> Repo.preload([:usuario, :mascota])
  end
end
