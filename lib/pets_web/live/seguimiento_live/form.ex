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
        <:subtitle>Formulario de Seguimiento para procesos de Adopción</:subtitle>
      </.header>

      <.form for={@form} id="seguimiento-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:fecha]} type="hidden" />
        <.input field={@form[:notas]} type="textarea" label="Notas" />
        <.input field={@form[:solicitud_id]} type="hidden" />
        <.input field={@form[:responsable_id]} type="hidden" />
        <.input field={@form[:usuario_id]} type="hidden" />
        <footer>
          <.button phx-disable-with="Guardando..." variant="primary">Guardar Seguimiento</.button>
          <.button navigate={return_path(@current_scope, @return_to, @seguimiento)}>Cancelar</.button>
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
    |> assign(:page_title, "Editar Seguimiento")
    |> assign(:seguimiento, seguimiento)
    |> assign(
      :form,
      to_form(Adopciones.change_seguimiento(socket.assigns.current_scope, seguimiento))
    )
  end

  defp apply_action(socket, :new, _params) do
    seguimiento = %Seguimiento{
      solicitud_id: _params["solicitud-id"],
      responsable_id: socket.assigns.current_scope.usuario.id,
      usuario_id: _params["adoptante-id"],
      fecha: NaiveDateTime.utc_now()
    }

    socket
    |> assign(:page_title, "Registrar Seguimiento")
    |> assign(:seguimiento, seguimiento)
    |> assign(
      :form,
      to_form(Adopciones.change_seguimiento(socket.assigns.current_scope, seguimiento))
    )
  end

  @impl true
  def handle_event("validate", %{"seguimiento" => seguimiento_params}, socket) do
    changeset =
      Adopciones.change_seguimiento(
        socket.assigns.current_scope,
        socket.assigns.seguimiento,
        seguimiento_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"seguimiento" => seguimiento_params}, socket) do
    save_seguimiento(socket, socket.assigns.live_action, seguimiento_params)
  end

  defp save_seguimiento(socket, :edit, seguimiento_params) do
    case Adopciones.update_seguimiento(
           socket.assigns.current_scope,
           socket.assigns.seguimiento,
           seguimiento_params
         ) do
      {:ok, seguimiento} ->
        {:noreply,
         socket
         |> put_flash(:info, "Seguimiento actualizado con éxito.")
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
         |> put_flash(:info, "Seguimiento creado con éxito.")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, seguimiento)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _seguimiento) do
    IO.inspect(_seguimiento, label: "Seguimiento")
    ~p"/solicitudes-adopcion/#{_seguimiento.solicitud_id}/seguimientos"
  end

  defp return_path(_scope, "show", seguimiento),
    do: ~p"/solicitudes-adopcion/#{seguimiento.solicitud_id}/seguimientos/#{seguimiento}"
end
