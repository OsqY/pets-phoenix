defmodule PetsWeb.EspecieLive.Form do
  use PetsWeb, :live_view

  alias Pets.Mascotas
  alias Pets.Mascotas.Especie

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage especie records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="especie-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:nombre]} type="text" label="Nombre" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Especie</.button>
          <.button navigate={return_path(@current_scope, @return_to, @especie)}>Cancel</.button>
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
    especie = Mascotas.get_especie!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Especie")
    |> assign(:especie, especie)
    |> assign(:form, to_form(Mascotas.change_especie(socket.assigns.current_scope, especie)))
  end

  defp apply_action(socket, :new, _params) do
    especie = %Especie{}

    socket
    |> assign(:page_title, "New Especie")
    |> assign(:especie, especie)
    |> assign(:form, to_form(Mascotas.change_especie(socket.assigns.current_scope, especie)))
  end

  @impl true
  def handle_event("validate", %{"especie" => especie_params}, socket) do
    changeset =
      Mascotas.change_especie(
        socket.assigns.current_scope,
        socket.assigns.especie,
        especie_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"especie" => especie_params}, socket) do
    save_especie(socket, socket.assigns.live_action, especie_params)
  end

  defp save_especie(socket, :edit, especie_params) do
    case Mascotas.update_especie(
           socket.assigns.current_scope,
           socket.assigns.especie,
           especie_params
         ) do
      {:ok, especie} ->
        {:noreply,
         socket
         |> put_flash(:info, "Especie actualizada correctamente")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, especie)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_especie(socket, :new, especie_params) do
    case Mascotas.create_especie(socket.assigns.current_scope, especie_params) do
      {:ok, especie} ->
        {:noreply,
         socket
         |> put_flash(:info, "Especie creada correctamente")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, especie)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _especie), do: ~p"/admin/especies"
  defp return_path(_scope, "show", especie), do: ~p"/admin/especies/#{especie}"
end
