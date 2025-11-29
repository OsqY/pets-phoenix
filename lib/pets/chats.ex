defmodule Pets.Chats do
  @moduledoc """
  The Chats context.
  """

  import Ecto.Query, warn: false
  alias Pets.Repo
  alias Pets.Chats.Conversacion
  alias Pets.Cuentas.Scope

  @doc """
  Subscribes to scoped notifications about any conversacion changes.

  The broadcasted messages match the pattern:

    * {:created, %Conversacion{}}
    * {:updated, %Conversacion{}}
    * {:deleted, %Conversacion{}}

  """
  def subscribe_conversaciones(%Scope{} = scope) do
    key = scope.usuario.id

    Phoenix.PubSub.subscribe(Pets.PubSub, "usuario:#{key}:conversaciones")
  end

  defp broadcast_conversacion(%Scope{} = scope, message) do
    key = scope.usuario.id

    Phoenix.PubSub.broadcast(Pets.PubSub, "usuario:#{key}:conversaciones", message)
  end

  @doc """
  Returns the list of conversaciones.

  ## Examples

      iex> list_conversaciones(scope)
      [%Conversacion{}, ...]

  """
  def list_conversaciones(%Scope{} = scope) do
    conversacion_query =
      from c in Conversacion,
        where: c.emisor_id == ^scope.usuario.id or c.receptor_id == ^scope.usuario.id,
        preload: [:emisor, :receptor]

    Repo.all(conversacion_query)
  end

  @doc """
  Gets a single conversacion.

  Raises `Ecto.NoResultsError` if the Conversacion does not exist.

  ## Examples

      iex> get_conversacion!(scope, 123)
      %Conversacion{}

      iex> get_conversacion!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_conversacion!(%Scope{} = scope, id) do
    mensaje_query = from e in Mensaje, select: [:id, :contenido]

    conversacion_query =
      from c in Conversacion,
        where:
          c.emisor_id == ^scope.usuario.id or (c.receptor_id == ^scope.usuario.id and c.id == ^id),
        preload: [:emisor, :receptor, mensajes: ^mensaje_query]

    Repo.get_by!(conversacion_query)
  end

  @doc """
  Creates a conversacion.

  ## Examples

      iex> create_conversacion(scope, %{field: value})
      {:ok, %Conversacion{}}

      iex> create_conversacion(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_conversacion(%Scope{} = scope, attrs) do
    with {:ok, conversacion = %Conversacion{}} <-
           %Conversacion{}
           |> Conversacion.changeset(attrs)
           |> Repo.insert() do
      broadcast_conversacion(scope, {:created, conversacion})
      {:ok, conversacion}
    end
  end

  @doc """
  Updates a conversacion.

  ## Examples

      iex> update_conversacion(scope, conversacion, %{field: new_value})
      {:ok, %Conversacion{}}

      iex> update_conversacion(scope, conversacion, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_conversacion(%Scope{} = scope, %Conversacion{} = conversacion, attrs) do
    true = conversacion.usuario_id == scope.usuario.id

    with {:ok, conversacion = %Conversacion{}} <-
           conversacion
           |> Conversacion.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_conversacion(scope, {:updated, conversacion})
      {:ok, conversacion}
    end
  end

  @doc """
  Deletes a conversacion.

  ## Examples

      iex> delete_conversacion(scope, conversacion)
      {:ok, %Conversacion{}}

      iex> delete_conversacion(scope, conversacion)
      {:error, %Ecto.Changeset{}}

  """
  def delete_conversacion(%Scope{} = scope, %Conversacion{} = conversacion) do
    true = conversacion.usuario_id == scope.usuario.id

    with {:ok, conversacion = %Conversacion{}} <-
           Repo.delete(conversacion) do
      broadcast_conversacion(scope, {:deleted, conversacion})
      {:ok, conversacion}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking conversacion changes.

  ## Examples

      iex> change_conversacion(scope, conversacion)
      %Ecto.Changeset{data: %Conversacion{}}

  """
  def change_conversacion(%Scope{} = scope, %Conversacion{} = conversacion, attrs \\ %{}) do
    true = conversacion.usuario_id == scope.usuario.id

    Conversacion.changeset(conversacion, attrs, scope)
  end

  alias Pets.Chats.Mensaje
  alias Pets.Cuentas.Scope

  @doc """
  Subscribes to scoped notifications about any mensaje changes.

  The broadcasted messages match the pattern:

    * {:created, %Mensaje{}}
    * {:updated, %Mensaje{}}
    * {:deleted, %Mensaje{}}

  """
  def subscribe_mensajes(%Scope{} = scope) do
    key = scope.usuario.id

    Phoenix.PubSub.subscribe(Pets.PubSub, "usuario:#{key}:mensajes")
  end

  defp broadcast_mensaje(%Scope{} = scope, message) do
    key = scope.usuario.id

    Phoenix.PubSub.broadcast(Pets.PubSub, "usuario:#{key}:mensajes", message)
  end

  @doc """
  Returns the list of mensajes.

  ## Examples

      iex> list_mensajes(scope)
      [%Mensaje{}, ...]

  """
  def list_mensajes(%Conversacion{} = conversacion) do
    Repo.all(
      from m in Mensaje,
        where: m.conversacion_id == ^conversacion.id,
        preload: [:emisor],
        order_by: [asc: m.inserted_at]
    )
  end

  @doc """
  Gets a single mensaje.

  Raises `Ecto.NoResultsError` if the Mensaje does not exist.

  ## Examples

      iex> get_mensaje!(scope, 123)
      %Mensaje{}

      iex> get_mensaje!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_mensaje!(%Scope{} = scope, id) do
    Repo.get_by!(Mensaje, id: id, usuario_id: scope.usuario.id)
  end

  @doc """
  Creates a mensaje.

  ## Examples

      iex> create_mensaje(scope, %{field: value})
      {:ok, %Mensaje{}}

      iex> create_mensaje(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_mensaje(%Scope{} = scope, attrs) do
    with {:ok, mensaje = %Mensaje{}} <-
           %Mensaje{}
           |> Mensaje.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_mensaje(scope, {:created, mensaje})

      # Notificar al receptor del mensaje
      conversacion = Repo.get!(Conversacion, mensaje.conversacion_id)

      receptor_id =
        if conversacion.emisor_id == scope.usuario.id do
          conversacion.receptor_id
        else
          conversacion.emisor_id
        end

      if receptor_id != scope.usuario.id do
        notificar_mensaje_chat(receptor_id, scope.usuario.email, conversacion.id)
      end

      {:ok, mensaje}
    end
  end

  @doc """
  Updates a mensaje.

  ## Examples

      iex> update_mensaje(scope, mensaje, %{field: new_value})
      {:ok, %Mensaje{}}

      iex> update_mensaje(scope, mensaje, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mensaje(%Scope{} = scope, %Mensaje{} = mensaje, attrs) do
    true = mensaje.usuario_id == scope.usuario.id

    with {:ok, mensaje = %Mensaje{}} <-
           mensaje
           |> Mensaje.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_mensaje(scope, {:updated, mensaje})
      {:ok, mensaje}
    end
  end

  @doc """
  Deletes a mensaje.

  ## Examples

      iex> delete_mensaje(scope, mensaje)
      {:ok, %Mensaje{}}

      iex> delete_mensaje(scope, mensaje)
      {:error, %Ecto.Changeset{}}

  """
  def delete_mensaje(%Scope{} = scope, %Mensaje{} = mensaje) do
    true = mensaje.usuario_id == scope.usuario.id

    with {:ok, mensaje = %Mensaje{}} <-
           Repo.delete(mensaje) do
      broadcast_mensaje(scope, {:deleted, mensaje})
      {:ok, mensaje}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking mensaje changes.

  ## Examples

      iex> change_mensaje(scope, mensaje)
      %Ecto.Changeset{data: %Mensaje{}}

  """
  def change_mensaje(%Scope{} = scope, %Mensaje{} = mensaje, attrs \\ %{}) do
    true = mensaje.usuario_id == scope.usuario.id

    Mensaje.changeset(mensaje, attrs, scope)
  end

  alias Pets.Chats.Notificacion
  alias Pets.Cuentas.Scope

  @doc """
  Subscribes to notifications for a specific user.

  The broadcasted messages match the pattern:

    * {:created, %Notificacion{}}
    * {:updated, %Notificacion{}}
    * {:deleted, %Notificacion{}}

  """
  def subscribe_notificaciones(%Scope{} = scope) do
    Phoenix.PubSub.subscribe(Pets.PubSub, "usuario:#{scope.usuario.id}:notificaciones")
  end

  defp broadcast_notificacion_to_user(usuario_id, message) do
    Phoenix.PubSub.broadcast(Pets.PubSub, "usuario:#{usuario_id}:notificaciones", message)
  end

  @doc """
  Returns the list of notificaciones for the user, ordered by most recent first.
  """
  def list_notificaciones(%Scope{} = scope) do
    from(n in Notificacion,
      where: n.usuario_id == ^scope.usuario.id,
      order_by: [desc: n.inserted_at],
      limit: 50
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of unread notificaciones for the user.
  """
  def list_notificaciones_no_leidas(%Scope{} = scope) do
    from(n in Notificacion,
      where: n.usuario_id == ^scope.usuario.id and n.leida == false,
      order_by: [desc: n.inserted_at]
    )
    |> Repo.all()
  end

  @doc """
  Returns count of unread notifications.
  """
  def count_notificaciones_no_leidas(%Scope{} = scope) do
    from(n in Notificacion,
      where: n.usuario_id == ^scope.usuario.id and n.leida == false,
      select: count(n.id)
    )
    |> Repo.one()
  end

  @doc """
  Gets a single notificacion.

  Raises `Ecto.NoResultsError` if the Notificacion does not exist.
  """
  def get_notificacion!(%Scope{} = scope, id) do
    Repo.get_by!(Notificacion, id: id, usuario_id: scope.usuario.id)
  end

  @doc """
  Creates a notification for a specific user.
  Used internally to notify users about events.
  """
  def create_notificacion(usuario_id, attrs) when is_integer(usuario_id) do
    attrs =
      Map.merge(attrs, %{
        usuario_id: usuario_id,
        fecha: NaiveDateTime.utc_now()
      })

    with {:ok, notificacion = %Notificacion{}} <-
           %Notificacion{}
           |> Notificacion.changeset(attrs)
           |> Repo.insert() do
      broadcast_notificacion_to_user(usuario_id, {:created, notificacion})
      {:ok, notificacion}
    end
  end

  @doc """
  Notifies a user about a new adoption request.
  """
  def notificar_solicitud_adopcion(refugio_id, mascota_nombre, solicitud_id) do
    create_notificacion(refugio_id, %{
      tipo: "solicitud_adopcion",
      contenido: "Nueva solicitud de adopción para #{mascota_nombre}",
      referencia_tipo: "solicitud_adopcion",
      referencia_id: solicitud_id
    })
  end

  @doc """
  Notifies a user about adoption status change.
  """
  def notificar_cambio_estado_solicitud(adoptante_id, mascota_nombre, nuevo_estado, solicitud_id) do
    mensaje =
      case nuevo_estado do
        "aprobada" -> "¡Tu solicitud de adopción para #{mascota_nombre} fue aprobada!"
        "rechazada" -> "Tu solicitud de adopción para #{mascota_nombre} fue rechazada"
        _ -> "El estado de tu solicitud para #{mascota_nombre} cambió a: #{nuevo_estado}"
      end

    create_notificacion(adoptante_id, %{
      tipo: "cambio_estado_solicitud",
      contenido: mensaje,
      referencia_tipo: "solicitud_adopcion",
      referencia_id: solicitud_id
    })
  end

  @doc """
  Notifies a user about a new chat message.
  """
  def notificar_mensaje_chat(receptor_id, emisor_email, conversacion_id) do
    create_notificacion(receptor_id, %{
      tipo: "mensaje_chat",
      contenido: "Nuevo mensaje de #{emisor_email}",
      referencia_tipo: "conversacion",
      referencia_id: conversacion_id
    })
  end

  @doc """
  Notifies a user about a new comment on their post.
  """
  def notificar_comentario_post(post_owner_id, comentador_email, post_id) do
    create_notificacion(post_owner_id, %{
      tipo: "comentario_post",
      contenido: "#{comentador_email} comentó en tu publicación",
      referencia_tipo: "post",
      referencia_id: post_id
    })
  end

  @doc """
  Notifies a user about a new like on their post.
  """
  def notificar_like_post(post_owner_id, liker_email, post_id) do
    create_notificacion(post_owner_id, %{
      tipo: "like_post",
      contenido: "A #{liker_email} le gustó tu publicación",
      referencia_tipo: "post",
      referencia_id: post_id
    })
  end

  @doc """
  Marks a notification as read.
  """
  def marcar_como_leida(%Scope{} = scope, notificacion_id) do
    notificacion = get_notificacion!(scope, notificacion_id)

    with {:ok, notificacion = %Notificacion{}} <-
           notificacion
           |> Notificacion.mark_as_read_changeset()
           |> Repo.update() do
      broadcast_notificacion_to_user(scope.usuario.id, {:updated, notificacion})
      {:ok, notificacion}
    end
  end

  @doc """
  Marks all notifications as read for a user.
  """
  def marcar_todas_como_leidas(%Scope{} = scope) do
    from(n in Notificacion,
      where: n.usuario_id == ^scope.usuario.id and n.leida == false
    )
    |> Repo.update_all(set: [leida: true])

    broadcast_notificacion_to_user(scope.usuario.id, :all_read)
    :ok
  end

  @doc """
  Deletes a notificacion.
  """
  def delete_notificacion(%Scope{} = scope, %Notificacion{} = notificacion) do
    true = notificacion.usuario_id == scope.usuario.id

    with {:ok, notificacion = %Notificacion{}} <- Repo.delete(notificacion) do
      broadcast_notificacion_to_user(scope.usuario.id, {:deleted, notificacion})
      {:ok, notificacion}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notificacion changes.
  """
  def change_notificacion(%Notificacion{} = notificacion, attrs \\ %{}) do
    Notificacion.changeset(notificacion, attrs)
  end
end
