defmodule Pets.Mascotas do
  @moduledoc """
  The Mascotas context.
  """

  import Ecto.Query, warn: false
  alias Pets.Repo

  alias Pets.Mascotas.Mascota

  @doc """
  Returns the list of mascotas.

  ## Examples

      iex> list_mascotas()
      [%Mascota{}, ...]

  """
  def list_mascotas do
    Repo.all(Mascota)
  end

  def list_mascotas_for_dropdown do
    from(m in Mascota, select: {m.nombre, m.id}, order_by: m.nombre)
    |> Repo.all()
  end

  @doc """
  Gets a single mascota.

  Raises `Ecto.NoResultsError` if the Mascota does not exist.

  ## Examples

      iex> get_mascota!(123)
      %Mascota{}

      iex> get_mascota!(456)
      ** (Ecto.NoResultsError)

  """
  def get_mascota!(id), do: Repo.get!(Mascota, id)

  @doc """
  Creates a mascota.

  ## Examples

      iex> create_mascota(%{field: value})
      {:ok, %Mascota{}}

      iex> create_mascota(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_mascota(attrs) do
    %Mascota{}
    |> Mascota.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a mascota.

  ## Examples

      iex> update_mascota(mascota, %{field: new_value})
      {:ok, %Mascota{}}

      iex> update_mascota(mascota, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mascota(%Mascota{} = mascota, attrs) do
    mascota
    |> Mascota.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a mascota.

  ## Examples

      iex> delete_mascota(mascota)
      {:ok, %Mascota{}}

      iex> delete_mascota(mascota)
      {:error, %Ecto.Changeset{}}

  """
  def delete_mascota(%Mascota{} = mascota) do
    Repo.delete(mascota)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking mascota changes.

  ## Examples

      iex> change_mascota(mascota)
      %Ecto.Changeset{data: %Mascota{}}

  """
  def change_mascota(%Mascota{} = mascota, attrs \\ %{}) do
    Mascota.changeset(mascota, attrs)
  end
end
