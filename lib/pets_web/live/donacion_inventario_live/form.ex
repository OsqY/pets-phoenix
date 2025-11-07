defmodule PetsWeb.DonacionInventarioLive.Form do
  use PetsWeb, :live_view

  alias Pets.Refugios
  alias Pets.Refugios.DonacionInventario

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>
          Formulario para registrar donaciones generales (comida, medicamentos, utilería).
        </:subtitle>
      </.header>

      <.form for={@form} id="donacion_inventario-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:cantidad]} type="number" label="Cantidad" step="any" />
        <.input field={@form[:descripcion]} type="text" label="Descripcion" />
        <.input field={@form[:fecha]} type="date" label="Fecha" />
        <.input
          field={@form[:donantes]}
          type="select"
          multiple
          label="Donantes"
          options={[{"Option 1", "option1"}, {"Option 2", "option2"}]}
        />
        <.input
          field={@form[:medida]}
          type="select"
          label="Medida"
          prompt="Choose a value"
          options={Ecto.Enum.values(Pets.Refugios.DonacionInventario, :medida)}
        />
        <.input
          field={@form[:tipo]}
          type="select"
          label="Tipo"
          prompt="Elija un tipo de objeto a donar"
          options={Ecto.Enum.values(Pets.Refugios.DonacionInventario, :tipo)}
        />
        <footer>
          <.button phx-disable-with="Guardando..." variant="primary">Guardar</.button>
          <.button navigate={return_path(@current_scope, @return_to, @donacion_inventario)}>
            Cancel
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
    donacion_inventario = Refugios.get_donacion_inventario!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Donacion inventario")
    |> assign(:donacion_inventario, donacion_inventario)
    |> assign(
      :form,
      to_form(
        Refugios.change_donacion_inventario(socket.assigns.current_scope, donacion_inventario)
      )
    )
  end

  defp apply_action(socket, :new, _params) do
    donacion_inventario = %DonacionInventario{refugio_id: socket.assigns.current_scope.usuario.id}

    socket
    |> assign(:page_title, "New Donacion inventario")
    |> assign(:donacion_inventario, donacion_inventario)
    |> assign(
      :form,
      to_form(
        Refugios.change_donacion_inventario(socket.assigns.current_scope, donacion_inventario)
      )
    )
  end

  @impl true
  def handle_event("validate", %{"donacion_inventario" => donacion_inventario_params}, socket) do
    changeset =
      Refugios.change_donacion_inventario(
        socket.assigns.current_scope,
        socket.assigns.donacion_inventario,
        donacion_inventario_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"donacion_inventario" => donacion_inventario_params}, socket) do
    save_donacion_inventario(socket, socket.assigns.live_action, donacion_inventario_params)
  end

  defp save_donacion_inventario(socket, :edit, donacion_inventario_params) do
    case Refugios.update_donacion_inventario(
           socket.assigns.current_scope,
           socket.assigns.donacion_inventario,
           donacion_inventario_params
         ) do
      {:ok, donacion_inventario} ->
        {:noreply,
         socket
         |> put_flash(:info, "Donación actualizada con éxito.")
         |> push_navigate(
           to:
             return_path(
               socket.assigns.current_scope,
               socket.assigns.return_to,
               donacion_inventario
             )
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_donacion_inventario(socket, :new, donacion_inventario_params) do
    case Refugios.create_donacion_inventario(
           socket.assigns.current_scope,
           donacion_inventario_params
         ) do
      {:ok, donacion_inventario} ->
        {:noreply,
         socket
         |> put_flash(:info, "Donación creada con éxito.")
         |> push_navigate(
           to:
             return_path(
               socket.assigns.current_scope,
               socket.assigns.return_to,
               donacion_inventario
             )
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _donacion_inventario), do: ~p"/refugio/donacion-inventario"

  defp return_path(_scope, "show", donacion_inventario),
    do: ~p"/refugio/donacion-inventario/#{donacion_inventario}"
end
