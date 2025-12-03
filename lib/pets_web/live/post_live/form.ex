defmodule PetsWeb.PostLive.Form do
  use PetsWeb, :live_view

  alias Pets.Mascotas
  alias Pets.Posts
  alias Pets.Posts.Post
  alias Pets.SimpleS3Upload

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Crea tu publicación</:subtitle>
      </.header>

      <.form for={@form} id="post-form" phx-change="validate" phx-submit="save" multipart>
        <.input field={@form[:content]} type="textarea" label="Contenido" />
        <.input field={@form[:fecha]} type="date" label="Fecha" />
        <.input field={@form[:mascota_id]} type="select" options={@mascotas} label="Mascota" />

        <div class="mt-2 pt-2">
          <h3 class="text-lg font-semibold">Imágenes de la Publicación</h3>
          <p class="text-sm mb-4">Añade una o más imágenes.</p>

          <div class="space-y-2 mb-4">
            <%= for imagen <- @post.imagenes_posts || [] do %>
              <div class="flex items-center gap-2 p-2 border rounded">
                <img src={imagen.url} class="w-16 h-16 object-cover rounded" alt="Imagen guardada" />
                <span class="text-sm text-gray-600">{List.last(String.split(imagen.url, "/"))}</span>
              </div>
            <% end %>

            <%= for entry <- @uploads.imagenes_posts.entries do %>
              <div class="flex items-center gap-2 p-2 border rounded">
                <.live_img_preview entry={entry} class="w-16 h-16 object-cover rounded" />
                <div class="flex-grow">
                  <span class="text-sm text-gray-800">{entry.client_name}</span>
                  <progress value={entry.progress} max="100" class="w-full">
                    {entry.progress}%
                  </progress>
                </div>
                <.button
                  type="button"
                  phx-click="cancel_upload"
                  phx-value-ref={entry.ref}
                  size="sm"
                >
                  Cancelar
                </.button>
              </div>
            <% end %>
          </div>

          <div class="space-y-2">
            <div phx-drop-target={@uploads.imagenes_posts.ref}>
              <.live_file_input
                upload={@uploads.imagenes_posts}
                class="block w-full text-sm text-gray-900 border border-gray-300 rounded-lg cursor-pointer bg-gray-50 dark:text-gray-400 focus:outline-none dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 p-4"
              />
            </div>

            <p :for={err <- upload_errors(@uploads.imagenes_posts)} class="mt-1.5 text-sm text-error">
              <span class="font-semibold">{error_to_string(err)}</span>
            </p>
          </div>
        </div>

        <footer class="mt-8 flex items-center gap-2">
          <.button phx-disable-with="Guardando..." variant="primary">
            {if @live_action == :new, do: "Publicar", else: "Guardar Cambios"}
          </.button>
          <.button navigate={return_path(@current_scope, @return_to, @post)} >
            Cancelar
          </.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> allow_upload(:imagenes_posts,
       accept: ~w(.jpg .jpeg .png .gif .webp),
       max_entries: 5,
       auto_upload: true,
       max_file_size: 10_000_000,
       external: &presign_entry/2
     )
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp presign_entry(entry, socket) do
    uploads = socket.assigns.uploads
    {:ok, SimpleS3Upload.meta(entry, uploads), socket}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    post = Posts.get_post!(socket.assigns.current_scope, id)
    post = %{post | imagenes_posts: post.imagenes_posts || []}
    mascotas = Mascotas.list_mascotas_for_dropdown(socket.assigns.current_scope)

    socket
    |> assign(:page_title, "Editar Publicación")
    |> assign(:post, post)
    |> assign(:mascotas, mascotas)
    |> assign(:form, to_form(Posts.change_post(socket.assigns.current_scope, post)))
  end

  defp apply_action(socket, :new, _params) do
    post = %Post{usuario_id: socket.assigns.current_scope.usuario.id, imagenes_posts: []}
    mascotas = Mascotas.list_mascotas_for_dropdown(socket.assigns.current_scope)

    socket
    |> assign(:page_title, "Nueva Publicación")
    |> assign(:post, post)
    |> assign(:mascotas, mascotas)
    |> assign(:form, to_form(Posts.change_post(socket.assigns.current_scope, post)))
  end

  @impl true
  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, socket |> cancel_upload(:imagenes_posts, ref)}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset =
      Posts.change_post(socket.assigns.current_scope, socket.assigns.post, post_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"post" => post_params}, socket) do
    post_params = put_photo_urls(socket, post_params)
    save_post(socket, socket.assigns.live_action, post_params)
  end

  defp put_photo_urls(socket, post_params) do
    uploaded_file_urls =
      consume_uploaded_entries(socket, :imagenes_posts, fn _meta, entry ->
        {:ok, SimpleS3Upload.entry_url(entry)}
      end)

    imagenes_existentes =
      (socket.assigns.post.imagenes_posts || [])
      |> Enum.map(fn img -> %{"url" => img.url} end)

    imagenes_nuevas =
      Enum.map(uploaded_file_urls, fn url -> %{"url" => url} end)

    todas_las_imagenes = imagenes_existentes ++ imagenes_nuevas

    Map.put(post_params, "imagenes_posts", todas_las_imagenes)
  end

  defp save_post(socket, :edit, post_params) do
    case Posts.update_post(socket.assigns.current_scope, socket.assigns.post, post_params) do
      {:ok, post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Publicación actualizada exitosamente")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, post)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_post(socket, :new, post_params) do
    case Posts.create_post(socket.assigns.current_scope, post_params) do
      {:ok, post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Publicación creada exitosamente")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, post)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _post), do: ~p"/posts"
  defp return_path(_scope, "show", post), do: ~p"/posts/#{post}"

  defp error_to_string(:too_large), do: "Archivo demasiado grande."
  defp error_to_string(:too_many_files), do: "Has seleccionado demasiados archivos."

  defp error_to_string(:not_accepted),
    do: "El tipo de archivo no es aceptado (solo .jpg, .jpeg, .png, .webp, .gif)."

  defp error_to_string(err) when is_atom(err), do: Atom.to_string(err)
end
