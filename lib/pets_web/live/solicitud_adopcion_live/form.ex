defmodule PetsWeb.SolicitudAdopcionLive.Form do
  alias Pets.Mascotas
  alias Pets.Mascotas.Mascota
  use PetsWeb, :live_view

  alias Pets.Adopciones
  alias Pets.Adopciones.SolicitudAdopcion

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Solicitud</:subtitle>
      </.header>

      <.form for={@form} id="solicitud_adopcion-form" phx-change="validate" phx-submit="save">
        <.input
          field="adoptante"
          name="adoptante"
          value={@current_scope.usuario.email}
          type="tex"
          label="Adoptante"
          disabled
        />
        <.input
          value={@mascota_nombre}
          field={@mascota_nombre}
          type="text"
          label="Mascota"
          name="NombreMascota"
          disabled
        />
        <footer>
          <.button phx-disable-with="Guardando..." variant="primary">Crear Solicitud</.button>
          <.button navigate={return_path(@current_scope, @return_to, @solicitud_adopcion)}>
            Cancelar
          </.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    if socket.assigns.live_action == :new do
      mascota = Mascotas.get_mascota(params["mascota_id"])

      case mascota do
        nil ->
          {:ok,
           socket
           |> put_flash(:error, "La mascota no existe.")
           |> push_navigate(to: "/mascotas")
           |> Map.put(:halted, true)}

        mascota ->
          if mascota.estado != :EnAdopcion ||
               mascota.usuario_id == socket.assigns.current_scope.usuario.id do
            {:ok,
             socket
             |> put_flash(:error, "No puedes hacer esta solicitud.")
             |> push_navigate(to: ~p"/mascotas/#{mascota.id}")
             |> Map.put(:halted, true)}
          else
            {:ok,
             socket
             |> assign(:mascota, mascota)
             |> assign(:return_to, return_to(params["return_to"]))
             |> apply_action(socket.assigns.live_action, params)}
          end
      end
    else
      {:ok,
       socket
       |> assign(:return_to, return_to(params["return_to"]))
       |> apply_action(socket.assigns.live_action, params)}
    end
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    solicitud_adopcion = Adopciones.get_solicitud_adopcion!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Editar Solicitud")
    |> assign(:solicitud_adopcion, solicitud_adopcion)
    |> assign(
      :form,
      to_form(
        Adopciones.change_solicitud_adopcion(socket.assigns.current_scope, solicitud_adopcion)
      )
    )
  end

  defp apply_action(socket, :new, _params) do
    mascota = Mascotas.get_mascota(_params["mascota_id"])

    solicitud_adopcion = %SolicitudAdopcion{
      adoptante_id: socket.assigns.current_scope.usuario.id,
      refugio_id: mascota.usuario_id,
      mascota_id: _params["mascota_id"],
      fecha_solicitud: NaiveDateTime.utc_now(),
      estado: :pendiente
    }

    socket
    |> assign(:page_title, "Crear Solicitud")
    |> assign(:solicitud_adopcion, solicitud_adopcion)
    |> assign(:mascota_nombre, _params["mascota_nombre"])
    |> assign(
      :form,
      to_form(
        Adopciones.change_solicitud_adopcion(socket.assigns.current_scope, solicitud_adopcion)
      )
    )
  end

  @impl true
  def handle_event("validate", %{"solicitud_adopcion" => solicitud_adopcion_params}, socket) do
    changeset =
      Adopciones.change_solicitud_adopcion(
        socket.assigns.current_scope,
        socket.assigns.solicitud_adopcion,
        solicitud_adopcion_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"solicitud_adopcion" => solicitud_adopcion_params}, socket) do
    save_solicitud_adopcion(socket, socket.assigns.live_action, solicitud_adopcion_params)
  end

  defp save_solicitud_adopcion(socket, :edit, solicitud_adopcion_params) do
    case Adopciones.update_solicitud_adopcion(
           socket.assigns.current_scope,
           socket.assigns.solicitud_adopcion,
           solicitud_adopcion_params
         ) do
      {:ok, solicitud_adopcion} ->
        {:noreply,
         socket
         |> put_flash(:info, "Solicitud adopcion updated successfully")
         |> push_navigate(
           to:
             return_path(
               socket.assigns.current_scope,
               socket.assigns.return_to,
               solicitud_adopcion
             )
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_solicitud_adopcion(socket, :new, solicitud_adopcion_params) do
    case Adopciones.create_solicitud_adopcion(
           socket.assigns.current_scope,
           solicitud_adopcion_params
         ) do
      {:ok, solicitud_adopcion} ->
        {:noreply,
         socket
         |> put_flash(:info, "Solicitud adopcion created successfully")
         |> push_navigate(
           to:
             return_path(
               socket.assigns.current_scope,
               socket.assigns.return_to,
               solicitud_adopcion
             )
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _solicitud_adopcion), do: ~p"/solicitudes-adopcion"

  defp return_path(_scope, "show", solicitud_adopcion),
    do: ~p"/solicitudes-adopcion/#{solicitud_adopcion}"
end
