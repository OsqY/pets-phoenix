defmodule PetsWeb.ChatHooks do
  @moduledoc """
  Hooks para manejar las suscripciones de chat en todos los LiveViews.
  """

  import Phoenix.LiveView
  import Phoenix.Component

  alias Pets.Chats
  alias Pets.Chats.Conversacion

  def on_mount(:default, _params, _session, socket) do
    # Siempre registrar el hook para capturar mensajes de chat
    socket = attach_hook(socket, :chat_messages, :handle_info, &handle_chat_info/2)

    if connected?(socket) and socket.assigns[:current_scope] do
      # Suscribirse a las conversaciones del usuario
      current_scope = socket.assigns.current_scope

      # Cargar y suscribirse a todas las conversaciones
      chats = Chats.list_conversaciones(current_scope)

      Enum.each(chats, fn chat ->
        Phoenix.PubSub.subscribe(Pets.PubSub, "conversacion:#{chat.id}")
      end)

      # Suscribirse a nuevas conversaciones
      Chats.subscribe_conversaciones(current_scope)

      socket = assign(socket, :chat_subscribed_ids, MapSet.new(Enum.map(chats, & &1.id)))

      {:cont, socket}
    else
      {:cont, assign(socket, :chat_subscribed_ids, MapSet.new())}
    end
  end

  # Manejar nuevos mensajes de chat
  defp handle_chat_info({:new_mensaje, mensaje}, socket) do
    # Reenviar el mensaje al ChatSideBar component
    send_update(PetsWeb.ChatSideBar, id: "chat-sidebar", new_mensaje: mensaje)
    {:halt, socket}
  end

  # Manejar solicitud de suscripción a un chat específico
  defp handle_chat_info({:subscribe_to_chat, chat_id}, socket) do
    subscribed = socket.assigns[:chat_subscribed_ids] || MapSet.new()

    socket =
      if not MapSet.member?(subscribed, chat_id) do
        Phoenix.PubSub.subscribe(Pets.PubSub, "conversacion:#{chat_id}")
        assign(socket, :chat_subscribed_ids, MapSet.put(subscribed, chat_id))
      else
        socket
      end

    {:halt, socket}
  end

  # Manejar creación de nuevas conversaciones
  defp handle_chat_info({:created, %Conversacion{} = conv}, socket) do
    subscribed = socket.assigns[:chat_subscribed_ids] || MapSet.new()

    socket =
      if not MapSet.member?(subscribed, conv.id) do
        Phoenix.PubSub.subscribe(Pets.PubSub, "conversacion:#{conv.id}")
        assign(socket, :chat_subscribed_ids, MapSet.put(subscribed, conv.id))
      else
        socket
      end

    {:halt, socket}
  end

  # Ignorar otros mensajes de conversaciones
  defp handle_chat_info({type, %Conversacion{}}, socket)
       when type in [:updated, :deleted] do
    {:halt, socket}
  end

  # Dejar pasar todos los demás mensajes al LiveView
  defp handle_chat_info(_msg, socket) do
    {:cont, socket}
  end
end
