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
        order_by: [asc: m.fecha_hora]
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
  Subscribes to scoped notifications about any notificacion changes.

  The broadcasted messages match the pattern:

    * {:created, %Notificacion{}}
    * {:updated, %Notificacion{}}
    * {:deleted, %Notificacion{}}

  """
  def subscribe_notificaciones(%Scope{} = scope) do
    key = scope.usuario.id

    Phoenix.PubSub.subscribe(Pets.PubSub, "usuario:#{key}:notificaciones")
  end

  defp broadcast_notificacion(%Scope{} = scope, message) do
    key = scope.usuario.id

    Phoenix.PubSub.broadcast(Pets.PubSub, "usuario:#{key}:notificaciones", message)
  end

  @doc """
  Returns the list of notificaciones.

  ## Examples

      iex> list_notificaciones(scope)
      [%Notificacion{}, ...]

  """
  def list_notificaciones(%Scope{} = scope) do
    Repo.all_by(Notificacion, usuario_id: scope.usuario.id)
  end

  @doc """
  Gets a single notificacion.

  Raises `Ecto.NoResultsError` if the Notificacion does not exist.

  ## Examples

      iex> get_notificacion!(scope, 123)
      %Notificacion{}

      iex> get_notificacion!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_notificacion!(%Scope{} = scope, id) do
    Repo.get_by!(Notificacion, id: id, usuario_id: scope.usuario.id)
  end

  @doc """
  Creates a notificacion.

  ## Examples

      iex> create_notificacion(scope, %{field: value})
      {:ok, %Notificacion{}}

      iex> create_notificacion(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notificacion(%Scope{} = scope, attrs) do
    with {:ok, notificacion = %Notificacion{}} <-
           %Notificacion{}
           |> Notificacion.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_notificacion(scope, {:created, notificacion})
      {:ok, notificacion}
    end
  end

  @doc """
  Updates a notificacion.

  ## Examples

      iex> update_notificacion(scope, notificacion, %{field: new_value})
      {:ok, %Notificacion{}}

      iex> update_notificacion(scope, notificacion, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_notificacion(%Scope{} = scope, %Notificacion{} = notificacion, attrs) do
    true = notificacion.usuario_id == scope.usuario.id

    with {:ok, notificacion = %Notificacion{}} <-
           notificacion
           |> Notificacion.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_notificacion(scope, {:updated, notificacion})
      {:ok, notificacion}
    end
  end

  @doc """
  Deletes a notificacion.

  ## Examples

      iex> delete_notificacion(scope, notificacion)
      {:ok, %Notificacion{}}

      iex> delete_notificacion(scope, notificacion)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notificacion(%Scope{} = scope, %Notificacion{} = notificacion) do
    true = notificacion.usuario_id == scope.usuario.id

    with {:ok, notificacion = %Notificacion{}} <-
           Repo.delete(notificacion) do
      broadcast_notificacion(scope, {:deleted, notificacion})
      {:ok, notificacion}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notificacion changes.

  ## Examples

      iex> change_notificacion(scope, notificacion)
      %Ecto.Changeset{data: %Notificacion{}}

  """
  def change_notificacion(%Scope{} = scope, %Notificacion{} = notificacion, attrs \\ %{}) do
    true = notificacion.usuario_id == scope.usuario.id

    Notificacion.changeset(notificacion, attrs, scope)
  end
end
