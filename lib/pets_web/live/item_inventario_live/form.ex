defmodule PetsWeb.ItemInventarioLive.Form do
  use PetsWeb, :live_view

  alias Pets.Refugios
  alias Pets.Refugios.ItemInventario

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Formulario para Inventario</:subtitle>
      </.header>

      <.form for={@form} id="item_inventario-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:nombre]} type="text" label="Nombre" />
        <.input field={@form[:descripcion]} type="textarea" label="Descripcion" />
        <.input field={@form[:cantidad]} type="number" label="Cantidad" step="any" />
        <.input
          field={@form[:medida]}
          type="select"
          label="Medida"
          prompt="Elija una medida"
          options={Ecto.Enum.values(Pets.Refugios.ItemInventario, :medida)}
        />
        <.input
          field={@form[:tipo]}
          type="select"
          label="Tipo"
          prompt="Elija un tipo"
          options={Ecto.Enum.values(Pets.Refugios.ItemInventario, :tipo)}
        />
        <footer>
          <.button phx-disable-with="Guardando..." variant="primary">Guardar</.button>
          <.button navigate={return_path(@current_scope, @return_to, @item_inventario)}>
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
    item_inventario = Refugios.get_item_inventario!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edición de Item")
    |> assign(:item_inventario, item_inventario)
    |> assign(
      :form,
      to_form(Refugios.change_item_inventario(socket.assigns.current_scope, item_inventario))
    )
  end

  defp apply_action(socket, :new, _params) do
    item_inventario = %ItemInventario{refugio_id: socket.assigns.current_scope.usuario.id}

    socket
    |> assign(:page_title, "Nuevo Item")
    |> assign(:item_inventario, item_inventario)
    |> assign(
      :form,
      to_form(Refugios.change_item_inventario(socket.assigns.current_scope, item_inventario))
    )
  end

  @impl true
  def handle_event("validate", %{"item_inventario" => item_inventario_params}, socket) do
    changeset =
      Refugios.change_item_inventario(
        socket.assigns.current_scope,
        socket.assigns.item_inventario,
        item_inventario_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"item_inventario" => item_inventario_params}, socket) do
    save_item_inventario(socket, socket.assigns.live_action, item_inventario_params)
  end

  defp save_item_inventario(socket, :edit, item_inventario_params) do
    case Refugios.update_item_inventario(
           socket.assigns.current_scope,
           socket.assigns.item_inventario,
           item_inventario_params
         ) do
      {:ok, item_inventario} ->
        {:noreply,
         socket
         |> put_flash(:info, "Item actualizado con éxito.")
         |> push_navigate(
           to:
             return_path(socket.assigns.current_scope, socket.assigns.return_to, item_inventario)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_item_inventario(socket, :new, item_inventario_params) do
    case Refugios.create_item_inventario(socket.assigns.current_scope, item_inventario_params) do
      {:ok, item_inventario} ->
        {:noreply,
         socket
         |> put_flash(:info, "Item creado con éxito.")
         |> push_navigate(
           to:
             return_path(socket.assigns.current_scope, socket.assigns.return_to, item_inventario)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _item_inventario), do: ~p"/refugio/inventario"

  defp return_path(_scope, "show", item_inventario),
    do: ~p"/refugio/inventario/#{item_inventario}"
end
