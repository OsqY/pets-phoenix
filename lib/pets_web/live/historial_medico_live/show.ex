defmodule PetsWeb.HistorialMedicoLive.Show do
  use PetsWeb, :live_view

  alias Pets.Mascotas

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Historial medico {@historial_medico.id}
        <:subtitle>This is a historial_medico record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/historiales_medicos"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/historiales_medicos/#{@historial_medico}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit historial_medico
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Fecha">{@historial_medico.fecha}</:item>
        <:item title="Tipo">{@historial_medico.tipo}</:item>
        <:item title="Mascota">{@historial_medico.mascota_id}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Mascotas.subscribe_historiales_medicos(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Historial medico")
     |> assign(:historial_medico, Mascotas.get_historial_medico!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Pets.Mascotas.HistorialMedico{id: id} = historial_medico},
        %{assigns: %{historial_medico: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :historial_medico, historial_medico)}
  end

  def handle_info(
        {:deleted, %Pets.Mascotas.HistorialMedico{id: id}},
        %{assigns: %{historial_medico: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current historial_medico was deleted.")
     |> push_navigate(to: ~p"/historiales_medicos")}
  end

  def handle_info({type, %Pets.Mascotas.HistorialMedico{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
