defmodule PetsWeb.DonacionDineroLive.Form do
  use PetsWeb, :live_view

  alias Pets.Refugios
  alias Pets.Refugios.DonacionDinero

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Formulario para registrar donaciones de carácter monetario.</:subtitle>
      </.header>

      <.form for={@form} id="donacion_dinero-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:monto]} type="text" inputmode="decimal" label="Monto" placeholder="0.00" />
        <.input field={@form[:descripcion]} type="text" label="Descripcion" />
        <.input field={@form[:fecha]} type="date" label="Fecha" />
        <.input field={@form[:donante]} type="text" label="Donante" placeholder="Nombre del donante (opcional)" />
        <footer>
          <.button phx-disable-with="Guardando..." variant="primary">Guardar</.button>
          <.button navigate={return_path(@current_scope, @return_to, @donacion_dinero)}>
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
    donacion_dinero = Refugios.get_donacion_dinero!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Editar Donación")
    |> assign(:donacion_dinero, donacion_dinero)
    |> assign(
      :form,
      to_form(Refugios.change_donacion_dinero(socket.assigns.current_scope, donacion_dinero))
    )
  end

  defp apply_action(socket, :new, _params) do
    donacion_dinero = %DonacionDinero{refugio_id: socket.assigns.current_scope.usuario.id}

    socket
    |> assign(:page_title, "Registrar Donación")
    |> assign(:donacion_dinero, donacion_dinero)
    |> assign(
      :form,
      to_form(Refugios.change_donacion_dinero(socket.assigns.current_scope, donacion_dinero))
    )
  end

  @impl true
  def handle_event("validate", %{"donacion_dinero" => donacion_dinero_params}, socket) do
    changeset =
      Refugios.change_donacion_dinero(
        socket.assigns.current_scope,
        socket.assigns.donacion_dinero,
        donacion_dinero_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"donacion_dinero" => donacion_dinero_params}, socket) do
    save_donacion_dinero(socket, socket.assigns.live_action, donacion_dinero_params)
  end

  defp save_donacion_dinero(socket, :edit, donacion_dinero_params) do
    case Refugios.update_donacion_dinero(
           socket.assigns.current_scope,
           socket.assigns.donacion_dinero,
           donacion_dinero_params
         ) do
      {:ok, donacion_dinero} ->
        {:noreply,
         socket
         |> put_flash(:info, "Donación actualizada con éxito.")
         |> push_navigate(
           to:
             return_path(socket.assigns.current_scope, socket.assigns.return_to, donacion_dinero)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_donacion_dinero(socket, :new, donacion_dinero_params) do
    case Refugios.create_donacion_dinero(socket.assigns.current_scope, donacion_dinero_params) do
      {:ok, donacion_dinero} ->
        {:noreply,
         socket
         |> put_flash(:info, "Donación registrada con éxito.")
         |> push_navigate(
           to:
             return_path(socket.assigns.current_scope, socket.assigns.return_to, donacion_dinero)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _donacion_dinero), do: ~p"/refugio/donacion-dinero"

  defp return_path(_scope, "show", donacion_dinero),
    do: ~p"/refugio/donacion-dinero/#{donacion_dinero}"
end
