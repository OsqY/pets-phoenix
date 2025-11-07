defmodule Pets.Refugios do
  @moduledoc """
  The Refugios context.
  """

  import Ecto.Query, warn: false
  alias Pets.Repo

  alias Pets.Refugios.ItemInventario
  alias Pets.Cuentas.Scope

  @doc """
  Subscribes to scoped notifications about any item_inventario changes.

  The broadcasted messages match the pattern:

    * {:created, %ItemInventario{}}
    * {:updated, %ItemInventario{}}
    * {:deleted, %ItemInventario{}}

  """
  def subscribe_items_inventario(%Scope{} = scope) do
    key = scope.usuario.id

    Phoenix.PubSub.subscribe(Pets.PubSub, "usuario:#{key}:items_inventario")
  end

  defp broadcast_item_inventario(%Scope{} = scope, message) do
    key = scope.usuario.id

    Phoenix.PubSub.broadcast(Pets.PubSub, "usuario:#{key}:items_inventario", message)
  end

  @doc """
  Returns the list of items_inventario.

  ## Examples

      iex> list_items_inventario(scope)
      [%ItemInventario{}, ...]

  """
  def list_items_inventario(%Scope{} = scope) do
    Repo.all_by(ItemInventario, refugio_id: scope.usuario.id)
  end

  @doc """
  Gets a single item_inventario.

  Raises `Ecto.NoResultsError` if the Item inventario does not exist.

  ## Examples

      iex> get_item_inventario!(scope, 123)
      %ItemInventario{}

      iex> get_item_inventario!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_item_inventario!(%Scope{} = scope, id) do
    Repo.get_by!(ItemInventario, id: id, refugio_id: scope.usuario.id)
  end

  @doc """
  Creates a item_inventario.

  ## Examples

      iex> create_item_inventario(scope, %{field: value})
      {:ok, %ItemInventario{}}

      iex> create_item_inventario(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item_inventario(%Scope{} = scope, attrs) do
    with {:ok, item_inventario = %ItemInventario{}} <-
           %ItemInventario{}
           |> ItemInventario.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_item_inventario(scope, {:created, item_inventario})
      {:ok, item_inventario}
    end
  end

  @doc """
  Updates a item_inventario.

  ## Examples

      iex> update_item_inventario(scope, item_inventario, %{field: new_value})
      {:ok, %ItemInventario{}}

      iex> update_item_inventario(scope, item_inventario, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item_inventario(%Scope{} = scope, %ItemInventario{} = item_inventario, attrs) do
    true = item_inventario.refugio_id == scope.usuario.id

    with {:ok, item_inventario = %ItemInventario{}} <-
           item_inventario
           |> ItemInventario.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_item_inventario(scope, {:updated, item_inventario})
      {:ok, item_inventario}
    end
  end

  @doc """
  Deletes a item_inventario.

  ## Examples

      iex> delete_item_inventario(scope, item_inventario)
      {:ok, %ItemInventario{}}

      iex> delete_item_inventario(scope, item_inventario)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item_inventario(%Scope{} = scope, %ItemInventario{} = item_inventario) do
    true = item_inventario.refugio_id == scope.usuario.id

    with {:ok, item_inventario = %ItemInventario{}} <-
           Repo.delete(item_inventario) do
      broadcast_item_inventario(scope, {:deleted, item_inventario})
      {:ok, item_inventario}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item_inventario changes.

  ## Examples

      iex> change_item_inventario(scope, item_inventario)
      %Ecto.Changeset{data: %ItemInventario{}}

  """
  def change_item_inventario(%Scope{} = scope, %ItemInventario{} = item_inventario, attrs \\ %{}) do
    true = item_inventario.refugio_id == scope.usuario.id

    ItemInventario.changeset(item_inventario, attrs, scope)
  end

  alias Pets.Refugios.DonacionDinero
  alias Pets.Cuentas.Scope

  @doc """
  Subscribes to scoped notifications about any donacion_dinero changes.

  The broadcasted messages match the pattern:

    * {:created, %DonacionDinero{}}
    * {:updated, %DonacionDinero{}}
    * {:deleted, %DonacionDinero{}}

  """
  def subscribe_donaciones_dinero(%Scope{} = scope) do
    key = scope.usuario.id

    Phoenix.PubSub.subscribe(Pets.PubSub, "usuario:#{key}:donaciones_dinero")
  end

  defp broadcast_donacion_dinero(%Scope{} = scope, message) do
    key = scope.usuario.id

    Phoenix.PubSub.broadcast(Pets.PubSub, "usuario:#{key}:donaciones_dinero", message)
  end

  @doc """
  Returns the list of donaciones_dinero.

  ## Examples

      iex> list_donaciones_dinero(scope)
      [%DonacionDinero{}, ...]

  """
  def list_donaciones_dinero(%Scope{} = scope) do
    Repo.all_by(DonacionDinero, refugio_id: scope.usuario.id)
  end

  @doc """
  Gets a single donacion_dinero.

  Raises `Ecto.NoResultsError` if the Donacion dinero does not exist.

  ## Examples

      iex> get_donacion_dinero!(scope, 123)
      %DonacionDinero{}

      iex> get_donacion_dinero!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_donacion_dinero!(%Scope{} = scope, id) do
    Repo.get_by!(DonacionDinero, id: id, refugio_id: scope.usuario.id)
  end

  @doc """
  Creates a donacion_dinero.

  ## Examples

      iex> create_donacion_dinero(scope, %{field: value})
      {:ok, %DonacionDinero{}}

      iex> create_donacion_dinero(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_donacion_dinero(%Scope{} = scope, attrs) do
    with {:ok, donacion_dinero = %DonacionDinero{}} <-
           %DonacionDinero{}
           |> DonacionDinero.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_donacion_dinero(scope, {:created, donacion_dinero})
      {:ok, donacion_dinero}
    end
  end

  @doc """
  Updates a donacion_dinero.

  ## Examples

      iex> update_donacion_dinero(scope, donacion_dinero, %{field: new_value})
      {:ok, %DonacionDinero{}}

      iex> update_donacion_dinero(scope, donacion_dinero, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_donacion_dinero(%Scope{} = scope, %DonacionDinero{} = donacion_dinero, attrs) do
    true = donacion_dinero.refugio_id == scope.usuario.id

    with {:ok, donacion_dinero = %DonacionDinero{}} <-
           donacion_dinero
           |> DonacionDinero.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_donacion_dinero(scope, {:updated, donacion_dinero})
      {:ok, donacion_dinero}
    end
  end

  @doc """
  Deletes a donacion_dinero.

  ## Examples

      iex> delete_donacion_dinero(scope, donacion_dinero)
      {:ok, %DonacionDinero{}}

      iex> delete_donacion_dinero(scope, donacion_dinero)
      {:error, %Ecto.Changeset{}}

  """
  def delete_donacion_dinero(%Scope{} = scope, %DonacionDinero{} = donacion_dinero) do
    true = donacion_dinero.refugio_id == scope.usuario.id

    with {:ok, donacion_dinero = %DonacionDinero{}} <-
           Repo.delete(donacion_dinero) do
      broadcast_donacion_dinero(scope, {:deleted, donacion_dinero})
      {:ok, donacion_dinero}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking donacion_dinero changes.

  ## Examples

      iex> change_donacion_dinero(scope, donacion_dinero)
      %Ecto.Changeset{data: %DonacionDinero{}}

  """
  def change_donacion_dinero(%Scope{} = scope, %DonacionDinero{} = donacion_dinero, attrs \\ %{}) do
    true = donacion_dinero.refugio_id == scope.usuario.id

    DonacionDinero.changeset(donacion_dinero, attrs, scope)
  end

  alias Pets.Refugios.DonacionInventario
  alias Pets.Cuentas.Scope

  @doc """
  Subscribes to scoped notifications about any donacion_inventario changes.

  The broadcasted messages match the pattern:

    * {:created, %DonacionInventario{}}
    * {:updated, %DonacionInventario{}}
    * {:deleted, %DonacionInventario{}}

  """
  def subscribe_donaciones_inventario(%Scope{} = scope) do
    key = scope.usuario.id

    Phoenix.PubSub.subscribe(Pets.PubSub, "usuario:#{key}:donaciones_inventario")
  end

  defp broadcast_donacion_inventario(%Scope{} = scope, message) do
    key = scope.usuario.id

    Phoenix.PubSub.broadcast(Pets.PubSub, "usuario:#{key}:donaciones_inventario", message)
  end

  @doc """
  Returns the list of donaciones_inventario.

  ## Examples

      iex> list_donaciones_inventario(scope)
      [%DonacionInventario{}, ...]

  """
  def list_donaciones_inventario(%Scope{} = scope) do
    Repo.all_by(DonacionInventario, refugio_id: scope.usuario.id)
  end

  @doc """
  Gets a single donacion_inventario.

  Raises `Ecto.NoResultsError` if the Donacion inventario does not exist.

  ## Examples

      iex> get_donacion_inventario!(scope, 123)
      %DonacionInventario{}

      iex> get_donacion_inventario!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_donacion_inventario!(%Scope{} = scope, id) do
    Repo.get_by!(DonacionInventario, id: id, refugio_id: scope.usuario.id)
  end

  @doc """
  Creates a donacion_inventario.

  ## Examples

      iex> create_donacion_inventario(scope, %{field: value})
      {:ok, %DonacionInventario{}}

      iex> create_donacion_inventario(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_donacion_inventario(%Scope{} = scope, attrs) do
    with {:ok, donacion_inventario = %DonacionInventario{}} <-
           %DonacionInventario{}
           |> DonacionInventario.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_donacion_inventario(scope, {:created, donacion_inventario})
      {:ok, donacion_inventario}
    end
  end

  @doc """
  Updates a donacion_inventario.

  ## Examples

      iex> update_donacion_inventario(scope, donacion_inventario, %{field: new_value})
      {:ok, %DonacionInventario{}}

      iex> update_donacion_inventario(scope, donacion_inventario, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_donacion_inventario(
        %Scope{} = scope,
        %DonacionInventario{} = donacion_inventario,
        attrs
      ) do
    true = donacion_inventario.refugio_id == scope.usuario.id

    with {:ok, donacion_inventario = %DonacionInventario{}} <-
           donacion_inventario
           |> DonacionInventario.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_donacion_inventario(scope, {:updated, donacion_inventario})
      {:ok, donacion_inventario}
    end
  end

  @doc """
  Deletes a donacion_inventario.

  ## Examples

      iex> delete_donacion_inventario(scope, donacion_inventario)
      {:ok, %DonacionInventario{}}

      iex> delete_donacion_inventario(scope, donacion_inventario)
      {:error, %Ecto.Changeset{}}

  """
  def delete_donacion_inventario(%Scope{} = scope, %DonacionInventario{} = donacion_inventario) do
    true = donacion_inventario.refugio_id == scope.usuario.id

    with {:ok, donacion_inventario = %DonacionInventario{}} <-
           Repo.delete(donacion_inventario) do
      broadcast_donacion_inventario(scope, {:deleted, donacion_inventario})
      {:ok, donacion_inventario}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking donacion_inventario changes.

  ## Examples

      iex> change_donacion_inventario(scope, donacion_inventario)
      %Ecto.Changeset{data: %DonacionInventario{}}

  """
  def change_donacion_inventario(
        %Scope{} = scope,
        %DonacionInventario{} = donacion_inventario,
        attrs \\ %{}
      ) do
    true = donacion_inventario.refugio_id == scope.usuario.id

    DonacionInventario.changeset(donacion_inventario, attrs, scope)
  end
end
