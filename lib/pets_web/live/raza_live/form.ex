defmodule PetsWeb.RazaLive.Form do
  use PetsWeb, :live_view

  alias Pets.Mascotas
  alias Pets.Mascotas.Raza

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage raza records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="raza-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:nombre]} type="text" label="Nombre" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Raza</.button>
          <.button navigate={return_path(@current_scope, @return_to, @raza)}>Cancel</.button>
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
    raza = Mascotas.get_raza!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Raza")
    |> assign(:raza, raza)
    |> assign(:form, to_form(Mascotas.change_raza(socket.assigns.current_scope, raza)))
  end

  defp apply_action(socket, :new, _params) do
    raza = %Raza{usuario_id: socket.assigns.current_scope.usuario.id}

    socket
    |> assign(:page_title, "New Raza")
    |> assign(:raza, raza)
    |> assign(:form, to_form(Mascotas.change_raza(socket.assigns.current_scope, raza)))
  end

  @impl true
  def handle_event("validate", %{"raza" => raza_params}, socket) do
    changeset =
      Mascotas.change_raza(socket.assigns.current_scope, socket.assigns.raza, raza_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"raza" => raza_params}, socket) do
    save_raza(socket, socket.assigns.live_action, raza_params)
  end

  defp save_raza(socket, :edit, raza_params) do
    case Mascotas.update_raza(socket.assigns.current_scope, socket.assigns.raza, raza_params) do
      {:ok, raza} ->
        {:noreply,
         socket
         |> put_flash(:info, "Raza updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, raza)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_raza(socket, :new, raza_params) do
    case Mascotas.create_raza(socket.assigns.current_scope, raza_params) do
      {:ok, raza} ->
        {:noreply,
         socket
         |> put_flash(:info, "Raza created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, raza)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _raza), do: ~p"/admin/razas"
  defp return_path(_scope, "show", raza), do: ~p"/admin/razas/#{raza}"
end
