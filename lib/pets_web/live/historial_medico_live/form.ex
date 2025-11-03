defmodule PetsWeb.HistorialMedicoLive.Form do
  use PetsWeb, :live_view

  alias Pets.Mascotas
  alias Pets.Mascotas.HistorialMedico

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage historial_medico records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="historial_medico-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:fecha]} type="date" label="Fecha" />
        <.input field={@form[:tipo]} type="text" label="Tipo" />
        <.input field={@form[:mascota_id]} type="number" label="Mascota" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Historial medico</.button>
          <.button navigate={return_path(@current_scope, @return_to, @historial_medico)}>Cancel</.button>
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
    historial_medico = Mascotas.get_historial_medico!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Historial medico")
    |> assign(:historial_medico, historial_medico)
    |> assign(:form, to_form(Mascotas.change_historial_medico(socket.assigns.current_scope, historial_medico)))
  end

  defp apply_action(socket, :new, _params) do
    historial_medico = %HistorialMedico{usuario_id: socket.assigns.current_scope.usuario.id}

    socket
    |> assign(:page_title, "New Historial medico")
    |> assign(:historial_medico, historial_medico)
    |> assign(:form, to_form(Mascotas.change_historial_medico(socket.assigns.current_scope, historial_medico)))
  end

  @impl true
  def handle_event("validate", %{"historial_medico" => historial_medico_params}, socket) do
    changeset = Mascotas.change_historial_medico(socket.assigns.current_scope, socket.assigns.historial_medico, historial_medico_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"historial_medico" => historial_medico_params}, socket) do
    save_historial_medico(socket, socket.assigns.live_action, historial_medico_params)
  end

  defp save_historial_medico(socket, :edit, historial_medico_params) do
    case Mascotas.update_historial_medico(socket.assigns.current_scope, socket.assigns.historial_medico, historial_medico_params) do
      {:ok, historial_medico} ->
        {:noreply,
         socket
         |> put_flash(:info, "Historial medico updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, historial_medico)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_historial_medico(socket, :new, historial_medico_params) do
    case Mascotas.create_historial_medico(socket.assigns.current_scope, historial_medico_params) do
      {:ok, historial_medico} ->
        {:noreply,
         socket
         |> put_flash(:info, "Historial medico created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, historial_medico)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _historial_medico), do: ~p"/historiales_medicos"
  defp return_path(_scope, "show", historial_medico), do: ~p"/historiales_medicos/#{historial_medico}"
end
