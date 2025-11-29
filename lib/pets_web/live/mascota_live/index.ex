defmodule PetsWeb.MascotaLive.Index do
  alias Pets.Mascotas.Mascota
  use PetsWeb, :live_view

  alias Pets.Mascotas

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <.header>
          Mascotas
          <:actions>
            <.button variant="primary" navigate={~p"/mascotas/crear"}>
              Nueva Mascota
            </.button>
          </:actions>
        </.header>
        
    <!-- Barra de búsqueda -->
        <form phx-change="search" phx-debounce="300" class="mt-6">
          <div class="relative">
            <input
              type="text"
              name="query"
              id="query"
              value={@query}
              class="block w-full pl-4 pr-4 py-3 border border-gray-200 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-900 focus:outline-none focus:ring-2 focus:ring-gray-900 dark:focus:ring-gray-100 focus:border-transparent"
              placeholder="Buscar mascotas..."
            />
          </div>
        </form>
        
    <!-- Grid de mascotas -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 mt-6">
          <div :for={{id, mascota} <- @streams.mascotas} id={id}>
            <div class="bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-800 rounded-lg overflow-hidden hover:shadow-lg transition-shadow">
              <!-- Imagen -->
              <div
                class="relative aspect-square bg-gray-100 dark:bg-gray-800 cursor-pointer"
                phx-click="navigate"
                phx-value-id={mascota.id}
              >
                <%= if mascota.imagenes && length(mascota.imagenes) > 0 do %>
                  <img
                    src={List.first(mascota.imagenes).url || "/placeholder.svg"}
                    alt={mascota.nombre}
                    class="w-full h-full object-cover"
                  />
                  <%= if length(mascota.imagenes) > 1 do %>
                    <div class="absolute top-2 right-2 bg-black/60 text-white text-xs px-2 py-1 rounded">
                      {length(mascota.imagenes)}
                    </div>
                  <% end %>
                <% else %>
                  <div class="w-full h-full flex items-center justify-center">
                    <div class="w-12 h-12 text-gray-300 dark:text-gray-700">
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke-width="1.5"
                        stroke="currentColor"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          d="m2.25 15.75 5.159-5.159a2.25 2.25 0 0 1 3.182 0l5.159 5.159m-1.5-1.5 1.409-1.409a2.25 2.25 0 0 1 3.182 0l2.909 2.909m-18 3.75h16.5a1.5 1.5 0 0 0 1.5-1.5V6a1.5 1.5 0 0 0-1.5-1.5H3.75A1.5 1.5 0 0 0 2.25 6v12a1.5 1.5 0 0 0 1.5 1.5Zm10.5-11.25h.008v.008h-.008V8.25Zm.375 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Z"
                        />
                      </svg>
                    </div>
                  </div>
                <% end %>
                <!-- Badges simples -->
                <div class="absolute top-2 left-2 flex flex-col gap-1">
                  <span class={[
                    "text-xs px-2 py-0.5 rounded font-medium",
                    estado_badge_class(mascota.estado)
                  ]}>
                    {Mascota.humanize_estado(mascota.estado)}
                  </span>
                </div>
              </div>
              <!-- Info -->
              <div class="p-4">
                <div class="flex items-start justify-between mb-2">
                  <h3
                    class="text-base font-semibold text-gray-900 dark:text-gray-100 cursor-pointer hover:underline"
                    phx-click="navigate"
                    phx-value-id={mascota.id}
                  >
                    {mascota.nombre}
                  </h3>
                  <div class="flex gap-1 ml-2">
                    <button
                      type="button"
                      phx-click="edit"
                      phx-value-id={mascota.id}
                      class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
                      title="Editar"
                    >
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke-width="1.5"
                        stroke="currentColor"
                        class="w-4 h-4"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0 1 15.75 21H5.25A2.25 2.25 0 0 1 3 18.75V8.25A2.25 2.25 0 0 1 5.25 6H10"
                        />
                      </svg>
                    </button>
                    <button
                      type="button"
                      phx-click="delete"
                      phx-value-id={mascota.id}
                      data-confirm="¿Estás seguro?"
                      class="text-gray-400 hover:text-red-600 dark:hover:text-red-400"
                      title="Eliminar"
                    >
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke-width="1.5"
                        stroke="currentColor"
                        class="w-4 h-4"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0"
                        />
                      </svg>
                    </button>
                  </div>
                </div>

                <div class="text-sm text-gray-600 dark:text-gray-400 mb-3 line-clamp-2">
                  {mascota.descripcion || "Sin descripción"}
                </div>

                <div class="flex items-center gap-2 text-xs text-gray-500 dark:text-gray-500 mb-2">
                  <span>{mascota.especie.nombre}</span>
                  <span>·</span>
                  <span>{mascota.raza.nombre}</span>
                </div>

                <div class="flex items-center justify-between text-xs text-gray-500 dark:text-gray-500">
                  <div class="flex items-center gap-3">
                    <span>{mascota.edad} años</span>
                    <span>{mascota.peso} kg</span>
                  </div>
                  <span>{mascota.sexo}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
        
    <!-- Estado vacío -->
        <div
          :if={map_size(@streams.mascotas) == 0}
          class="text-center py-16 mt-8"
        >
          <div class="text-gray-400 dark:text-gray-600 mb-4">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
              class="w-16 h-16 mx-auto"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z"
              />
            </svg>
          </div>
          <h3 class="text-lg font-medium text-gray-900 dark:text-gray-100 mb-2">
            {if @query != "", do: "No se encontraron mascotas", else: "No hay mascotas"}
          </h3>
          <p class="text-sm text-gray-500 dark:text-gray-400 mb-4">
            {if @query != "", do: "Intenta con otros términos", else: "Crea tu primera mascota"}
          </p>
          <.button variant="primary" navigate={~p"/mascotas/crear"}>
            Nueva Mascota
          </.button>
        </div>
        
    <!-- Contador -->
        <div :if={map_size(@streams.mascotas) > 0} class="mt-6 text-center">
          <span class="text-sm text-gray-500 dark:text-gray-400">
            {map_size(@streams.mascotas)}
            {if map_size(@streams.mascotas) == 1, do: "mascota", else: "mascotas"}
          </span>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp estado_badge_class(:EnAdopcion), do: "bg-green-500 text-white"
  defp estado_badge_class(:ConHogar), do: "bg-blue-500 text-white"
  defp estado_badge_class(:Adoptado), do: "bg-gray-500 text-white"
  defp estado_badge_class(:EnProcesoAdopcion), do: "bg-yellow-500 text-white"
  defp estado_badge_class(_), do: "bg-gray-400 text-white"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Mascotas.subscribe_mascotas(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Mascotas")
     |> assign(:query, "")
     |> stream(:mascotas, list_mascotas(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("navigate", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/mascotas/#{id}")}
  end

  @impl true
  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/mascotas/#{id}/editar")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    mascota = Mascotas.get_mascota!(socket.assigns.current_scope, id)
    {:ok, _} = Mascotas.delete_mascota(socket.assigns.current_scope, mascota)

    {:noreply, stream_delete(socket, :mascotas, mascota)}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    mascotas = Mascotas.list_mascotas(socket.assigns.current_scope, query)

    {:noreply,
     socket
     |> assign(:query, query)
     |> stream(:mascotas, mascotas, reset: true)}
  end

  @impl true
  def handle_event("search", %{"_target" => _}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({type, %Pets.Mascotas.Mascota{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :mascotas, list_mascotas(socket.assigns.current_scope), reset: true)}
  end

  defp list_mascotas(current_scope, query \\ "") do
    Mascotas.list_mascotas(current_scope, query)
  end
end
