defmodule PetsWeb.Components.Notificaciones do
  @moduledoc """
  Componente funcional para mostrar el dropdown de notificaciones en el header.
  """
  use Phoenix.Component
  use PetsWeb, :verified_routes

  import PetsWeb.CoreComponents

  alias Pets.Chats

  attr :current_scope, :map, required: true

  def notificaciones_dropdown(assigns) do
    {notificaciones, unread_count} =
      if assigns.current_scope do
        notifs = Chats.list_notificaciones(assigns.current_scope) |> Enum.take(10)
        count = Chats.count_notificaciones_no_leidas(assigns.current_scope)
        {notifs, count}
      else
        {[], 0}
      end

    assigns =
      assigns
      |> assign(:notificaciones, notificaciones)
      |> assign(:unread_count, unread_count)

    ~H"""
    <div class="relative" id="notificaciones-dropdown" phx-hook="NotificacionesDropdown">
      <button
        type="button"
        class="relative flex items-center justify-center w-10 h-10 text-gray-700 dark:text-gray-300 hover:text-gray-900 dark:hover:text-gray-100 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors"
        phx-click={toggle_dropdown()}
      >
        <.icon name="hero-bell" class="w-5 h-5" />
        <%= if @unread_count > 0 do %>
          <span class="absolute -top-0.5 -right-0.5 flex items-center justify-center min-w-[18px] h-[18px] px-1 text-xs font-bold text-white bg-red-500 rounded-full">
            {if @unread_count > 99, do: "99+", else: @unread_count}
          </span>
        <% end %>
      </button>

      <div
        id="notificaciones-panel"
        class="hidden absolute right-0 mt-2 w-80 sm:w-96 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-xl shadow-xl overflow-hidden z-50"
        phx-click-away={hide_dropdown()}
      >
        <%!-- Header --%>
        <div class="flex items-center justify-between px-4 py-3 border-b border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-900">
          <h3 class="text-sm font-semibold text-gray-900 dark:text-gray-100">
            Notificaciones
          </h3>
          <%= if @unread_count > 0 do %>
            <button
              type="button"
              class="text-xs font-medium text-indigo-600 dark:text-indigo-400 hover:text-indigo-800 dark:hover:text-indigo-300 transition-colors"
              phx-click="mark_all_notifications_read"
            >
              Marcar todas como leídas
            </button>
          <% end %>
        </div>

        <%!-- Lista de notificaciones --%>
        <div class="max-h-96 overflow-y-auto">
          <%= if @notificaciones == [] do %>
            <div class="flex flex-col items-center justify-center py-8 px-4 text-center">
              <.icon name="hero-bell-slash" class="w-12 h-12 text-gray-300 dark:text-gray-600 mb-3" />
              <p class="text-sm text-gray-500 dark:text-gray-400">
                No tienes notificaciones
              </p>
            </div>
          <% else %>
            <div class="divide-y divide-gray-100 dark:divide-gray-700">
              <%= for notificacion <- @notificaciones do %>
                <.link
                  navigate={notificacion_link(notificacion)}
                  class={[
                    "flex items-start gap-3 px-4 py-3 hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors cursor-pointer",
                    !notificacion.leida && "bg-indigo-50/50 dark:bg-indigo-900/20"
                  ]}
                  phx-click="mark_notification_read"
                  phx-value-id={notificacion.id}
                >
                  <div class={[
                    "flex-shrink-0 w-9 h-9 rounded-full flex items-center justify-center",
                    notification_icon_bg(notificacion.tipo)
                  ]}>
                    <.icon name={notification_icon(notificacion.tipo)} class="w-4 h-4 text-white" />
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
                    <p class="text-xs text-gray-400 dark:text-gray-500 mt-1">
                      {format_time(notificacion.inserted_at)}
                    </p>
                  </div>
                  <%= if !notificacion.leida do %>
                    <div class="flex-shrink-0 w-2 h-2 mt-2 bg-indigo-500 rounded-full"></div>
                  <% end %>
                </.link>
              <% end %>
            </div>
          <% end %>
        </div>

        <%!-- Footer --%>
        <%= if @notificaciones != [] do %>
          <div class="px-4 py-3 border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-900">
            <.link
              navigate={~p"/notificaciones"}
              class="block text-center text-sm font-medium text-indigo-600 dark:text-indigo-400 hover:text-indigo-800 dark:hover:text-indigo-300 transition-colors"
            >
              Ver todas las notificaciones
            </.link>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp toggle_dropdown do
    Phoenix.LiveView.JS.toggle(
      to: "#notificaciones-panel",
      in: {"ease-out duration-200", "opacity-0 translate-y-1", "opacity-100 translate-y-0"},
      out: {"ease-in duration-150", "opacity-100 translate-y-0", "opacity-0 translate-y-1"}
    )
  end

  defp hide_dropdown do
    Phoenix.LiveView.JS.hide(
      to: "#notificaciones-panel",
      transition:
        {"ease-in duration-150", "opacity-100 translate-y-0", "opacity-0 translate-y-1"}
    )
  end

  defp notificacion_link(notificacion) do
    case {notificacion.referencia_tipo, notificacion.referencia_id} do
      {"solicitud_adopcion", _id} -> ~p"/solicitudes-adopcion"
      {"conversacion", id} when not is_nil(id) -> ~p"/chats/#{id}"
      {"post", _id} -> ~p"/posts"
      _ -> ~p"/notificaciones"
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
