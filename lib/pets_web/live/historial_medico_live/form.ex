defmodule PetsWeb.HistorialMedicoLive.Form do
  use PetsWeb, :live_view

  alias Pets.Mascotas
  alias Pets.Mascotas.HistorialMedico

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-2xl mx-auto">
        <div class="mb-8">
          <.button navigate={~p"/historial-medico"}>
            <.icon name="hero-arrow-left" class="w-4 h-4 mr-1" /> Volver
          </.button>
        </div>

        <div class="bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-800 rounded-xl p-8">
          <div class="mb-8">
            <h1 class="text-2xl font-bold text-gray-900 dark:text-gray-100">
              {@page_title}
            </h1>
            <p class="text-sm text-gray-500 dark:text-gray-400 mt-2">
              Registra una atención médica para tu mascota
            </p>
          </div>

          <.form for={@form} id="historial-form" phx-change="validate" phx-submit="save" class="space-y-8">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Mascota
                </label>
                <select
                  name="historial_medico[mascota_id]"
                  class="w-full rounded-lg border-gray-300 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-100 focus:ring-indigo-500 focus:border-indigo-500 py-2.5"
                  required
                >
                  <option value="">Selecciona una mascota</option>
                  <%= for {nombre, id} <- @mascotas do %>
                    <option value={id} selected={to_string(id) == to_string(@form[:mascota_id].value)}>
                      {nombre}
                    </option>
                  <% end %>
                </select>
                <%= if @form[:mascota_id].errors != [] do %>
                  <p class="mt-2 text-sm text-red-600 dark:text-red-400">
                    {translate_error(hd(@form[:mascota_id].errors))}
                  </p>
                <% end %>
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Fecha
                </label>
                <input
                  type="date"
                  name="historial_medico[fecha]"
                  value={@form[:fecha].value}
                  class="w-full rounded-lg border-gray-300 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-100 focus:ring-indigo-500 focus:border-indigo-500 py-2.5"
                  required
                />
                <%= if @form[:fecha].errors != [] do %>
                  <p class="mt-2 text-sm text-red-600 dark:text-red-400">
                    {translate_error(hd(@form[:fecha].errors))}
                  </p>
                <% end %>
              </div>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-3">
                Tipo de Atención
              </label>
              <div class="grid grid-cols-2 md:grid-cols-4 gap-3">
                <%= for tipo <- HistorialMedico.tipos() do %>
                  <label class={[
                    "flex items-center justify-center px-4 py-3 rounded-lg border cursor-pointer transition-colors text-sm font-medium",
                    if(@form[:tipo].value == tipo,
                      do: "border-indigo-500 bg-indigo-50 dark:bg-indigo-900/30 text-indigo-700 dark:text-indigo-300 ring-2 ring-indigo-500/20",
                      else: "border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800 text-gray-700 dark:text-gray-300"
                    )
                  ]}>
                    <input
                      type="radio"
                      name="historial_medico[tipo]"
                      value={tipo}
                      checked={@form[:tipo].value == tipo}
                      class="sr-only"
                    />
                    <.icon name={tipo_icon(tipo)} class="w-4 h-4 mr-2" />
                    {format_tipo(tipo)}
                  </label>
                <% end %>
              </div>
              <%= if @form[:tipo].errors != [] do %>
                <p class="mt-2 text-sm text-red-600 dark:text-red-400">
                  {translate_error(hd(@form[:tipo].errors))}
                </p>
              <% end %>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Descripción <span class="text-gray-400 font-normal">(opcional)</span>
              </label>
              <textarea
                name="historial_medico[descripcion]"
                rows="4"
                placeholder="Detalles adicionales sobre la atención médica..."
                class="w-full rounded-lg border-gray-300 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-100 focus:ring-indigo-500 focus:border-indigo-500 py-2.5"
              >{@form[:descripcion].value}</textarea>
            </div>

            <div class="flex items-center justify-end gap-4 pt-6 border-t border-gray-200 dark:border-gray-700">
              <.button navigate={~p"/historial-medico"}>
                Cancelar
              </.button>
              <.button type="submit" variant="primary" phx-disable-with="Guardando...">
                <.icon name="hero-check" class="w-4 h-4 mr-1" />
                Guardar Registro
              </.button>
            </div>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
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
      "vacuna" -> "Vacuna"
      "desparasitacion" -> "Desparasitación"
      "consulta" -> "Consulta"
      "cirugia" -> "Cirugía"
      "emergencia" -> "Emergencia"
      "control" -> "Control"
      "chequeo" -> "Chequeo"
      "otro" -> "Otro"
      _ -> tipo
    end
  end



  @impl true
  def mount(params, _session, socket) do
    mascotas = Mascotas.list_mascotas_for_dropdown(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:mascotas, mascotas)
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    historial = Mascotas.get_historial_medico!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Editar Registro Médico")
    |> assign(:historial_medico, historial)
    |> assign(:form, to_form(Mascotas.change_historial_medico(socket.assigns.current_scope, historial)))
  end

  defp apply_action(socket, :new, params) do
    historial = %HistorialMedico{
      usuario_id: socket.assigns.current_scope.usuario.id,
      fecha: Date.utc_today()
    }

    attrs = if params["mascota_id"], do: %{"mascota_id" => params["mascota_id"]}, else: %{}

    socket
    |> assign(:page_title, "Nuevo Registro Médico")
    |> assign(:historial_medico, historial)
    |> assign(:form, to_form(Mascotas.change_new_historial_medico(socket.assigns.current_scope, attrs)))
  end

  @impl true
  def handle_event("validate", %{"historial_medico" => params}, socket) do
    changeset =
      Mascotas.change_historial_medico(
        socket.assigns.current_scope,
        socket.assigns.historial_medico,
        params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"historial_medico" => params}, socket) do
    save_historial(socket, socket.assigns.live_action, params)
  end

  defp save_historial(socket, :edit, params) do
    case Mascotas.update_historial_medico(
           socket.assigns.current_scope,
           socket.assigns.historial_medico,
           params
         ) do
      {:ok, _historial} ->
        {:noreply,
         socket
         |> put_flash(:info, "Registro médico actualizado")
         |> push_navigate(to: ~p"/historial-medico")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_historial(socket, :new, params) do
    case Mascotas.create_historial_medico(socket.assigns.current_scope, params) do
      {:ok, _historial} ->
        {:noreply,
         socket
         |> put_flash(:info, "Registro médico creado")
         |> push_navigate(to: ~p"/historial-medico")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
