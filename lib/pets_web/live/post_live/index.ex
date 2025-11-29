defmodule PetsWeb.PostLive.Index do
  use PetsWeb, :live_view

  alias Pets.Posts
  alias Pets.Repo

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-2xl mx-auto px-4 py-6">
        <div class="flex items-center justify-between mb-6">
          <h1 class="text-2xl font-bold text-gray-900 dark:text-gray-100">Publicaciones</h1>
          <%= if @current_scope do %>
            <.button variant="primary" navigate={~p"/posts/crear"}>
              Nueva Publicación
            </.button>
          <% end %>
        </div>

        <div id="posts" phx-update="stream" class="space-y-6">
          <article
            :for={{id, post_data} <- @streams.posts}
            id={id}
            class="bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-800 rounded-xl shadow-sm overflow-hidden"
          >
            <div class="flex items-center justify-between p-4 border-b border-gray-100 dark:border-gray-800">
              <div class="flex items-center gap-3">
                <div class="w-9 h-9 bg-indigo-100 dark:bg-indigo-900/50 rounded-full flex items-center justify-center ring-2 ring-white dark:ring-gray-900">
                  <span class="text-sm font-bold text-indigo-600 dark:text-indigo-300">
                    {String.first(post_data.post.usuario.email) |> String.upcase()}
                  </span>
                </div>
                <div class="leading-tight">
                  <p class="text-sm font-semibold text-gray-900 dark:text-gray-100">
                    {post_data.post.usuario.email}
                  </p>
                  <p class="text-xs text-gray-500 dark:text-gray-400">
                    {format_date(post_data.post.fecha)}
                  </p>
                </div>
              </div>
              <%= if @current_scope && @current_scope.usuario.id == post_data.post.usuario_id do %>
                <div class="flex gap-1">
                  <button
                    type="button"
                    phx-click="edit"
                    phx-value-id={post_data.post.id}
                    class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-full transition-colors"
                    title="Editar"
                  >
                    <.icon name="hero-pencil-square" class="w-5 h-5" />
                  </button>
                  <button
                    type="button"
                    phx-click="delete"
                    phx-value-id={post_data.post.id}
                    data-confirm="¿Estás seguro?"
                    class="text-gray-400 hover:text-red-600 dark:hover:text-red-400 p-2 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-full transition-colors"
                    title="Eliminar"
                  >
                    <.icon name="hero-trash" class="w-5 h-5" />
                  </button>
                </div>
              <% end %>
            </div>

            <%= if post_data.post.imagenes_posts && length(post_data.post.imagenes_posts) > 0 do %>
              <div class="relative bg-gray-50 dark:bg-black aspect-square group" id={"post-carousel-#{post_data.post.id}"}>
                <%= for {imagen, index} <- Enum.with_index(post_data.post.imagenes_posts) do %>
                  <div class={[
                    "absolute inset-0 transition-opacity duration-300",
                    if(index == get_current_image(assigns, post_data.post.id), do: "opacity-100 z-10", else: "opacity-0 z-0")
                  ]}>
                    <img
                      src={imagen.url || "/placeholder.svg"}
                      alt="Post image"
                      class="w-full h-full object-cover"
                    />
                  </div>
                <% end %>

                <%= if length(post_data.post.imagenes_posts) > 1 do %>
                  <button
                    type="button"
                    phx-click="prev_image"
                    phx-value-post-id={post_data.post.id}
                    class="absolute left-3 top-1/2 -translate-y-1/2 z-20 bg-white/90 dark:bg-black/60 hover:bg-white text-gray-800 dark:text-white p-2 rounded-full shadow-sm opacity-0 group-hover:opacity-100 transition-all"
                  >
                    <.icon name="hero-chevron-left" class="w-4 h-4" />
                  </button>
                  <button
                    type="button"
                    phx-click="next_image"
                    phx-value-post-id={post_data.post.id}
                    class="absolute right-3 top-1/2 -translate-y-1/2 z-20 bg-white/90 dark:bg-black/60 hover:bg-white text-gray-800 dark:text-white p-2 rounded-full shadow-sm opacity-0 group-hover:opacity-100 transition-all"
                  >
                    <.icon name="hero-chevron-right" class="w-4 h-4" />
                  </button>
                  <div class="absolute bottom-3 left-1/2 -translate-x-1/2 flex gap-1.5 z-20 px-2 py-1 rounded-full bg-black/20 backdrop-blur-sm">
                    <%= for index <- 0..(length(post_data.post.imagenes_posts) - 1) do %>
                      <div class={[
                        "w-1.5 h-1.5 rounded-full transition-colors",
                        if(index == get_current_image(assigns, post_data.post.id), do: "bg-white", else: "bg-white/40")
                      ]}>
                      </div>
                    <% end %>
                  </div>
                <% end %>
              </div>
            <% end %>

            <div class="px-4 pt-3 pb-2 flex items-center gap-4">
              <button
                type="button"
                phx-click="toggle_like"
                phx-value-post-id={post_data.post.id}
                class={[
                  "flex items-center gap-1.5 transition-colors group",
                  if(post_data.user_liked, do: "text-red-500", else: "text-gray-500 hover:text-red-500")
                ]}
                disabled={is_nil(@current_scope)}
                title={if @current_scope, do: "Me gusta", else: "Inicia sesión para dar like"}
              >
                <.icon
                  name={if post_data.user_liked, do: "hero-heart-solid", else: "hero-heart"}
                  class="w-6 h-6 transition-transform group-hover:scale-110"
                />
                <span class="text-sm font-medium">{post_data.likes_count}</span>
              </button>

              <button
                type="button"
                phx-click="toggle_comments"
                phx-value-post-id={post_data.post.id}
                class="flex items-center gap-1.5 text-gray-500 hover:text-blue-500 transition-colors group"
              >
                <.icon name="hero-chat-bubble-oval-left" class="w-6 h-6 transition-transform group-hover:scale-110" />
                <span class="text-sm font-medium">{post_data.comentarios_count}</span>
              </button>
            </div>

            <div class="px-5 pb-4">
              <%= if post_data.post.mascota do %>
                <div class="flex items-center mb-3">
                  <div class="inline-flex items-center px-2.5 py-0.5 rounded-md text-xs font-medium bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300">
                    <span class="font-bold mr-1">{post_data.post.mascota.nombre}</span>
                    <span class="text-slate-400 dark:text-slate-500 mx-1">•</span>
                    <span>{post_data.post.mascota.especie.nombre}</span>
                  </div>
                </div>
              <% end %>

              <div class="prose prose-sm dark:prose-invert max-w-none">
                <p class="text-gray-700 dark:text-gray-300 whitespace-pre-wrap text-sm leading-relaxed">
                  {post_data.post.content}
                </p>
              </div>
            </div>

            <%= if MapSet.member?(@expanded_comments, post_data.post.id) do %>
              <div class="border-t border-gray-100 dark:border-gray-800 px-4 py-4 bg-gray-50/50 dark:bg-gray-800/30">
                <%= if @current_scope do %>
                  <.form
                    for={@comment_forms[post_data.post.id] || to_form(%{"contenido" => ""})}
                    id={"comment-form-#{post_data.post.id}"}
                    phx-submit="submit_comment"
                    phx-value-post-id={post_data.post.id}
                    class="flex gap-2 mb-4"
                  >
                    <div class="w-8 h-8 bg-indigo-100 dark:bg-indigo-900/50 rounded-full flex items-center justify-center flex-shrink-0">
                      <span class="text-xs font-bold text-indigo-600 dark:text-indigo-300">
                        {String.first(@current_scope.usuario.email) |> String.upcase()}
                      </span>
                    </div>
                    <div class="flex-1 flex gap-2">
                      <input
                        type="text"
                        name="contenido"
                        placeholder="Escribe un comentario..."
                        class="flex-1 text-sm border border-gray-200 dark:border-gray-700 rounded-full px-4 py-2 bg-white dark:bg-gray-900 focus:outline-none focus:ring-2 focus:ring-indigo-500 dark:focus:ring-indigo-400"
                        autocomplete="off"
                      />
                      <button
                        type="submit"
                        class="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-medium rounded-full transition-colors"
                      >
                        Enviar
                      </button>
                    </div>
                  </.form>
                <% else %>
                  <div class="text-center py-3 mb-4 bg-gray-100 dark:bg-gray-800 rounded-lg">
                    <p class="text-sm text-gray-500 dark:text-gray-400">
                      <.link navigate={~p"/usuario/iniciar-sesion"} class="text-indigo-600 dark:text-indigo-400 hover:underline">
                        Inicia sesión
                      </.link>
                      para comentar
                    </p>
                  </div>
                <% end %>

                <div class="space-y-3" id={"comments-#{post_data.post.id}"}>
                  <%= if Map.get(@comments_by_post, post_data.post.id, []) == [] do %>
                    <p class="text-sm text-gray-500 dark:text-gray-400 text-center py-2">
                      No hay comentarios aún. ¡Sé el primero!
                    </p>
                  <% else %>
                    <%= for comentario <- Map.get(@comments_by_post, post_data.post.id, []) do %>
                      <div class="flex gap-2" id={"comentario-#{comentario.id}"}>
                        <div class="w-8 h-8 bg-gray-200 dark:bg-gray-700 rounded-full flex items-center justify-center flex-shrink-0">
                          <span class="text-xs font-bold text-gray-600 dark:text-gray-300">
                            {String.first(comentario.usuario.email) |> String.upcase()}
                          </span>
                        </div>
                        <div class="flex-1">
                          <div class="bg-white dark:bg-gray-800 rounded-lg px-3 py-2 shadow-sm">
                            <p class="text-xs font-semibold text-gray-900 dark:text-gray-100">
                              {comentario.usuario.email}
                            </p>
                            <p class="text-sm text-gray-700 dark:text-gray-300 mt-0.5">
                              {comentario.contenido}
                            </p>
                          </div>
                          <div class="flex items-center gap-3 mt-1 px-1">
                            <span class="text-xs text-gray-400">
                              {format_datetime(comentario.inserted_at)}
                            </span>
                            <%= if @current_scope && @current_scope.usuario.id == comentario.usuario_id do %>
                              <button
                                type="button"
                                phx-click="delete_comment"
                                phx-value-comment-id={comentario.id}
                                phx-value-post-id={post_data.post.id}
                                class="text-xs text-red-500 hover:text-red-700 transition-colors"
                              >
                                Eliminar
                              </button>
                            <% end %>
                          </div>
                        </div>
                      </div>
                    <% end %>
                  <% end %>
                </div>
              </div>
            <% end %>
          </article>
        </div>

        <div :if={@posts_empty?} class="text-center py-16">
          <div class="text-gray-400 dark:text-gray-600 mb-4">
            <.icon name="hero-chat-bubble-left-right" class="w-16 h-16 mx-auto" />
          </div>
          <h3 class="text-lg font-medium text-gray-900 dark:text-gray-100 mb-2">
            No hay publicaciones
          </h3>
          <p class="text-sm text-gray-500 dark:text-gray-400 mb-4">Crea tu primera publicación</p>
          <%= if @current_scope do %>
            <.button variant="primary" navigate={~p"/posts/crear"}>
              Nueva Publicación
            </.button>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp format_date(date) do
    Calendar.strftime(date, "%d de %B, %Y")
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%d/%m/%Y %H:%M")
  end

  defp get_current_image(assigns, post_id) do
    Map.get(assigns.carousel_indices, post_id, 0)
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      if socket.assigns.current_scope do
        Posts.subscribe_posts(socket.assigns.current_scope)
      end

      Posts.subscribe_post_likes()
    end

    posts_with_stats = Posts.list_posts_with_stats(socket.assigns.current_scope)

    carousel_indices =
      Map.new(posts_with_stats, fn %{post: post} -> {post.id, 0} end)

    {:ok,
     socket
     |> assign(:page_title, "Publicaciones")
     |> assign(:carousel_indices, carousel_indices)
     |> assign(:expanded_comments, MapSet.new())
     |> assign(:comments_by_post, %{})
     |> assign(:comment_forms, %{})
     |> assign(:posts_empty?, posts_with_stats == [])
     |> stream(:posts, posts_with_stats)}
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/posts/#{id}/editar")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Posts.get_post!(socket.assigns.current_scope, id)
    {:ok, _} = Posts.delete_post(socket.assigns.current_scope, post)

    # Create a dummy post_data structure for stream_delete
    post_data = %{id: post.id, post: post}

    {:noreply, stream_delete(socket, :posts, post_data)}
  end

  @impl true
  def handle_event("toggle_like", %{"post-id" => post_id}, socket) do
    case socket.assigns.current_scope do
      nil ->
        {:noreply, put_flash(socket, :error, "Debes iniciar sesión para dar like")}

      scope ->
        post_id = String.to_integer(post_id)
        {:ok, _action} = Posts.toggle_like_post(scope, post_id)

        # Update only the specific post stats
        post_data = Posts.get_post_with_stats!(post_id, scope)

        {:noreply, stream_insert(socket, :posts, post_data)}
    end
  end

  @impl true
  def handle_event("toggle_comments", %{"post-id" => post_id}, socket) do
    post_id = String.to_integer(post_id)
    expanded = socket.assigns.expanded_comments

    socket =
      if MapSet.member?(expanded, post_id) do
        socket
        |> assign(:expanded_comments, MapSet.delete(expanded, post_id))
      else
        # Subscribe to comment updates for this post
        if connected?(socket) do
          Posts.subscribe_post_comentarios(post_id)
        end

        comments = Posts.list_comentarios_for_post(post_id)

        socket
        |> assign(:expanded_comments, MapSet.put(expanded, post_id))
        |> assign(:comments_by_post, Map.put(socket.assigns.comments_by_post, post_id, comments))
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("submit_comment", %{"contenido" => contenido, "post-id" => post_id}, socket) do
    post_id = String.to_integer(post_id)

    case socket.assigns.current_scope do
      nil ->
        {:noreply, put_flash(socket, :error, "Debes iniciar sesión para comentar")}

      scope ->
        case Posts.create_comentario_for_post(scope, post_id, %{"contenido" => contenido}) do
          {:ok, _comentario} ->
            # Refresh comments for this post
            comments = Posts.list_comentarios_for_post(post_id)

            # Update only the specific post stats
            post_data = Posts.get_post_with_stats!(post_id, scope)

            {:noreply,
             socket
             |> assign(:comments_by_post, Map.put(socket.assigns.comments_by_post, post_id, comments))
             |> stream_insert(:posts, post_data)}

          {:error, _changeset} ->
            {:noreply, put_flash(socket, :error, "Error al crear el comentario")}
        end
    end
  end

  @impl true
  def handle_event("delete_comment", %{"comment-id" => comment_id, "post-id" => post_id}, socket) do
    post_id = String.to_integer(post_id)
    comment_id = String.to_integer(comment_id)

    scope = socket.assigns.current_scope
    comentario = Posts.get_comentario!(scope, comment_id)

    case Posts.delete_comentario(scope, comentario) do
      {:ok, _} ->
        comments = Posts.list_comentarios_for_post(post_id)
        post_data = Posts.get_post_with_stats!(post_id, scope)

        {:noreply,
         socket
         |> assign(:comments_by_post, Map.put(socket.assigns.comments_by_post, post_id, comments))
         |> stream_insert(:posts, post_data)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Error al eliminar el comentario")}
    end
  end

  @impl true
  def handle_event("next_image", %{"post-id" => post_id}, socket) do
    post_id = String.to_integer(post_id)
    posts = Posts.list_posts()
    post = Enum.find(posts, &(&1.id == post_id))

    if post && post.imagenes_posts do
      current = Map.get(socket.assigns.carousel_indices, post_id, 0)
      total = length(post.imagenes_posts)
      new_index = rem(current + 1, total)

      {:noreply,
       assign(
         socket,
         :carousel_indices,
         Map.put(socket.assigns.carousel_indices, post_id, new_index)
       )}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("prev_image", %{"post-id" => post_id}, socket) do
    post_id = String.to_integer(post_id)
    posts = Posts.list_posts()
    post = Enum.find(posts, &(&1.id == post_id))

    if post && post.imagenes_posts do
      current = Map.get(socket.assigns.carousel_indices, post_id, 0)
      total = length(post.imagenes_posts)
      new_index = rem(current - 1 + total, total)

      {:noreply,
       assign(
         socket,
         :carousel_indices,
         Map.put(socket.assigns.carousel_indices, post_id, new_index)
       )}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({type, %Pets.Posts.Post{}}, socket)
      when type in [:created, :updated, :deleted] do
    posts_with_stats = Posts.list_posts_with_stats(socket.assigns.current_scope)
    carousel_indices = Map.new(posts_with_stats, fn %{post: post} -> {post.id, 0} end)

    {:noreply,
     socket
     |> assign(:carousel_indices, carousel_indices)
     |> assign(:posts_empty?, posts_with_stats == [])
     |> stream(:posts, posts_with_stats, reset: true)}
  end

  @impl true
  def handle_info({:post_liked, post_id, _usuario_id}, socket) do
    post_data = Posts.get_post_with_stats!(post_id, socket.assigns.current_scope)
    {:noreply, stream_insert(socket, :posts, post_data)}
  end

  @impl true
  def handle_info({:post_unliked, post_id, _usuario_id}, socket) do
    post_data = Posts.get_post_with_stats!(post_id, socket.assigns.current_scope)
    {:noreply, stream_insert(socket, :posts, post_data)}
  end

  @impl true
  def handle_info({:comentario_created, comentario}, socket) do
    post_id = comentario.post_id
    post_data = Posts.get_post_with_stats!(post_id, socket.assigns.current_scope)

    socket =
      if MapSet.member?(socket.assigns.expanded_comments, post_id) do
        comments = Posts.list_comentarios_for_post(post_id)
        assign(socket, :comments_by_post, Map.put(socket.assigns.comments_by_post, post_id, comments))
      else
        socket
      end

    {:noreply, stream_insert(socket, :posts, post_data)}
  end

  @impl true
  def handle_info({:comentario_deleted, comentario}, socket) do
    post_id = comentario.post_id
    post_data = Posts.get_post_with_stats!(post_id, socket.assigns.current_scope)

    socket =
      if MapSet.member?(socket.assigns.expanded_comments, post_id) do
        comments = Posts.list_comentarios_for_post(post_id)
        assign(socket, :comments_by_post, Map.put(socket.assigns.comments_by_post, post_id, comments))
      else
        socket
      end

    {:noreply, stream_insert(socket, :posts, post_data)}
  end
end
