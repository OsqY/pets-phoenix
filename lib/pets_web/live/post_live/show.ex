defmodule PetsWeb.PostLive.Show do
  use PetsWeb, :live_view

  alias Pets.Posts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-2xl mx-auto px-4 py-6">
        <div class="mb-4">
          <.button navigate={~p"/posts"}>
            <.icon name="hero-arrow-left" class="w-4 h-4 mr-1" /> Volver
          </.button>
        </div>

        <article class="bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-800 rounded-xl shadow-sm overflow-hidden">
          <div class="flex items-center justify-between p-4 border-b border-gray-100 dark:border-gray-800">
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 bg-indigo-100 dark:bg-indigo-900/50 rounded-full flex items-center justify-center ring-2 ring-white dark:ring-gray-900">
                <span class="text-sm font-bold text-indigo-600 dark:text-indigo-300">
                  {String.first(@post_data.post.usuario.email) |> String.upcase()}
                </span>
              </div>
              <div class="leading-tight">
                <p class="text-sm font-semibold text-gray-900 dark:text-gray-100">
                  {@post_data.post.usuario.email}
                </p>
                <p class="text-xs text-gray-500 dark:text-gray-400">
                  {format_date(@post_data.post.fecha)}
                </p>
              </div>
            </div>
            <%= if @current_scope && @current_scope.usuario.id == @post_data.post.usuario_id do %>
              <div class="flex gap-1">
                <.button variant="primary" navigate={~p"/posts/#{@post_data.post}/editar?return_to=show"}>
                  <.icon name="hero-pencil-square" class="w-4 h-4" /> Editar
                </.button>
              </div>
            <% end %>
          </div>

          <%= if @post_data.post.imagenes_posts && length(@post_data.post.imagenes_posts) > 0 do %>
            <div class="relative bg-gray-50 dark:bg-black aspect-square group">
              <%= for {imagen, index} <- Enum.with_index(@post_data.post.imagenes_posts) do %>
                <div class={[
                  "absolute inset-0 transition-opacity duration-300",
                  if(index == @current_image, do: "opacity-100 z-10", else: "opacity-0 z-0")
                ]}>
                  <img
                    src={imagen.url || "/placeholder.svg"}
                    alt="Post image"
                    class="w-full h-full object-cover"
                  />
                </div>
              <% end %>

              <%= if length(@post_data.post.imagenes_posts) > 1 do %>
                <button
                  type="button"
                  phx-click="prev_image"
                  class="absolute left-3 top-1/2 -translate-y-1/2 z-20 bg-white/90 dark:bg-black/60 hover:bg-white text-gray-800 dark:text-white p-2 rounded-full shadow-sm opacity-0 group-hover:opacity-100 transition-all"
                >
                  <.icon name="hero-chevron-left" class="w-5 h-5" />
                </button>
                <button
                  type="button"
                  phx-click="next_image"
                  class="absolute right-3 top-1/2 -translate-y-1/2 z-20 bg-white/90 dark:bg-black/60 hover:bg-white text-gray-800 dark:text-white p-2 rounded-full shadow-sm opacity-0 group-hover:opacity-100 transition-all"
                >
                  <.icon name="hero-chevron-right" class="w-5 h-5" />
                </button>
                <div class="absolute bottom-3 left-1/2 -translate-x-1/2 flex gap-1.5 z-20 px-2 py-1 rounded-full bg-black/20 backdrop-blur-sm">
                  <%= for index <- 0..(length(@post_data.post.imagenes_posts) - 1) do %>
                    <div class={[
                      "w-2 h-2 rounded-full transition-colors",
                      if(index == @current_image, do: "bg-white", else: "bg-white/40")
                    ]}>
                    </div>
                  <% end %>
                </div>
              <% end %>
            </div>
          <% end %>

          <div class="px-4 pt-4 pb-2 flex items-center gap-4">
            <button
              type="button"
              phx-click="toggle_like"
              class={[
                "flex items-center gap-2 transition-colors group",
                if(@post_data.user_liked, do: "text-red-500", else: "text-gray-500 hover:text-red-500")
              ]}
              disabled={is_nil(@current_scope)}
              title={if @current_scope, do: "Me gusta", else: "Inicia sesión para dar like"}
            >
              <.icon
                name={if @post_data.user_liked, do: "hero-heart-solid", else: "hero-heart"}
                class="w-7 h-7 transition-transform group-hover:scale-110"
              />
              <span class="text-base font-medium">{@post_data.likes_count}</span>
            </button>

            <div class="flex items-center gap-2 text-gray-500">
              <.icon name="hero-chat-bubble-oval-left" class="w-7 h-7" />
              <span class="text-base font-medium">{@post_data.comentarios_count}</span>
            </div>
          </div>

          <div class="px-5 pb-4">
            <%= if @post_data.post.mascota do %>
              <div class="flex items-center mb-3">
                <div class="inline-flex items-center px-3 py-1 rounded-md text-sm font-medium bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300">
                  <span class="font-bold mr-1">{@post_data.post.mascota.nombre}</span>
                  <span class="text-slate-400 dark:text-slate-500 mx-1">•</span>
                  <span>{@post_data.post.mascota.especie.nombre}</span>
                </div>
              </div>
            <% end %>

            <div class="prose dark:prose-invert max-w-none">
              <p class="text-gray-700 dark:text-gray-300 whitespace-pre-wrap leading-relaxed">
                {@post_data.post.content}
              </p>
            </div>
          </div>

          <div class="border-t border-gray-100 dark:border-gray-800 px-4 py-4 bg-gray-50/50 dark:bg-gray-800/30">
            <h3 class="text-sm font-semibold text-gray-900 dark:text-gray-100 mb-4">
              Comentarios ({@post_data.comentarios_count})
            </h3>

            <%= if @current_scope do %>
              <.form
                for={@comment_form}
                id="comment-form"
                phx-submit="submit_comment"
                class="flex gap-3 mb-6"
              >
                <div class="w-10 h-10 bg-indigo-100 dark:bg-indigo-900/50 rounded-full flex items-center justify-center flex-shrink-0">
                  <span class="text-sm font-bold text-indigo-600 dark:text-indigo-300">
                    {String.first(@current_scope.usuario.email) |> String.upcase()}
                  </span>
                </div>
                <div class="flex-1 flex gap-2">
                  <input
                    type="text"
                    name="contenido"
                    placeholder="Escribe un comentario..."
                    class="flex-1 text-sm border border-gray-200 dark:border-gray-700 rounded-full px-4 py-2.5 bg-white dark:bg-gray-900 focus:outline-none focus:ring-2 focus:ring-indigo-500 dark:focus:ring-indigo-400"
                    autocomplete="off"
                  />
                  <button
                    type="submit"
                    class="px-5 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-medium rounded-full transition-colors"
                  >
                    Enviar
                  </button>
                </div>
              </.form>
            <% else %>
              <div class="text-center py-4 mb-6 bg-gray-100 dark:bg-gray-800 rounded-lg">
                <p class="text-sm text-gray-500 dark:text-gray-400">
                  <.link navigate={~p"/usuario/iniciar-sesion"} class="text-indigo-600 dark:text-indigo-400 hover:underline">
                    Inicia sesión
                  </.link>
                  para comentar
                </p>
              </div>
            <% end %>

            <div class="space-y-4" id="comments-list">
              <%= if @comments == [] do %>
                <p class="text-sm text-gray-500 dark:text-gray-400 text-center py-4">
                  No hay comentarios aún. ¡Sé el primero!
                </p>
              <% else %>
                <%= for comentario <- @comments do %>
                  <div class="flex gap-3" id={"comentario-#{comentario.id}"}>
                    <div class="w-10 h-10 bg-gray-200 dark:bg-gray-700 rounded-full flex items-center justify-center flex-shrink-0">
                      <span class="text-sm font-bold text-gray-600 dark:text-gray-300">
                        {String.first(comentario.usuario.email) |> String.upcase()}
                      </span>
                    </div>
                    <div class="flex-1">
                      <div class="bg-white dark:bg-gray-800 rounded-xl px-4 py-3 shadow-sm">
                        <p class="text-sm font-semibold text-gray-900 dark:text-gray-100">
                          {comentario.usuario.email}
                        </p>
                        <p class="text-sm text-gray-700 dark:text-gray-300 mt-1">
                          {comentario.contenido}
                        </p>
                      </div>
                      <div class="flex items-center gap-4 mt-1.5 px-2">
                        <span class="text-xs text-gray-400">
                          {format_datetime(comentario.inserted_at)}
                        </span>
                        <%= if @current_scope && @current_scope.usuario.id == comentario.usuario_id do %>
                          <button
                            type="button"
                            phx-click="delete_comment"
                            phx-value-comment-id={comentario.id}
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
        </article>
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

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    post_id = String.to_integer(id)

    if connected?(socket) do
      if socket.assigns.current_scope do
        Posts.subscribe_posts(socket.assigns.current_scope)
      end

      Posts.subscribe_post_likes()
      Posts.subscribe_post_comentarios(post_id)
    end

    post_data = Posts.get_post_with_stats!(post_id, socket.assigns.current_scope)
    comments = Posts.list_comentarios_for_post(post_id)

    {:ok,
     socket
     |> assign(:page_title, "Post")
     |> assign(:post_data, post_data)
     |> assign(:comments, comments)
     |> assign(:current_image, 0)
     |> assign(:comment_form, to_form(%{"contenido" => ""}))}
  end

  @impl true
  def handle_event("toggle_like", _params, socket) do
    case socket.assigns.current_scope do
      nil ->
        {:noreply, put_flash(socket, :error, "Debes iniciar sesión para dar like")}

      scope ->
        post_id = socket.assigns.post_data.post.id
        {:ok, _action} = Posts.toggle_like_post(scope, post_id)

        post_data = Posts.get_post_with_stats!(post_id, scope)
        {:noreply, assign(socket, :post_data, post_data)}
    end
  end

  @impl true
  def handle_event("submit_comment", %{"contenido" => contenido}, socket) do
    case socket.assigns.current_scope do
      nil ->
        {:noreply, put_flash(socket, :error, "Debes iniciar sesión para comentar")}

      scope ->
        post_id = socket.assigns.post_data.post.id

        case Posts.create_comentario_for_post(scope, post_id, %{"contenido" => contenido}) do
          {:ok, _comentario} ->
            comments = Posts.list_comentarios_for_post(post_id)
            post_data = Posts.get_post_with_stats!(post_id, scope)

            {:noreply,
             socket
             |> assign(:comments, comments)
             |> assign(:post_data, post_data)
             |> assign(:comment_form, to_form(%{"contenido" => ""}))}

          {:error, _changeset} ->
            {:noreply, put_flash(socket, :error, "Error al crear el comentario")}
        end
    end
  end

  @impl true
  def handle_event("delete_comment", %{"comment-id" => comment_id}, socket) do
    comment_id = String.to_integer(comment_id)
    scope = socket.assigns.current_scope
    post_id = socket.assigns.post_data.post.id

    comentario = Posts.get_comentario!(scope, comment_id)

    case Posts.delete_comentario(scope, comentario) do
      {:ok, _} ->
        comments = Posts.list_comentarios_for_post(post_id)
        post_data = Posts.get_post_with_stats!(post_id, scope)

        {:noreply,
         socket
         |> assign(:comments, comments)
         |> assign(:post_data, post_data)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Error al eliminar el comentario")}
    end
  end

  @impl true
  def handle_event("next_image", _params, socket) do
    post = socket.assigns.post_data.post

    if post.imagenes_posts && length(post.imagenes_posts) > 0 do
      current = socket.assigns.current_image
      total = length(post.imagenes_posts)
      new_index = rem(current + 1, total)
      {:noreply, assign(socket, :current_image, new_index)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("prev_image", _params, socket) do
    post = socket.assigns.post_data.post

    if post.imagenes_posts && length(post.imagenes_posts) > 0 do
      current = socket.assigns.current_image
      total = length(post.imagenes_posts)
      new_index = rem(current - 1 + total, total)
      {:noreply, assign(socket, :current_image, new_index)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:updated, %Pets.Posts.Post{id: id} = _post}, socket) do
    if socket.assigns.post_data.post.id == id do
      post_data = Posts.get_post_with_stats!(id, socket.assigns.current_scope)
      {:noreply, assign(socket, :post_data, post_data)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:deleted, %Pets.Posts.Post{id: id}}, socket) do
    if socket.assigns.post_data.post.id == id do
      {:noreply,
       socket
       |> put_flash(:error, "El post fue eliminado.")
       |> push_navigate(to: ~p"/posts")}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:created, %Pets.Posts.Post{}}, socket), do: {:noreply, socket}

  @impl true
  def handle_info({:post_liked, post_id, _usuario_id}, socket) do
    if socket.assigns.post_data.post.id == post_id do
      post_data = Posts.get_post_with_stats!(post_id, socket.assigns.current_scope)
      {:noreply, assign(socket, :post_data, post_data)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:post_unliked, post_id, _usuario_id}, socket) do
    if socket.assigns.post_data.post.id == post_id do
      post_data = Posts.get_post_with_stats!(post_id, socket.assigns.current_scope)
      {:noreply, assign(socket, :post_data, post_data)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:comentario_created, comentario}, socket) do
    if comentario.post_id == socket.assigns.post_data.post.id do
      post_id = socket.assigns.post_data.post.id
      comments = Posts.list_comentarios_for_post(post_id)
      post_data = Posts.get_post_with_stats!(post_id, socket.assigns.current_scope)

      {:noreply,
       socket
       |> assign(:comments, comments)
       |> assign(:post_data, post_data)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:comentario_deleted, comentario}, socket) do
    if comentario.post_id == socket.assigns.post_data.post.id do
      post_id = socket.assigns.post_data.post.id
      comments = Posts.list_comentarios_for_post(post_id)
      post_data = Posts.get_post_with_stats!(post_id, socket.assigns.current_scope)

      {:noreply,
       socket
       |> assign(:comments, comments)
       |> assign(:post_data, post_data)}
    else
      {:noreply, socket}
    end
  end
end
