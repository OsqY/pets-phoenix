defmodule PetsWeb.MascotaLive.Form do
  alias Phoenix.Router.Route
  use PetsWeb, :live_view

  alias Pets.Mascotas
  alias Pets.Mascotas.Mascota

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Formulario de Registro de Mascotas</:subtitle>
      </.header>

      <.form for={@form} id="mascota-form" phx-change="validate" phx-submit="save">
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
        <footer>
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
     |> assign(estados_options: Mascota.estados_options())
     |> assign(energia_options: Mascota.energia_options())
     |> apply_action(socket.assigns.live_action, params)}
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
    mascota = %Mascota{usuario_id: socket.assigns.current_scope.usuario.id}

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
  def handle_event("validate", %{"mascota" => mascota_params}, socket) do
    changeset =
      Mascotas.change_mascota(
        socket.assigns.current_scope,
        socket.assigns.mascota,
        mascota_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"mascota" => mascota_params}, socket) do
    save_mascota(socket, socket.assigns.live_action, mascota_params)
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
end
