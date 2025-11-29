defmodule PetsWeb.HistorialMedicoLive.Index do
  use PetsWeb, :live_view

  alias Pets.Mascotas

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-4xl mx-auto">
        <div class="flex items-center justify-between mb-6">
          <div>
            <h1 class="text-2xl font-bold text-gray-900 dark:text-gray-100">
              Historial Médico
            </h1>
            <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">
              Registro de atenciones médicas de tus mascotas
            </p>
          </div>
          <.button variant="primary" navigate={~p"/historial-medico/nuevo"}>
            <.icon name="hero-plus" class="w-4 h-4 mr-1" /> Nuevo Registro
          </.button>
        </div>

        <div id="historiales" phx-update="stream" class="space-y-4">
          <div class="hidden only:block text-center py-12">
            <.icon name="hero-clipboard-document-list" class="w-16 h-16 mx-auto text-gray-300 dark:text-gray-600 mb-4" />
            <h3 class="text-lg font-medium text-gray-900 dark:text-gray-100 mb-2">
              No hay registros médicos
            </h3>
            <p class="text-sm text-gray-500 dark:text-gray-400 mb-4">
              Comienza agregando el historial médico de tus mascotas
            </p>
            <.button variant="primary" navigate={~p"/historial-medico/nuevo"}>
              <.icon name="hero-plus" class="w-4 h-4 mr-1" /> Agregar Registro
            </.button>
          </div>

          <div
            :for={{dom_id, historial} <- @streams.historiales_medicos}
            id={dom_id}
            class="bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-800 rounded-xl p-4 hover:shadow-md transition-shadow"
          >
            <div class="flex items-start justify-between">
              <div class="flex items-start gap-4">
                <div class={[
                  "w-12 h-12 rounded-full flex items-center justify-center flex-shrink-0",
                  tipo_color(historial.tipo)
                ]}>
                  <.icon name={tipo_icon(historial.tipo)} class="w-6 h-6" />
                </div>
                <div>
                  <div class="flex items-center gap-2 mb-1">
                    <span class="font-semibold text-gray-900 dark:text-gray-100 capitalize">
                      {format_tipo(historial.tipo)}
                    </span>
                    <span class="text-xs px-2 py-0.5 bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-400 rounded-full">
                      {historial.mascota.nombre}
                    </span>
                  </div>
                  <p class="text-sm text-gray-500 dark:text-gray-400">
                    {format_date(historial.fecha)}
                  </p>
                  <%= if historial.descripcion do %>
                    <p class="text-sm text-gray-600 dark:text-gray-300 mt-2">
                      {historial.descripcion}
                    </p>
                  <% end %>
                </div>
              </div>
              <div class="flex items-center gap-2">
                <.link
                  navigate={~p"/historial-medico/#{historial}/editar"}
                  class="p-2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-full transition-colors"
                >
                  <.icon name="hero-pencil-square" class="w-5 h-5" />
                </.link>
                <button
                  type="button"
                  phx-click="delete"
                  phx-value-id={historial.id}
                  data-confirm="¿Estás seguro de eliminar este registro?"
                  class="p-2 text-gray-400 hover:text-red-600 dark:hover:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-full transition-colors"
                >
                  <.icon name="hero-trash" class="w-5 h-5" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp tipo_color(tipo) do
    case tipo do
      "vacuna" -> "bg-green-100 dark:bg-green-900/50 text-green-600 dark:text-green-400"
      "desparasitacion" -> "bg-blue-100 dark:bg-blue-900/50 text-blue-600 dark:text-blue-400"
      "consulta" -> "bg-purple-100 dark:bg-purple-900/50 text-purple-600 dark:text-purple-400"
      "cirugia" -> "bg-red-100 dark:bg-red-900/50 text-red-600 dark:text-red-400"
      "emergencia" -> "bg-orange-100 dark:bg-orange-900/50 text-orange-600 dark:text-orange-400"
      "control" -> "bg-cyan-100 dark:bg-cyan-900/50 text-cyan-600 dark:text-cyan-400"
      "chequeo" -> "bg-indigo-100 dark:bg-indigo-900/50 text-indigo-600 dark:text-indigo-400"
      _ -> "bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-400"
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

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Mascotas.subscribe_historiales_medicos(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Historial Médico")
     |> stream(:historiales_medicos, Mascotas.list_historiales_medicos(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    historial = Mascotas.get_historial_medico!(socket.assigns.current_scope, id)
    {:ok, _} = Mascotas.delete_historial_medico(socket.assigns.current_scope, historial)

    {:noreply, stream_delete(socket, :historiales_medicos, historial)}
  end

  @impl true
  def handle_info({type, %Pets.Mascotas.HistorialMedico{}}, socket)
      when type in [:created, :updated, :deleted] do
    historiales = Mascotas.list_historiales_medicos(socket.assigns.current_scope)
    {:noreply, stream(socket, :historiales_medicos, historiales, reset: true)}
  end
end
