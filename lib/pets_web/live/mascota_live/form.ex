defmodule PetsWeb.MascotaLive.Form do
  alias Phoenix.Router.Route
  use PetsWeb, :live_view

  alias Pets.Mascotas
  alias Pets.Mascotas.Mascota
  alias Pets.SimpleS3Upload

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Formulario de Registro de Mascotas</:subtitle>
      </.header>

      <.form for={@form} id="mascota-form" phx-change="validate" phx-submit="save" multipart>
        <.input field={@form[:nombre]} type="text" label="Nombre" />
        <.input field={@form[:descripcion]} type="textarea" label="Descripcion" />
        <.input field={@form[:edad]} type="number" label="Edad" />
        <.input field={@form[:sexo]} type="text" label="Sexo" />
        <.input field={@form[:tamanio]} type="text" label="Tamanio" />
        <.input field={@form[:peso]} type="number" label="Peso" step="any" />
        <.input field={@form[:color_id]} type="select" options={@colores} label="Color" />
        <.input
          field={@form[:energia]}
          type="select"
          label="Nivel de energía"
          options={@energia_options}
        />
        <.input
          field={@form[:sociable_mascotas]}
          type="checkbox"
          label="¿Es sociable con otras mascotas?"
        />
        <.input
          field={@form[:sociable_personas]}
          type="checkbox"
          label="¿Es sociable con otras personas?"
        />
        <.input
          field={@form[:necesidades_especiales]}
          type="textarea"
          label="Necesidades especiales"
        />
        <.input
          field={@form[:historia]}
          type="textarea"
          label="Historia"
        />
        <.input
          field={@form[:estado]}
          type="select"
          label="Estado"
          options={@estados_options}
        />
        <.input field={@form[:especie_id]} type="select" options={@especies} label="Especie" />
        <.input field={@form[:raza_id]} type="select" options={@razas} label="Raza" />

        <div class="mt-2 pt-2">
          <h3 class="text-lg font-semibold ">Imágenes de la Mascota</h3>
          <p class="text-sm mb-4">Añade una o más imágenes.</p>

          <div class="space-y-2 mb-4">
            <%= for imagen <- @mascota.imagenes do %>
              <div class="flex items-center gap-2 p-2 border rounded">
                <img src={imagen.url} class="w-16 h-16 object-cover rounded" alt="Imagen guardada" />
                <span class="text-sm text-gray-600">{List.last(String.split(imagen.url, "/"))}</span>
              </div>
            <% end %>

            <%= for entry <- @uploads.imagenes.entries do %>
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
            <div phx-drop-target={@uploads.imagenes.ref}>
              <.live_file_input
                upload={@uploads.imagenes}
                class="block w-full text-sm text-gray-900 border border-gray-300 rounded-lg cursor-pointer bg-gray-50 dark:text-gray-400 focus:outline-none dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 p-4"
              />
            </div>

            <p :for={err <- upload_errors(@uploads.imagenes)} class="mt-1.5 text-sm text-error">
              <span class="font-semibold">{error_to_string(err)}</span>
            </p>
          </div>
        </div>

        <footer class="my-4">
          <.button phx-disable-with="Agregando..." variant="primary">Registrar Mascota</.button>
          <.button navigate={return_path(@current_scope, @return_to, @mascota)}>Cancelar</.button>
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
     |> assign(estados_options: Mascota.estado_options())
     |> assign(energia_options: Mascota.energia_options())
     |> allow_upload(:imagenes,
       accept: ~w(.jpg .jpeg .png .gif .webp),
       max_entries: 5,
       auto_upload: true,
       max_file_size: 10_000_000,
       external: &presign_entry/2
     )
     |> apply_action(socket.assigns.live_action, params)}
  end

  # Esta función genera la URL firmada para S3
  defp presign_entry(entry, socket) do
    uploads = socket.assigns.uploads
    {:ok, SimpleS3Upload.meta(entry, uploads), socket}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    case mascota = Mascotas.get_mascota(socket.assigns.current_scope, id) do
      mascota when not is_nil(mascota) ->
        colores =
          Mascotas.list_colores(socket.assigns.current_scope)
          |> Enum.map(fn color -> {color.nombre, color.id} end)

        especies =
          Mascotas.list_especies(socket.assigns.current_scope)
          |> Enum.map(fn especie -> {especie.nombre, especie.id} end)

        razas =
          Mascotas.list_razas(socket.assigns.current_scope)
          |> Enum.map(fn raza -> {raza.nombre, raza.id} end)

        socket
        |> assign(:page_title, "Editar Mascota")
        |> assign(:mascota, mascota)
        |> assign(:colores, colores)
        |> assign(:razas, razas)
        |> assign(:especies, especies)
        |> assign(:form, to_form(Mascotas.change_mascota(socket.assigns.current_scope, mascota)))

      nil ->
        mascota = Mascotas.get_mascota(id)

        if mascota == nil do
          socket
          |> put_flash(:error, "Mascota no encontrada.")
          |> redirect(to: "/mascotas")
        else
          socket
          |> put_flash(:error, "No tiene permisos para editar la mascota.")
          |> redirect(to: "/mascotas/#{id}")
        end
    end
  end

  defp apply_action(socket, :new, _params) do
    mascota = %Mascota{usuario_id: socket.assigns.current_scope.usuario.id, imagenes: []}

    colores =
      Mascotas.list_colores(socket.assigns.current_scope)
      |> Enum.map(fn color -> {color.nombre, color.id} end)

    especies =
      Mascotas.list_especies(socket.assigns.current_scope)
      |> Enum.map(fn especie -> {especie.nombre, especie.id} end)

    razas =
      Mascotas.list_razas(socket.assigns.current_scope)
      |> Enum.map(fn raza -> {raza.nombre, raza.id} end)

    socket
    |> assign(:page_title, "Nueva Mascota")
    |> assign(:mascota, mascota)
    |> assign(:colores, colores)
    |> assign(:especies, especies)
    |> assign(:razas, razas)
    |> assign(:form, to_form(Mascotas.change_mascota(socket.assigns.current_scope, mascota)))
  end

  @impl true
  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, socket |> cancel_upload(:imagenes, ref)}
  end

  @impl true
  def handle_event("validate", %{"mascota" => mascota_params}, socket) do
    changeset =
      Mascotas.change_mascota(
        socket.assigns.current_scope,
        socket.assigns.mascota,
        mascota_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"mascota" => mascota_params}, socket) do
    mascota_params = put_photo_urls(socket, mascota_params)

    save_mascota(socket, socket.assigns.live_action, mascota_params)
  end

  defp put_photo_urls(socket, mascota_params) do
    uploaded_file_urls =
      consume_uploaded_entries(socket, :imagenes, fn _meta, entry ->
        {:ok, Pets.SimpleS3Upload.entry_url(entry)}
      end)

    imagenes_existentes =
      socket.assigns.mascota.imagenes
      |> Enum.map(fn img -> %{"url" => img.url} end)

    imagenes_nuevas =
      Enum.map(uploaded_file_urls, fn url -> %{"url" => url} end)

    todas_las_imagenes = imagenes_existentes ++ imagenes_nuevas

    Map.put(mascota_params, "imagenes", todas_las_imagenes)
  end

  defp save_mascota(socket, :edit, mascota_params) do
    case Mascotas.update_mascota(
           socket.assigns.current_scope,
           socket.assigns.mascota,
           mascota_params
         ) do
      {:ok, mascota} ->
        {:noreply,
         socket
         |> put_flash(:info, "Información de mascota actualizada con éxito")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, mascota)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_mascota(socket, :new, mascota_params) do
    case Mascotas.create_mascota(socket.assigns.current_scope, mascota_params) do
      {:ok, mascota} ->
        {:noreply,
         socket
         |> put_flash(:info, "Mascota agregada")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, mascota)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _mascota), do: ~p"/mascotas"
  defp return_path(_scope, "show", mascota), do: ~p"/mascotas/#{mascota}"

  defp error_to_string(:too_large), do: "Archivo demasiado grande."
  defp error_to_string(:too_many_files), do: "Has seleccionado demasiados archivos."

  defp error_to_string(:not_accepted),
    do: "El tipo de archivo no es aceptado (solo .jpg, .jpeg, .png, .webp, .gif)."

  defp error_to_string(err) when is_atom(err), do: Atom.to_string(err)
end
