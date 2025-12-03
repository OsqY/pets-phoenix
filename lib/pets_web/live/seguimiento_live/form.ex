defmodule PetsWeb.SeguimientoLive.Form do
  use PetsWeb, :live_view

  alias Pets.Adopciones
  alias Pets.Adopciones.Seguimiento
  alias Pets.Adopciones.SolicitudAdopcion

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
        <.input
          field={@form[:nuevo_estado]}
          type="select"
          label="Estado de la solicitud"
          options={@estados_options}
        />
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
    solicitud = Adopciones.get_solicitud_adopcion!(socket.assigns.current_scope, seguimiento.solicitud_id)

    socket
    |> assign(:page_title, "Editar Seguimiento")
    |> assign(:seguimiento, seguimiento)
    |> assign(:estados_options, SolicitudAdopcion.solicitudes_estado_options())
    |> assign(:solicitud, solicitud)
    |> assign(
      :form,
      to_form(Adopciones.change_seguimiento(socket.assigns.current_scope, seguimiento))
    )
  end

  defp apply_action(socket, :new, params) do
    solicitud_id = params["solicitud-id"]
    solicitud = Adopciones.get_solicitud_adopcion!(socket.assigns.current_scope, solicitud_id)

    seguimiento = %Seguimiento{
      solicitud_id: solicitud_id,
      responsable_id: socket.assigns.current_scope.usuario.id,
      usuario_id: params["adoptante-id"],
      fecha: Date.utc_today()
    }

    socket
    |> assign(:page_title, "Registrar Seguimiento")
    |> assign(:seguimiento, seguimiento)
    |> assign(:estados_options, SolicitudAdopcion.solicitudes_estado_options())
    |> assign(:solicitud, solicitud)
    |> assign(
      :form,
      to_form(Adopciones.change_seguimiento(socket.assigns.current_scope, seguimiento, %{nuevo_estado: solicitud.estado}))
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
    nuevo_estado = seguimiento_params["nuevo_estado"]

    case Adopciones.update_seguimiento(
           socket.assigns.current_scope,
           socket.assigns.seguimiento,
           seguimiento_params
         ) do
      {:ok, seguimiento} ->
        if nuevo_estado && nuevo_estado != "" do
          Adopciones.update_solicitud_adopcion(
            socket.assigns.current_scope,
            socket.assigns.solicitud,
            %{estado: nuevo_estado, fecha_revision: Date.utc_today()}
          )
        end

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
    nuevo_estado = seguimiento_params["nuevo_estado"]

    case Adopciones.create_seguimiento(socket.assigns.current_scope, seguimiento_params) do
      {:ok, seguimiento} ->
        if nuevo_estado && nuevo_estado != "" do
          Adopciones.update_solicitud_adopcion(
            socket.assigns.current_scope,
            socket.assigns.solicitud,
            %{estado: nuevo_estado, fecha_revision: Date.utc_today()}
          )
        end

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

  defp return_path(_scope, "index", seguimiento) do
    ~p"/solicitudes-adopcion/#{seguimiento.solicitud_id}/seguimientos"
  end

  defp return_path(_scope, "show", seguimiento),
    do: ~p"/solicitudes-adopcion/#{seguimiento.solicitud_id}/seguimientos/#{seguimiento}"
end
