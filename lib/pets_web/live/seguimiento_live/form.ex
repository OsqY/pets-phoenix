defmodule PetsWeb.SeguimientoLive.Form do
  use PetsWeb, :live_view

  alias Pets.Adopciones
  alias Pets.Adopciones.Seguimiento

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage seguimiento records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="seguimiento-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:fecha]} type="date" label="Fecha" />
        <.input field={@form[:notas]} type="textarea" label="Notas" />
        <.input field={@form[:solicitud_id]} type="number" label="Solicitud" />
        <.input field={@form[:responsable_id]} type="number" label="Responsable" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Seguimiento</.button>
          <.button navigate={return_path(@current_scope, @return_to, @seguimiento)}>Cancel</.button>
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
    seguimiento = Adopciones.get_seguimiento!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Seguimiento")
    |> assign(:seguimiento, seguimiento)
    |> assign(:form, to_form(Adopciones.change_seguimiento(socket.assigns.current_scope, seguimiento)))
  end

  defp apply_action(socket, :new, _params) do
    seguimiento = %Seguimiento{usuario_id: socket.assigns.current_scope.usuario.id}

    socket
    |> assign(:page_title, "New Seguimiento")
    |> assign(:seguimiento, seguimiento)
    |> assign(:form, to_form(Adopciones.change_seguimiento(socket.assigns.current_scope, seguimiento)))
  end

  @impl true
  def handle_event("validate", %{"seguimiento" => seguimiento_params}, socket) do
    changeset = Adopciones.change_seguimiento(socket.assigns.current_scope, socket.assigns.seguimiento, seguimiento_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"seguimiento" => seguimiento_params}, socket) do
    save_seguimiento(socket, socket.assigns.live_action, seguimiento_params)
  end

  defp save_seguimiento(socket, :edit, seguimiento_params) do
    case Adopciones.update_seguimiento(socket.assigns.current_scope, socket.assigns.seguimiento, seguimiento_params) do
      {:ok, seguimiento} ->
        {:noreply,
         socket
         |> put_flash(:info, "Seguimiento updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, seguimiento)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_seguimiento(socket, :new, seguimiento_params) do
    case Adopciones.create_seguimiento(socket.assigns.current_scope, seguimiento_params) do
      {:ok, seguimiento} ->
        {:noreply,
         socket
         |> put_flash(:info, "Seguimiento created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, seguimiento)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _seguimiento), do: ~p"/seguimientos"
  defp return_path(_scope, "show", seguimiento), do: ~p"/seguimientos/#{seguimiento}"
end
