defmodule PetsWeb.MascotaLive.Show do
  alias Pets.Adopciones
  use PetsWeb, :live_view

  alias Pets.Mascotas

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-6xl mx-auto">
        <.header>
          {@mascota.nombre}
          <:subtitle>{@mascota.descripcion}</:subtitle>
          <:actions>
            <.button navigate={~p"/mascotas"}>
              <.icon name="hero-arrow-left" />
            </.button>
            <%= if @current_scope.usuario.id == @mascota.usuario_id do %>
              <.button variant="primary" navigate={~p"/mascotas/#{@mascota}/editar?return_to=show"}>
                <.icon name="hero-pencil-square" /> Editar mascota
              </.button>
            <% end %>
          </:actions>
        </.header>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mt-8">
          <div class="space-y-4">
            <%= if length(@mascota.imagenes) > 0 do %>
              <div
                id="carousel-container"
                class="relative rounded-xl overflow-hidden bg-gray-100 dark:bg-gray-800 aspect-square"
                phx-hook="ImageCarousel"
              >
                <div id="carousel-track" class="relative w-full h-full">
                  <%= for {imagen, index} <- Enum.with_index(@mascota.imagenes) do %>
                    <div
                      class={"absolute inset-0 transition-opacity duration-500 #{if index == @current_image_index, do: "opacity-100 z-10", else: "opacity-0 z-0"}"}
                      data-index={index}
                    >
                      <img
                        src={imagen.url || "/placeholder.svg"}
                        alt={"Imagen de #{@mascota.nombre}"}
                        class="w-full h-full object-cover"
                      />
                    </div>
                  <% end %>
                </div>

                <%= if length(@mascota.imagenes) > 1 do %>
                  <button
                    type="button"
                    phx-click="prev_image"
                    class="absolute left-4 top-1/2 -translate-y-1/2 bg-white/90 dark:bg-gray-900/90 p-3 rounded-full hover:bg-white dark:hover:bg-gray-900 transition-colors shadow-lg z-20"
                  >
                    <.icon name="hero-chevron-left" class="w-6 h-6" />
                  </button>

                  <button
                    type="button"
                    phx-click="next_image"
                    class="absolute right-4 top-1/2 -translate-y-1/2 bg-white/90 dark:bg-gray-900/90 p-3 rounded-full hover:bg-white dark:hover:bg-gray-900 transition-colors shadow-lg z-20"
                  >
                    <.icon name="hero-chevron-right" class="w-6 h-6" />
                  </button>

                  <div class="absolute bottom-4 left-1/2 -translate-x-1/2 flex gap-2 z-20">
                    <%= for index <- 0..(length(@mascota.imagenes) - 1) do %>
                      <button
                        type="button"
                        phx-click="go_to_image"
                        phx-value-index={index}
                        class={"w-2 h-2 rounded-full transition-all #{if index == @current_image_index, do: "bg-white w-8", else: "bg-white/50 hover:bg-white/75"}"}
                      />
                    <% end %>
                  </div>
                <% end %>
              </div>

              <%= if length(@mascota.imagenes) > 1 do %>
                <div class="grid grid-cols-4 md:grid-cols-5 gap-2">
                  <%= for {imagen, index} <- Enum.with_index(@mascota.imagenes) do %>
                    <button
                      type="button"
                      phx-click="go_to_image"
                      phx-value-index={index}
                      class={"rounded-lg overflow-hidden border-2 transition-all #{if index == @current_image_index, do: "border-blue-500 ring-2 ring-blue-300", else: "border-gray-300 dark:border-gray-600 hover:border-blue-300"}"}
                    >
                      <img
                        src={imagen.url || "/placeholder.svg"}
                        alt={"Miniatura #{index + 1}"}
                        class="w-full h-20 object-cover"
                      />
                    </button>
                  <% end %>
                </div>
              <% end %>
            <% else %>
              <div class="rounded-xl bg-gray-100 dark:bg-gray-800 aspect-square flex items-center justify-center">
                <div class="text-center text-gray-500 dark:text-gray-400">
                  <.icon name="hero-photo" class="w-24 h-24 mx-auto mb-4 opacity-50" />
                  <p class="text-lg font-medium">Sin imágenes</p>
                </div>
              </div>
            <% end %>
          </div>

          <div class="space-y-6">
            <!-- Estado y Energía - Badges destacados -->
            <div class="flex flex-wrap gap-3">
              <span class={"inline-flex items-center gap-2 px-4 py-2 rounded-full text-sm font-semibold #{estado_badge_class(@mascota.estado)}"}>
                <.icon name="hero-heart" class="w-4 h-4" />
                {humanize_estado(@mascota.estado)}
              </span>
              <span class={"inline-flex items-center gap-2 px-4 py-2 rounded-full text-sm font-semibold #{energia_badge_class(@mascota.energia)}"}>
                <.icon name="hero-bolt" class="w-4 h-4" />
                Energía: {humanize_energia(@mascota.energia)}
              </span>
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-4">
                <div class="text-sm text-gray-500 dark:text-gray-400 mb-1">Edad</div>
                <div class="text-2xl font-bold">{@mascota.edad} años</div>
              </div>

              <div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-4">
                <div class="text-sm text-gray-500 dark:text-gray-400 mb-1">Peso</div>
                <div class="text-2xl font-bold">{@mascota.peso} kg</div>
              </div>

              <div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-4">
                <div class="text-sm text-gray-500 dark:text-gray-400 mb-1">Sexo</div>
                <div class="text-lg font-semibold">{@mascota.sexo}</div>
              </div>

              <div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-4">
                <div class="text-sm text-gray-500 dark:text-gray-400 mb-1">Tamaño</div>
                <div class="text-lg font-semibold">{@mascota.tamanio}</div>
              </div>
            </div>

            <div class="border border-gray-200 dark:border-gray-700 rounded-lg divide-y divide-gray-200 dark:divide-gray-700">
              <div class="p-4">
                <div class="text-sm font-medium text-gray-500 dark:text-gray-400">Especie y Raza</div>
                <div class="mt-1 text-base">{@mascota.especie.nombre} - {@mascota.raza.nombre}</div>
              </div>

              <div class="p-4">
                <div class="text-sm font-medium text-gray-500 dark:text-gray-400">Color</div>
                <div class="mt-1 text-base">{@mascota.color.nombre}</div>
              </div>

              <div class="p-4">
                <div class="text-sm font-medium text-gray-500 dark:text-gray-400 mb-2">
                  Comportamiento Social
                </div>
                <div class="space-y-2">
                  <div class="flex items-center gap-2">
                    <%= if @mascota.sociable_mascotas do %>
                      <.icon name="hero-check-circle" class="w-5 h-5 text-green-500" />
                      <span>Amigable con otras mascotas</span>
                    <% else %>
                      <.icon name="hero-x-circle" class="w-5 h-5 text-red-500" />
                      <span>No es amigable con otras mascotas</span>
                    <% end %>
                  </div>
                  <div class="flex items-center gap-2">
                    <%= if @mascota.sociable_personas do %>
                      <.icon name="hero-check-circle" class="w-5 h-5 text-green-500" />
                      <span>Amigable con personas</span>
                    <% else %>
                      <.icon name="hero-x-circle" class="w-5 h-5 text-red-500" />
                      <span>No es amigable con personas</span>
                    <% end %>
                  </div>
                </div>
              </div>

              <%= if @mascota.historia && String.trim(@mascota.historia) != "" do %>
                <div class="p-4">
                  <div class="text-sm font-medium text-gray-500 dark:text-gray-400 mb-2">
                    Historia
                  </div>
                  <div class="text-base leading-relaxed">{@mascota.historia}</div>
                </div>
              <% end %>

              <%= if @mascota.necesidades_especiales && String.trim(@mascota.necesidades_especiales) != "" do %>
                <div class="p-4 bg-blue-50 dark:bg-blue-900/20">
                  <div class="text-sm font-medium text-blue-700 dark:text-blue-300 mb-2 flex items-center gap-2">
                    <.icon name="hero-information-circle" class="w-5 h-5" /> Necesidades Especiales
                  </div>
                  <div class="text-base text-blue-900 dark:text-blue-100">
                    {@mascota.necesidades_especiales}
                  </div>
                </div>
              <% end %>

              <div class="p-4">
                <div class="text-sm font-medium text-gray-500 dark:text-gray-400">Responsable</div>
                <div class="mt-1 text-base">{@mascota.usuario.email}</div>
              </div>
            </div>

            <%= if can_adopt?(@current_scope, @mascota) && !@solicitud_creada do %>
              <.button
                phx-click="create_solicitud"
                phx-value-id={@mascota.id}
                variant="primary"
                class="w-full py-4 text-lg font-semibold"
              >
                <.icon name="hero-heart" class="w-5 h-5" /> Solicitar Adopción
              </.button>
            <% end %>

            <%= if @solicitud_creada do %>
              <div class="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg p-4 text-center">
                <.icon
                  name="hero-check-circle"
                  class="w-8 h-8 text-green-600 dark:text-green-400 mx-auto mb-2"
                />
                <p class="font-medium text-green-900 dark:text-green-100">
                  Ya has enviado una solicitud de adopción
                </p>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp estado_badge_class(:EnAdopcion),
    do: "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300"

  defp estado_badge_class(:ConHogar),
    do: "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300"

  defp estado_badge_class(:Adoptado),
    do: "bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-300"

  defp estado_badge_class(:EnProcesoAdopcion),
    do: "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300"

  defp estado_badge_class(_), do: "bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-300"

  defp energia_badge_class(:Alta),
    do: "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300"

  defp energia_badge_class(:Media),
    do: "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300"

  defp energia_badge_class(:Baja),
    do: "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300"

  defp energia_badge_class(_), do: "bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-300"

  defp humanize_estado(atom) do
    Pets.Mascotas.Mascota.humanize_estado(atom)
  end

  defp humanize_energia(atom) do
    Pets.Mascotas.Mascota.humanize_energia(atom)
  end

  defp can_adopt?(nil, _), do: false

  defp can_adopt?(scope, mascota) do
    mascota.estado == :EnAdopcion && mascota.usuario_id != scope.usuario.id &&
      "refugio" not in scope.usuario.roles
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Mascotas.subscribe_mascotas(socket.assigns.current_scope)
    end

    solicitud_creada =
      if Adopciones.get_solicitud_by_scope(socket.assigns.current_scope, id),
        do: true,
        else: false

    {:ok,
     socket
     |> assign(:solicitud_creada, solicitud_creada)
     |> assign(:page_title, "Ver Mascota")
     |> assign(:current_image_index, 0)
     |> assign(:mascota, Mascotas.get_mascota_for_show!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_event("next_image", _params, socket) do
    total_images = length(socket.assigns.mascota.imagenes)
    new_index = rem(socket.assigns.current_image_index + 1, total_images)
    {:noreply, assign(socket, :current_image_index, new_index)}
  end

  @impl true
  def handle_event("prev_image", _params, socket) do
    total_images = length(socket.assigns.mascota.imagenes)
    new_index = rem(socket.assigns.current_image_index - 1 + total_images, total_images)
    {:noreply, assign(socket, :current_image_index, new_index)}
  end

  @impl true
  def handle_event("go_to_image", %{"index" => index}, socket) do
    {:noreply, assign(socket, :current_image_index, String.to_integer(index))}
  end

  @impl true
  def handle_info(
        {:updated, %Pets.Mascotas.Mascota{id: id} = mascota},
        %{assigns: %{mascota: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :mascota, mascota)}
  end

  def handle_info(
        {:deleted, %Pets.Mascotas.Mascota{id: id}},
        %{assigns: %{mascota: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "La mascota fue eliminada.")
     |> push_navigate(to: ~p"/mascotas")}
  end

  def handle_info({type, %Pets.Mascotas.Mascota{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end

  @impl true
  def handle_event("create_solicitud", %{"id" => id}, socket) do
    if Adopciones.get_solicitud_by_scope(socket.assigns.current_scope, id) do
      {:error, socket |> put_flash(:error, "Ya existe solicitud.")}
    end

    if Adopciones.create_solicitud_adopcion(socket.assigns.current_scope, %{
         estado: :pendiente,
         fecha_solicitud: NaiveDateTime.utc_now(),
         adoptante_id: socket.assigns.current_scope.usuario.id,
         mascota_id: id,
         refugio_id: socket.assigns.mascota.usuario_id
       }) do
      {:noreply,
       socket
       |> put_flash(:success, "Solicitud Creada con éxito")
       |> assign(:solicitud_creada, true)}
    end
  end
end
