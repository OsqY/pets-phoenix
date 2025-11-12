defmodule Pets.Adopciones do
  @moduledoc """
  The Adopciones context.
  """

  import Ecto.Query, warn: false
  alias Pets.Cuentas.Usuario
  alias Pets.Mascotas.Mascota
  alias Pets.Repo

  alias Pets.Adopciones.SolicitudAdopcion
  alias Pets.Cuentas.Scope

  @doc """
  Subscribes to scoped notifications about any solicitud_adopcion changes.

  The broadcasted messages match the pattern:

    * {:created, %SolicitudAdopcion{}}
    * {:updated, %SolicitudAdopcion{}}
    * {:deleted, %SolicitudAdopcion{}}

  """
  def subscribe_solicitudes_adopcion(%Scope{} = scope) do
    key = scope.usuario.id

    Phoenix.PubSub.subscribe(Pets.PubSub, "usuario:#{key}:solicitudes_adopcion")
  end

  defp broadcast_solicitud_adopcion(%Scope{} = scope, message) do
    key = scope.usuario.id

    Phoenix.PubSub.broadcast(Pets.PubSub, "usuario:#{key}:solicitudes_adopcion", message)
  end

  @doc """
  Returns the list of solicitudes_adopcion.

  ## Examples

      iex> list_solicitudes_adopcion(scope)
      [%SolicitudAdopcion{}, ...]

  """
  def list_solicitudes_adopcion_adoptante(%Scope{} = scope) do
    mascota_query = from m in Mascota, select: [:id, :nombre]

    Repo.all(
      from s in SolicitudAdopcion,
        where: s.adoptante_id == ^scope.usuario.id,
        preload: [mascota: ^mascota_query]
    )
  end

  def list_solicitudes_adopcion_refugio(%Scope{} = scope) do
    mascota_query = from m in Mascota, select: [:id, :nombre]
    adoptante_query = from u in Usuario, select: [:id, :email]

    Repo.all(
      from s in SolicitudAdopcion,
        where: s.refugio_id == ^scope.usuario.id,
        preload: [adoptante: ^adoptante_query, mascota: ^mascota_query]
    )
  end

  @doc """
  Gets a single solicitud_adopcion.

  Raises `Ecto.NoResultsError` if the Solicitud adopcion does not exist.

  ## Examples

      iex> get_solicitud_adopcion!(scope, 123)
      %SolicitudAdopcion{}

      iex> get_solicitud_adopcion!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_solicitud_adopcion!(%Scope{} = scope, id) do
    Repo.one(
      from s in SolicitudAdopcion,
        where:
          s.id == ^id and
            (s.refugio_id == ^scope.usuario.id or s.adoptante_id == ^scope.usuario.id),
        preload: [:mascota, :adoptante, :refugio]
    )
  end

  def get_solicitud_by_scope(%Scope{} = scope, mascota_id) do
    Repo.one(
      from s in SolicitudAdopcion,
        where: s.adoptante_id == ^scope.usuario.id and s.mascota_id == ^mascota_id
    )
  end

  @doc """
  Creates a solicitud_adopcion.

  ## Examples

      iex> create_solicitud_adopcion(scope, %{field: value})
      {:ok, %SolicitudAdopcion{}}

      iex> create_solicitud_adopcion(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_solicitud_adopcion(%Scope{} = scope, attrs) do
    true = attrs["refugio_id"] != scope.usuario.id

    with {:ok, solicitud_adopcion = %SolicitudAdopcion{}} <-
           %SolicitudAdopcion{}
           |> SolicitudAdopcion.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_solicitud_adopcion(scope, {:created, solicitud_adopcion})
      {:ok, solicitud_adopcion}
    end
  end

  @doc """
  Updates a solicitud_adopcion.

  ## Examples

      iex> update_solicitud_adopcion(scope, solicitud_adopcion, %{field: new_value})
      {:ok, %SolicitudAdopcion{}}

      iex> update_solicitud_adopcion(scope, solicitud_adopcion, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_solicitud_adopcion(
        %Scope{} = scope,
        %SolicitudAdopcion{} = solicitud_adopcion,
        attrs
      ) do
    true = solicitud_adopcion.adoptante_id == scope.usuario.id

    with {:ok, solicitud_adopcion = %SolicitudAdopcion{}} <-
           solicitud_adopcion
           |> SolicitudAdopcion.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_solicitud_adopcion(scope, {:updated, solicitud_adopcion})
      {:ok, solicitud_adopcion}
    end
  end

  @doc """
  Deletes a solicitud_adopcion.

  ## Examples

      iex> delete_solicitud_adopcion(scope, solicitud_adopcion)
      {:ok, %SolicitudAdopcion{}}

      iex> delete_solicitud_adopcion(scope, solicitud_adopcion)
      {:error, %Ecto.Changeset{}}

  """
  def delete_solicitud_adopcion(%Scope{} = scope, %SolicitudAdopcion{} = solicitud_adopcion) do
    true = solicitud_adopcion.adoptante_id == scope.usuario.id

    with {:ok, solicitud_adopcion = %SolicitudAdopcion{}} <-
           Repo.delete(solicitud_adopcion) do
      broadcast_solicitud_adopcion(scope, {:deleted, solicitud_adopcion})
      {:ok, solicitud_adopcion}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking solicitud_adopcion changes.

  ## Examples

      iex> change_solicitud_adopcion(scope, solicitud_adopcion)
      %Ecto.Changeset{data: %SolicitudAdopcion{}}

  """
  def change_solicitud_adopcion(
        %Scope{} = scope,
        %SolicitudAdopcion{} = solicitud_adopcion,
        attrs \\ %{}
      ) do
    true = solicitud_adopcion.adoptante_id == scope.usuario.id

    SolicitudAdopcion.changeset(solicitud_adopcion, attrs, scope)
  end

  alias Pets.Adopciones.Seguimiento
  alias Pets.Cuentas.Scope

  @doc """
  Subscribes to scoped notifications about any seguimiento changes.

  The broadcasted messages match the pattern:

    * {:created, %Seguimiento{}}
    * {:updated, %Seguimiento{}}
    * {:deleted, %Seguimiento{}}

  """
  def subscribe_seguimientos(%Scope{} = scope) do
    key = scope.usuario.id

    Phoenix.PubSub.subscribe(Pets.PubSub, "usuario:#{key}:seguimientos")
  end

  defp broadcast_seguimiento(%Scope{} = scope, message) do
    key = scope.usuario.id

    Phoenix.PubSub.broadcast(Pets.PubSub, "usuario:#{key}:seguimientos", message)
  end

  @doc """
  Returns the list of seguimientos.

  ## Examples

      iex> list_seguimientos(scope)
      [%Seguimiento{}, ...]

  """
  def list_seguimientos(%Scope{} = scope) do
    Repo.all_by(Seguimiento, responsable_id: scope.usuario.id)
  end

  def list_seguimientos_adoptante(%Scope{} = scope) do
    Repo.all_by(Seguimiento, usuario_id: scope.usuario.id)
  end

  @doc """
  Gets a single seguimiento.

  Raises `Ecto.NoResultsError` if the Seguimiento does not exist.

  ## Examples

      iex> get_seguimiento!(scope, 123)
      %Seguimiento{}

      iex> get_seguimiento!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_seguimiento!(%Scope{} = scope, id) do
    Repo.get_by!(Seguimiento, id: id, usuario_id: scope.usuario.id)
  end

  @doc """
  Creates a seguimiento.

  ## Examples

      iex> create_seguimiento(scope, %{field: value})
      {:ok, %Seguimiento{}}

      iex> create_seguimiento(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_seguimiento(%Scope{} = scope, attrs) do
    with {:ok, seguimiento = %Seguimiento{}} <-
           %Seguimiento{}
           |> Seguimiento.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_seguimiento(scope, {:created, seguimiento})
      {:ok, seguimiento}
    end
  end

  @doc """
  Updates a seguimiento.

  ## Examples

      iex> update_seguimiento(scope, seguimiento, %{field: new_value})
      {:ok, %Seguimiento{}}

      iex> update_seguimiento(scope, seguimiento, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_seguimiento(%Scope{} = scope, %Seguimiento{} = seguimiento, attrs) do
    true = seguimiento.responsable_id == scope.usuario.id

    with {:ok, seguimiento = %Seguimiento{}} <-
           seguimiento
           |> Seguimiento.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_seguimiento(scope, {:updated, seguimiento})
      {:ok, seguimiento}
    end
  end

  @doc """
  Deletes a seguimiento.

  ## Examples

      iex> delete_seguimiento(scope, seguimiento)
      {:ok, %Seguimiento{}}

      iex> delete_seguimiento(scope, seguimiento)
      {:error, %Ecto.Changeset{}}

  """
  def delete_seguimiento(%Scope{} = scope, %Seguimiento{} = seguimiento) do
    true = seguimiento.responsable_id == scope.usuario.id

    with {:ok, seguimiento = %Seguimiento{}} <-
           Repo.delete(seguimiento) do
      broadcast_seguimiento(scope, {:deleted, seguimiento})
      {:ok, seguimiento}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking seguimiento changes.

  ## Examples

      iex> change_seguimiento(scope, seguimiento)
      %Ecto.Changeset{data: %Seguimiento{}}

  """
  def change_seguimiento(%Scope{} = scope, %Seguimiento{} = seguimiento, attrs \\ %{}) do
    true = seguimiento.responsable_id == scope.usuario.id

    Seguimiento.changeset(seguimiento, attrs, scope)
  end
end
