defmodule PetsWeb.MascotaLive.Index do
  alias Pets.Mascotas.Mascota
  use PetsWeb, :live_view

  alias Pets.Mascotas

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-8xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <.header>
          <.icon name="hero-heart" class="w-8 h-8 mr-2 text-pink-500" /> Nuestras Mascotas
          <:actions>
            <.button
              variant="primary"
              navigate={~p"/mascotas/crear"}
            >
              <.icon name="hero-plus" class="w-5 h-5 mr-1" /> Nueva Mascota
            </.button>
          </:actions>
        </.header>

        <div class="mb-8 p-6 rounded-xl border border-slate-700">
          <div class="flex flex-col md:flex-row gap-4 items-center justify-between">
            <div class="flex-1 w-full">
              <label for="search" class="sr-only">Buscar mascotas</label>
              <div class="relative">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <.icon name="hero-magnifying-glass" class="h-5 w-5 text-gray-500" />
                </div>
                <input
                  type="text"
                  name="search"
                  id="search"
                  class="block w-full pl-10 pr-3 py-2 border border-slate-600 rounded-lg text-gray-200 placeholder-gray-500 shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                  placeholder="Buscar por nombre, especie..."
                  phx-debounce="300"
                />
              </div>
            </div>
            <div class="flex gap-3">
              <select class="block w-full md:w-auto px-3 py-2 border border-slate-600 rounded-lg shadow-sm focus:outline-none focus:ring-2">
                <option>Todas las especies</option>
                <option>Perros</option>
                <option>Gatos</option>
              </select>
              <select class="block w-full md:w-auto px-3 py-2 border border-slate-600 rounded-lg late-700 text-gray-200 shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-purple-500">
                <option>Cualquier tamaño</option>
                <option>Pequeño</option>
                <option>Mediano</option>
                <option>Grande</option>
              </select>
            </div>
          </div>
        </div>

        <div class="grid grid-cols-1 gap-6">
          <div
            :for={{id, mascota} <- @streams.mascotas}
            id={id}
            class="bg-white dark:bg-slate-800 rounded-2xl shadow-lg dark:shadow-2xl border border-zinc-200 dark:border-slate-700 overflow-hidden"
            phx-click={JS.navigate(~p"/mascotas/#{mascota}")}
          >
            <div class="h-48 rounded-t-2xl flex items-center justify-center relative overflow-hidden">
              <div class="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300">
              </div>
              <.icon
                name="hero-photo"
                class="w-16 h-16 text-slate-600 group-hover:text-purple-400 transition-colors duration-300"
              />
              <div class="absolute top-4 right-4">
                <span class={[
                  "inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold",
                  mascota.sexo == "Macho" && "bg-blue-500/20 text-blue-300",
                  mascota.sexo == "Hembra" && "bg-pink-500/20 text-pink-300",
                  "late-700 text-slate-300"
                ]}>
                  <.icon
                    name={(mascota.sexo == "Macho" && "hero-sparkles") || "hero-heart"}
                    class="w-3 h-3 mr-1"
                  />
                  {mascota.sexo}
                </span>
              </div>
            </div>

            <div class="p-5">
              <div class="flex justify-between items-start mb-3">
                <h3 class="text-xl font-bold text-gray-100 truncate group-hover:text-purple-400 transition-colors duration-300">
                  {mascota.nombre}
                </h3>
                <div class="flex space-x-1 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                  <.link
                    navigate={~p"/mascotas/#{mascota}/editar"}
                    class="p-2 text-blue-400 hover:text-blue-300 hover:bg-blue-900/50 rounded-lg transition-colors duration-200"
                    phx-click="ignore"
                  >
                    <.icon name="hero-pencil-square" class="w-4 h-4" />
                  </.link>
                  <.link
                    phx-click={JS.push("delete", value: %{id: mascota.id}) |> hide("##{id}")}
                    data-confirm="¿Estás seguro de que quieres eliminar esta mascota?"
                    class="p-2 text-red-400 hover:text-red-300 hover:bg-red-900/50 rounded-lg transition-colors duration-200"
                    phx-click="ignore"
                  >
                    <.icon name="hero-trash" class="w-4 h-4" />
                  </.link>
                </div>
              </div>

              <p class="text-gray-400 text-sm mb-4 line-clamp-2 leading-relaxed">
                {mascota.descripcion || "Sin descripción disponible"}
              </p>

              <div class="grid grid-cols-2 gap-3 text-sm text-gray-300 mb-4">
                <div class="flex items-center late-700 rounded-lg p-2">
                  <.icon name="hero-cake" class="w-4 h-4 mr-2 text-purple-400" />
                  <span class="font-medium">{mascota.edad} años</span>
                </div>
                <div class="flex items-center late-700 rounded-lg p-2">
                  <.icon name="hero-arrows-pointing-out" class="w-4 h-4 mr-2 text-blue-400" />
                  <span class="font-medium">{mascota.tamanio}</span>
                </div>
                <div class="flex items-center late-700 rounded-lg p-2">
                  <.icon name="hero-scale" class="w-4 h-4 mr-2 text-green-400" />
                  <span class="font-medium">{mascota.peso} kg</span>
                </div>
                <div class="flex items-center late-700 rounded-lg p-2">
                  <.icon name="hero-paint-brush" class="w-4 h-4 mr-2 text-orange-400" />
                  <span class="font-medium">{mascota.color.nombre}</span>
                </div>

                <div class="flex items-center late-700 rounded-lg p-2">
                  <.icon name="hero-home" class="w-4 h-4 mr-2 text-cyan-400" />
                  <span class="font-medium">{Mascota.humanize_estado(mascota.estado)}</span>
                </div>
                <div class="flex items-center late-700 rounded-lg p-2">
                  <.icon name="hero-bolt" class="w-4 h-4 mr-2 text-yellow-400" />
                  <span class="font-medium">{Mascota.humanize_energia(mascota.energia)}</span>
                </div>
              </div>

              <div class="flex flex-wrap gap-2 mb-4">
                <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-purple-500/20 text-purple-300 border border-purple-500/30">
                  <.icon name="hero-tag" class="w-3 h-3 mr-1" /> Especie: {mascota.especie.nombre}
                </span>
                <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-green-500/20 text-green-300 border border-green-500/30">
                  <.icon name="hero-arrows-pointing-out" class="w-3 h-3 mr-1" />
                  Raza: {mascota.raza.nombre}
                </span>
              </div>

              <div class="flex justify-between items-center text-xs text-gray-500 border-t border-slate-700 pt-3">
                <div class="flex items-center">
                  <.icon name="hero-user-circle" class="w-4 h-4 mr-1 text-gray-600" />
                  <span>Usuario: {mascota.usuario.email}</span>
                </div>
                <div class="text-gray-600">
                  ID: #{mascota.id}
                </div>
              </div>
            </div>
          </div>
        </div>

        <div
          :if={map_size(@streams.mascotas) == 0}
          class="text-center py-16 late-800 rounded-2xl border-2 border-dashed border-slate-700"
        >
          <.icon name="hero-inbox" class="w-20 h-20 text-slate-600 mx-auto mb-6" />
          <h3 class="text-2xl font-bold text-gray-100 mb-3">¡Aún no hay mascotas!</h3>
          <p class="text-gray-400 mb-6 max-w-md mx-auto leading-relaxed">
            Comienza creando el perfil de tu primera mascota. Comparte su historia y ayuda a encontrarle un hogar amoroso.
          </p>
          <.button
            variant="primary"
            navigate={~p"/mascotas/crear"}
            class="bg-gradient-to-r from-pink-500 to-purple-600 hover:from-pink-600 hover:to-purple-700 shadow-lg hover:shadow-xl transition-all duration-300"
          >
            <.icon name="hero-plus" class="w-5 h-5 mr-2" /> Agregar primera mascota
          </.button>
        </div>

        <div class="mt-8 text-center">
          <div class="inline-flex items-center px-4 py-2 late-800 rounded-full shadow-sm border border-slate-700">
            <.icon name="hero-heart" class="w-5 h-5 mr-2 text-pink-500" />
            <span class="text-sm font-medium text-gray-300">
              Mostrando <span class="font-bold text-purple-400">{map_size(@streams.mascotas)}</span>
              mascotas
            </span>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Mascotas.subscribe_mascotas(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Mascotas")
     |> stream(:mascotas, list_mascotas(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    mascota = Mascotas.get_mascota!(socket.assigns.current_scope, id)
    {:ok, _} = Mascotas.delete_mascota(socket.assigns.current_scope, mascota)

    {:noreply, stream_delete(socket, :mascotas, mascota)}
  end

  @impl true
  def handle_info({type, %Pets.Mascotas.Mascota{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :mascotas, list_mascotas(socket.assigns.current_scope), reset: true)}
  end

  defp list_mascotas(current_scope) do
    Mascotas.list_mascotas()
  end
end
