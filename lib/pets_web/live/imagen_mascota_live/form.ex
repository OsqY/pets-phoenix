defmodule PetsWeb.ImagenMascotaLive.Form do
  use PetsWeb, :live_view

  alias Pets.Mascotas
  alias Pets.Mascotas.ImagenMascota

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Utiliza este formulario para gestionar las imágenes de mascotas.</:subtitle>
      </.header>

      <.form for={@form} id="imagen_mascota-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:url]} type="text" label="Url" />
        <.input field={@form[:mascota_id]} type="number" label="Mascota" />
        <footer>
          <.button phx-disable-with="Guardando..." variant="primary">Guardar Imagen</.button>
          <.button navigate={return_path(@current_scope, @return_to, @imagen_mascota)}>
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
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    imagen_mascota = Mascotas.get_imagen_mascota!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Editar Imagen de Mascota")
    |> assign(:imagen_mascota, imagen_mascota)
    |> assign(
      :form,
      to_form(Mascotas.change_imagen_mascota(socket.assigns.current_scope, imagen_mascota))
    )
  end

  defp apply_action(socket, :new, _params) do
    imagen_mascota = %ImagenMascota{}

    socket
    |> assign(:page_title, "Nueva Imagen de Mascota")
    |> assign(:imagen_mascota, imagen_mascota)
    |> assign(
      :form,
      to_form(Mascotas.change_imagen_mascota(socket.assigns.current_scope, imagen_mascota))
    )
  end

  @impl true
  def handle_event("validate", %{"imagen_mascota" => imagen_mascota_params}, socket) do
    changeset =
      Mascotas.change_imagen_mascota(
        socket.assigns.current_scope,
        socket.assigns.imagen_mascota,
        imagen_mascota_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"imagen_mascota" => imagen_mascota_params}, socket) do
    save_imagen_mascota(socket, socket.assigns.live_action, imagen_mascota_params)
  end

  defp save_imagen_mascota(socket, :edit, imagen_mascota_params) do
    case Mascotas.update_imagen_mascota(
           socket.assigns.current_scope,
           socket.assigns.imagen_mascota,
           imagen_mascota_params
         ) do
      {:ok, imagen_mascota} ->
        {:noreply,
         socket
         |> put_flash(:info, "Imagen de mascota actualizada correctamente")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, imagen_mascota)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_imagen_mascota(socket, :new, imagen_mascota_params) do
    case Mascotas.create_imagen_mascota(socket.assigns.current_scope, imagen_mascota_params) do
      {:ok, imagen_mascota} ->
        {:noreply,
         socket
         |> put_flash(:info, "Imagen de mascota creada correctamente")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, imagen_mascota)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _imagen_mascota), do: ~p"/imagenes_mascotas"
  defp return_path(_scope, "show", imagen_mascota), do: ~p"/imagenes_mascotas/#{imagen_mascota}"
end
