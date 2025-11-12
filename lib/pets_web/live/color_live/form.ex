defmodule PetsWeb.ColorLive.Form do
  use PetsWeb, :live_view

  alias Pets.Mascotas
  alias Pets.Mascotas.Color

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage color records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="color-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:nombre]} type="text" label="Nombre" />
        <.input
          field={@form[:especie_id]}
          type="select"
          options={@especies}
          label="Seleccionar Especie"
        />
        <footer>
          <.button phx-disable-with="Guardando..." variant="primary">Guardar Color</.button>
          <.button navigate={return_path(@current_scope, @return_to, @color)}>Cancelar</.button>
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
    color = Mascotas.get_color!(socket.assigns.current_scope, id)

    especies_options =
      Mascotas.list_especies(socket.assigns.current_scope)
      |> Enum.map(fn especie -> {especie.nombre, especie.id} end)

    socket
    |> assign(:page_title, "Editar Color")
    |> assign(:color, color)
    |> assign(:especies, especies_options)
    |> assign(:form, to_form(Mascotas.change_color(socket.assigns.current_scope, color)))
  end

  defp apply_action(socket, :new, _params) do
    color = %Color{usuario_id: socket.assigns.current_scope.usuario.id}

    especies_options =
      Mascotas.list_especies(socket.assigns.current_scope)
      |> Enum.map(fn especie ->
        {
          especie.nombre,
          especie.id
        }
      end)

    socket
    |> assign(:page_title, "Nuevo Color")
    |> assign(:color, color)
    |> assign(:especies, especies_options)
    |> assign(
      :form,
      to_form(Mascotas.change_color(socket.assigns.current_scope, color))
    )
  end

  @impl true
  def handle_event("validate", %{"color" => color_params}, socket) do
    changeset =
      Mascotas.change_color(socket.assigns.current_scope, socket.assigns.color, color_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"color" => color_params}, socket) do
    save_color(socket, socket.assigns.live_action, color_params)
  end

  defp save_color(socket, :edit, color_params) do
    case Mascotas.update_color(socket.assigns.current_scope, socket.assigns.color, color_params) do
      {:ok, color} ->
        {:noreply,
         socket
         |> put_flash(:info, "Color updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, color)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_color(socket, :new, color_params) do
    case Mascotas.create_color(socket.assigns.current_scope, color_params) do
      {:ok, color} ->
        {:noreply,
         socket
         |> put_flash(:info, "Color created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, color)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _color), do: ~p"/admin/colores"
  defp return_path(_scope, "show", color), do: ~p"/admin/colores/#{color}"
end
