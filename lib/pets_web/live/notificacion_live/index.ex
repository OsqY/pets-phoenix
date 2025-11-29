defmodule PetsWeb.NotificacionLive.Index do
  use PetsWeb, :live_view

  alias Pets.Chats

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-3xl mx-auto">
        <div class="flex items-center justify-between mb-8">
          <div>
            <h1 class="text-2xl font-bold text-gray-900 dark:text-gray-100">
              Notificaciones
            </h1>
            <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">
              Mantente al día con tu actividad
            </p>
          </div>

          <%= if @unread_count > 0 do %>
            <button
              type="button"
              class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-indigo-600 dark:text-indigo-400 hover:text-indigo-800 dark:hover:text-indigo-300 hover:bg-indigo-50 dark:hover:bg-indigo-900/20 rounded-lg transition-colors"
              phx-click="mark_all_read"
            >
              <.icon name="hero-check-circle" class="w-5 h-5" />
              Marcar todas como leídas
            </button>
          <% end %>
        </div>

        <%= if @notificaciones == [] do %>
          <div class="bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-800 rounded-xl p-12 text-center">
            <.icon name="hero-bell-slash" class="w-16 h-16 text-gray-300 dark:text-gray-600 mx-auto mb-4" />
            <h3 class="text-lg font-medium text-gray-900 dark:text-gray-100 mb-2">
              No tienes notificaciones
            </h3>
            <p class="text-sm text-gray-500 dark:text-gray-400">
              Cuando recibas notificaciones, aparecerán aquí
            </p>
          </div>
        <% else %>
          <div class="bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-800 rounded-xl overflow-hidden divide-y divide-gray-100 dark:divide-gray-800">
            <%= for notificacion <- @notificaciones do %>
              <div
                class={[
                  "flex items-start gap-4 p-4 hover:bg-gray-50 dark:hover:bg-gray-800/50 transition-colors cursor-pointer",
                  !notificacion.leida && "bg-indigo-50/50 dark:bg-indigo-900/10"
                ]}
                phx-click="click_notificacion"
                phx-value-id={notificacion.id}
              >
                <div class={[
                  "flex-shrink-0 w-10 h-10 rounded-full flex items-center justify-center",
                  notification_icon_bg(notificacion.tipo)
                ]}>
                  <.icon name={notification_icon(notificacion.tipo)} class="w-5 h-5 text-white" />
                </div>

                <div class="flex-1 min-w-0">
                  <p class={[
                    "text-sm",
                    if(notificacion.leida,
                      do: "text-gray-600 dark:text-gray-400",
                      else: "text-gray-900 dark:text-gray-100 font-medium"
                    )
                  ]}>
                    {notificacion.contenido}
                  </p>
                  <div class="flex items-center gap-3 mt-1">
                    <p class="text-xs text-gray-400 dark:text-gray-500">
                      {format_time(notificacion.inserted_at)}
                    </p>
                    <span class={[
                      "inline-flex items-center px-2 py-0.5 rounded text-xs font-medium",
                      notification_badge_class(notificacion.tipo)
                    ]}>
                      {format_tipo(notificacion.tipo)}
                    </span>
                  </div>
                </div>

                <div class="flex items-center gap-2">
                  <%= if !notificacion.leida do %>
                    <div class="w-2 h-2 bg-indigo-500 rounded-full"></div>
                  <% end %>
                  <button
                    type="button"
                    class="p-1 text-gray-400 hover:text-red-500 dark:hover:text-red-400 transition-colors"
                    phx-click="delete"
                    phx-value-id={notificacion.id}
                    title="Eliminar notificación"
                  >
                    <.icon name="hero-trash" class="w-4 h-4" />
                  </button>
                </div>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Chats.subscribe_notificaciones(socket.assigns.current_scope)
    end

    notificaciones = Chats.list_notificaciones(socket.assigns.current_scope)
    unread_count = Chats.count_notificaciones_no_leidas(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "Notificaciones")
     |> assign(:notificaciones, notificaciones)
     |> assign(:unread_count, unread_count)}
  end

  @impl true
  def handle_event("mark_all_read", _, socket) do
    Chats.marcar_todas_como_leidas(socket.assigns.current_scope)

    notificaciones =
      Enum.map(socket.assigns.notificaciones, fn n -> %{n | leida: true} end)

    {:noreply, assign(socket, notificaciones: notificaciones, unread_count: 0)}
  end

  def handle_event("click_notificacion", %{"id" => id}, socket) do
    notificacion_id = String.to_integer(id)
    {:ok, notificacion} = Chats.marcar_como_leida(socket.assigns.current_scope, notificacion_id)

    notificaciones =
      Enum.map(socket.assigns.notificaciones, fn n ->
        if n.id == notificacion_id, do: %{n | leida: true}, else: n
      end)

    unread_count = max(socket.assigns.unread_count - 1, 0)

    socket =
      socket
      |> assign(notificaciones: notificaciones, unread_count: unread_count)
      |> maybe_navigate(notificacion)

    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    notificacion = Chats.get_notificacion!(socket.assigns.current_scope, String.to_integer(id))
    {:ok, _} = Chats.delete_notificacion(socket.assigns.current_scope, notificacion)

    notificaciones = Enum.reject(socket.assigns.notificaciones, fn n -> n.id == notificacion.id end)
    unread_count = if notificacion.leida, do: socket.assigns.unread_count, else: max(socket.assigns.unread_count - 1, 0)

    {:noreply, assign(socket, notificaciones: notificaciones, unread_count: unread_count)}
  end

  @impl true
  def handle_info({:created, notificacion}, socket) do
    notificaciones = [notificacion | socket.assigns.notificaciones]
    unread_count = socket.assigns.unread_count + 1

    {:noreply, assign(socket, notificaciones: notificaciones, unread_count: unread_count)}
  end

  def handle_info({:updated, updated_notificacion}, socket) do
    notificaciones =
      Enum.map(socket.assigns.notificaciones, fn n ->
        if n.id == updated_notificacion.id, do: updated_notificacion, else: n
      end)

    {:noreply, assign(socket, notificaciones: notificaciones)}
  end

  def handle_info({:deleted, deleted_notificacion}, socket) do
    notificaciones = Enum.reject(socket.assigns.notificaciones, fn n -> n.id == deleted_notificacion.id end)
    {:noreply, assign(socket, notificaciones: notificaciones)}
  end

  def handle_info(:all_read, socket) do
    notificaciones = Enum.map(socket.assigns.notificaciones, fn n -> %{n | leida: true} end)
    {:noreply, assign(socket, notificaciones: notificaciones, unread_count: 0)}
  end

  defp maybe_navigate(socket, notificacion) do
    case {notificacion.referencia_tipo, notificacion.referencia_id} do
      {"solicitud_adopcion", _id} ->
        push_navigate(socket, to: ~p"/solicitudes-adopcion")

      {"conversacion", id} when not is_nil(id) ->
        push_navigate(socket, to: ~p"/chats/#{id}")

      {"post", _id} ->
        push_navigate(socket, to: ~p"/posts")

      _ ->
        socket
    end
  end

  defp notification_icon(tipo) do
    case tipo do
      "solicitud_adopcion" -> "hero-heart"
      "cambio_estado_solicitud" -> "hero-check-circle"
      "mensaje_chat" -> "hero-chat-bubble-left-right"
      "comentario_post" -> "hero-chat-bubble-bottom-center-text"
      "like_post" -> "hero-hand-thumb-up"
      _ -> "hero-bell"
    end
  end

  defp notification_icon_bg(tipo) do
    case tipo do
      "solicitud_adopcion" -> "bg-pink-500"
      "cambio_estado_solicitud" -> "bg-green-500"
      "mensaje_chat" -> "bg-blue-500"
      "comentario_post" -> "bg-purple-500"
      "like_post" -> "bg-red-500"
      _ -> "bg-gray-500"
    end
  end

  defp notification_badge_class(tipo) do
    case tipo do
      "solicitud_adopcion" -> "bg-pink-100 text-pink-800 dark:bg-pink-900/30 dark:text-pink-300"
      "cambio_estado_solicitud" -> "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300"
      "mensaje_chat" -> "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300"
      "comentario_post" -> "bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-300"
      "like_post" -> "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300"
      _ -> "bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300"
    end
  end

  defp format_tipo(tipo) do
    case tipo do
      "solicitud_adopcion" -> "Solicitud"
      "cambio_estado_solicitud" -> "Estado"
      "mensaje_chat" -> "Mensaje"
      "comentario_post" -> "Comentario"
      "like_post" -> "Like"
      _ -> "General"
    end
  end

  defp format_time(datetime) do
    now = DateTime.utc_now()
    diff = DateTime.diff(now, datetime, :second)

    cond do
      diff < 60 -> "Hace un momento"
      diff < 3600 -> "Hace #{div(diff, 60)} min"
      diff < 86400 -> "Hace #{div(diff, 3600)} h"
      diff < 604_800 -> "Hace #{div(diff, 86400)} días"
      true -> Calendar.strftime(datetime, "%d/%m/%Y")
    end
  end
end
