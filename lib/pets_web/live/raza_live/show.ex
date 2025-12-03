defmodule PetsWeb.RazaLive.Show do
  use PetsWeb, :live_view

  alias Pets.Mascotas

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Raza {@raza.id}
        <:subtitle>Información de la raza registrada.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/razas"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/razas/#{@raza}/editar?return_to=show"}>
            <.icon name="hero-pencil-square" /> Editar raza
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Nombre">{@raza.nombre}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Mascotas.subscribe_razas(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Ver Raza")
     |> assign(:raza, Mascotas.get_raza!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Pets.Mascotas.Raza{id: id} = raza},
        %{assigns: %{raza: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :raza, raza)}
  end

  def handle_info(
        {:deleted, %Pets.Mascotas.Raza{id: id}},
        %{assigns: %{raza: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "La raza fue eliminada.")
     |> push_navigate(to: ~p"/razas")}
  end

  def handle_info({type, %Pets.Mascotas.Raza{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
