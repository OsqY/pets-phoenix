defmodule PetsWeb.HistorialMedicoLive.Show do
  use PetsWeb, :live_view

  alias Pets.Mascotas

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-2xl mx-auto">
        <div class="mb-6">
          <.button navigate={~p"/historial-medico"}>
            <.icon name="hero-arrow-left" class="w-4 h-4 mr-1" /> Volver
          </.button>
        </div>

        <div class="bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-800 rounded-xl overflow-hidden">
          <div class={[
            "px-6 py-4 border-b border-gray-200 dark:border-gray-700",
            tipo_header_color(@historial.tipo)
          ]}>
            <div class="flex items-center gap-3">
              <div class="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center">
                <.icon name={tipo_icon(@historial.tipo)} class="w-6 h-6" />
              </div>
              <div>
                <h1 class="text-xl font-bold capitalize">
                  {format_tipo(@historial.tipo)}
                </h1>
                <p class="text-sm opacity-80">
                  {format_date(@historial.fecha)}
                </p>
              </div>
            </div>
          </div>

          <div class="p-6 space-y-6">
            <div class="flex items-center gap-4 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
              <div class="w-14 h-14 bg-indigo-100 dark:bg-indigo-900/50 rounded-full flex items-center justify-center">
                <.icon name="hero-heart" class="w-7 h-7 text-indigo-600 dark:text-indigo-400" />
              </div>
              <div>
                <p class="text-sm text-gray-500 dark:text-gray-400">Mascota</p>
                <p class="text-lg font-semibold text-gray-900 dark:text-gray-100">
                  {@historial.mascota.nombre}
                </p>
              </div>
            </div>

            <%= if @historial.descripcion do %>
              <div>
                <h3 class="text-sm font-medium text-gray-500 dark:text-gray-400 mb-2">
                  Descripción
                </h3>
                <p class="text-gray-700 dark:text-gray-300 whitespace-pre-wrap">
                  {@historial.descripcion}
                </p>
              </div>
            <% end %>

            <div class="grid grid-cols-2 gap-4 pt-4 border-t border-gray-200 dark:border-gray-700">
              <div>
                <p class="text-xs text-gray-500 dark:text-gray-400 mb-1">Fecha de registro</p>
                <p class="text-sm text-gray-700 dark:text-gray-300">
                  {format_datetime(@historial.inserted_at)}
                </p>
              </div>
              <div>
                <p class="text-xs text-gray-500 dark:text-gray-400 mb-1">Última actualización</p>
                <p class="text-sm text-gray-700 dark:text-gray-300">
                  {format_datetime(@historial.updated_at)}
                </p>
              </div>
            </div>
          </div>

          <div class="px-6 py-4 bg-gray-50 dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700 flex justify-end gap-3">
            <.button navigate={~p"/historial-medico/#{@historial}/editar"} variant="primary">
              <.icon name="hero-pencil-square" class="w-4 h-4 mr-1" /> Editar
            </.button>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp tipo_header_color(tipo) do
    case tipo do
      "vacuna" -> "bg-green-500 text-white"
      "desparasitacion" -> "bg-blue-500 text-white"
      "consulta" -> "bg-purple-500 text-white"
      "cirugia" -> "bg-red-500 text-white"
      "emergencia" -> "bg-orange-500 text-white"
      "control" -> "bg-cyan-500 text-white"
      "chequeo" -> "bg-indigo-500 text-white"
      _ -> "bg-gray-500 text-white"
    end
  end

  defp tipo_icon(tipo) do
    case tipo do
      "vacuna" -> "hero-beaker"
      "desparasitacion" -> "hero-bug-ant"
      "consulta" -> "hero-chat-bubble-left-right"
      "cirugia" -> "hero-scissors"
      "emergencia" -> "hero-exclamation-triangle"
      "control" -> "hero-clipboard-document-check"
      "chequeo" -> "hero-heart"
      _ -> "hero-document-text"
    end
  end

  defp format_tipo(tipo) do
    case tipo do
      "desparasitacion" -> "Desparasitación"
      "cirugia" -> "Cirugía"
      _ -> tipo
    end
  end

  defp format_date(date) do
    Calendar.strftime(date, "%d de %B, %Y")
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%d/%m/%Y a las %H:%M")
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Mascotas.subscribe_historiales_medicos(socket.assigns.current_scope)
    end

    historial = Mascotas.get_historial_medico!(socket.assigns.current_scope, id)

    {:ok,
     socket
     |> assign(:page_title, "Detalle del Registro")
     |> assign(:historial, historial)}
  end

  @impl true
  def handle_info({:updated, %Pets.Mascotas.HistorialMedico{id: id} = historial}, socket) do
    if socket.assigns.historial.id == id do
      {:noreply, assign(socket, :historial, historial)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:deleted, %Pets.Mascotas.HistorialMedico{id: id}}, socket) do
    if socket.assigns.historial.id == id do
      {:noreply,
       socket
       |> put_flash(:error, "Este registro fue eliminado.")
       |> push_navigate(to: ~p"/historial-medico")}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:created, %Pets.Mascotas.HistorialMedico{}}, socket) do
    {:noreply, socket}
  end
end
