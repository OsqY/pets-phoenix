defmodule Pets.Mascotas do
  @moduledoc """
  The Mascotas context.
  """

  import Ecto.Query, warn: false
  alias Inspect.Pets.Cuentas.Usuario
  alias Pets.Repo

  alias Pets.Mascotas.Mascota

  alias Pets.Mascotas.Raza
  alias Pets.Cuentas.Scope

  @doc """
  Subscribes to scoped notifications about any raza changes.

  The broadcasted messages match the pattern:

    * {:created, %Raza{}}
    * {:updated, %Raza{}}
    * {:deleted, %Raza{}}

  """
  def subscribe_razas(%Scope{} = scope) do
    key = scope.usuario.id

    Phoenix.PubSub.subscribe(Pets.PubSub, "usuario:#{key}:razas")
  end

  defp broadcast_raza(%Scope{} = scope, message) do
    key = scope.usuario.id

    Phoenix.PubSub.broadcast(Pets.PubSub, "usuario:#{key}:razas", message)
  end

  @doc """
  Returns the list of razas.

  ## Examples

      iex> list_razas(scope)
      [%Raza{}, ...]

  """
  def list_razas(%Scope{} = scope) do
    Repo.all(Raza)
  end

  @doc """
  Gets a single raza.

  Raises `Ecto.NoResultsError` if the Raza does not exist.

  ## Examples

      iex> get_raza!(scope, 123)
      %Raza{}

      iex> get_raza!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_raza!(%Scope{} = scope, id) do
    Repo.get_by!(Raza, id: id, usuario_id: scope.usuario.id)
  end

  @doc """
  Creates a raza.

  ## Examples

      iex> create_raza(scope, %{field: value})
      {:ok, %Raza{}}

      iex> create_raza(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_raza(%Scope{} = scope, attrs) do
    with {:ok, raza = %Raza{}} <-
           %Raza{}
           |> Raza.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_raza(scope, {:created, raza})
      {:ok, raza}
    end
  end

  @doc """
  Updates a raza.

  ## Examples

      iex> update_raza(scope, raza, %{field: new_value})
      {:ok, %Raza{}}

      iex> update_raza(scope, raza, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_raza(%Scope{} = scope, %Raza{} = raza, attrs) do
    true = raza.usuario_id == scope.usuario.id

    with {:ok, raza = %Raza{}} <-
           raza
           |> Raza.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_raza(scope, {:updated, raza})
      {:ok, raza}
    end
  end

  @doc """
  Deletes a raza.

  ## Examples

      iex> delete_raza(scope, raza)
      {:ok, %Raza{}}

      iex> delete_raza(scope, raza)
      {:error, %Ecto.Changeset{}}

  """
  def delete_raza(%Scope{} = scope, %Raza{} = raza) do
    true = raza.usuario_id == scope.usuario.id

    with {:ok, raza = %Raza{}} <-
           raza
           |> Raza.delete_changeset()
           |> Repo.delete() do
      broadcast_raza(scope, {:deleted, raza})
      {:ok, raza}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking raza changes.

  ## Examples

      iex> change_raza(scope, raza)
      %Ecto.Changeset{data: %Raza{}}

  """
  def change_raza(%Scope{} = scope, %Raza{} = raza, attrs \\ %{}) do
    true = raza.usuario_id == scope.usuario.id

    Raza.changeset(raza, attrs, scope)
  end

  alias Pets.Mascotas.Especie
  alias Pets.Cuentas.Scope

  @doc """
  Subscribes to scoped notifications about any especie changes.

  The broadcasted messages match the pattern:

    * {:created, %Especie{}}
    * {:updated, %Especie{}}
    * {:deleted, %Especie{}}

  """
  def subscribe_especies(%Scope{} = scope) do
    key = scope.usuario.id

    Phoenix.PubSub.subscribe(Pets.PubSub, "usuario:#{key}:especies")
  end

  defp broadcast_especie(%Scope{} = scope, message) do
    key = scope.usuario.id

    Phoenix.PubSub.broadcast(Pets.PubSub, "usuario:#{key}:especies", message)
  end

  @doc """
  Returns the list of especies.

  ## Examples

      iex> list_especies(scope)
      [%Especie{}, ...]

  """
  def list_especies(%Scope{} = scope) do
    Repo.all(Especie)
  end

  def list_especies(_) do
    Repo.all(Especie)
  end

  @doc """
  Gets a single especie.

  Raises `Ecto.NoResultsError` if the Especie does not exist.

  ## Examples

      iex> get_especie!(scope, 123)
      %Especie{}

      iex> get_especie!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_especie!(%Scope{} = scope, id) do
    Repo.get_by!(Especie, id: id)
  end

  @doc """
  Creates a especie.

  ## Examples

      iex> create_especie(scope, %{field: value})
      {:ok, %Especie{}}

      iex> create_especie(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_especie(%Scope{} = scope, attrs) do
    with {:ok, especie = %Especie{}} <-
           %Especie{}
           |> Especie.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_especie(scope, {:created, especie})
      {:ok, especie}
    end
  end

  @doc """
  Updates a especie.

  ## Examples

      iex> update_especie(scope, especie, %{field: new_value})
      {:ok, %Especie{}}

      iex> update_especie(scope, especie, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_especie(%Scope{} = scope, %Especie{} = especie, attrs) do
    with {:ok, especie = %Especie{}} <-
           especie
           |> Especie.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_especie(scope, {:updated, especie})
      {:ok, especie}
    end
  end

  @doc """
  Deletes a especie.

  ## Examples

      iex> delete_especie(scope, especie)
      {:ok, %Especie{}}

      iex> delete_especie(scope, especie)
      {:error, %Ecto.Changeset{}}

  """
  def delete_especie(%Scope{} = scope, %Especie{} = especie) do
    with {:ok, especie = %Especie{}} <-
           especie
           |> Especie.delete_changeset()
           |> Repo.delete() do
      broadcast_especie(scope, {:deleted, especie})
      {:ok, especie}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking especie changes.

  ## Examples

      iex> change_especie(scope, especie)
      %Ecto.Changeset{data: %Especie{}}

  """
  def change_especie(%Scope{} = scope, %Especie{} = especie, attrs \\ %{}) do
    Especie.changeset(especie, attrs, scope)
  end

  alias Pets.Mascotas.Color
  alias Pets.Cuentas.Scope

  @doc """
  Subscribes to scoped notifications about any color changes.

  The broadcasted messages match the pattern:

    * {:created, %Color{}}
    * {:updated, %Color{}}
    * {:deleted, %Color{}}

  """
  def subscribe_colores(%Scope{} = scope) do
    key = scope.usuario.id

    Phoenix.PubSub.subscribe(Pets.PubSub, "usuario:#{key}:colores")
  end

  defp broadcast_color(%Scope{} = scope, message) do
    key = scope.usuario.id

    Phoenix.PubSub.broadcast(Pets.PubSub, "usuario:#{key}:colores", message)
  end

  @doc """
  Returns the list of colores.

  ## Examples

      iex> list_colores(scope)
      [%Color{}, ...]

  """
  def list_colores(%Scope{} = scope) do
    Repo.all(Color) |> Repo.preload([:especie])
  end

  @doc """
  Gets a single color.

  Raises `Ecto.NoResultsError` if the Color does not exist.

  ## Examples

      iex> get_color!(scope, 123)
      %Color{}

      iex> get_color!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_color!(%Scope{} = scope, id) do
    Repo.get_by!(Color, id: id, usuario_id: scope.usuario.id)
  end

  @doc """
  Creates a color.

  ## Examples

      iex> create_color(scope, %{field: value})
      {:ok, %Color{}}

      iex> create_color(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_color(%Scope{} = scope, attrs) do
    with {:ok, color = %Color{}} <-
           %Color{}
           |> Color.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_color(scope, {:created, color})
      {:ok, color}
    end
  end

  @doc """
  Updates a color.

  ## Examples

      iex> update_color(scope, color, %{field: new_value})
      {:ok, %Color{}}

      iex> update_color(scope, color, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_color(%Scope{} = scope, %Color{} = color, attrs) do
    true = color.usuario_id == scope.usuario.id

    with {:ok, color = %Color{}} <-
           color
           |> Color.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_color(scope, {:updated, color})
      {:ok, color}
    end
  end

  @doc """
  Deletes a color.

  ## Examples

      iex> delete_color(scope, color)
      {:ok, %Color{}}

      iex> delete_color(scope, color)
      {:error, %Ecto.Changeset{}}

  """
  def delete_color(%Scope{} = scope, %Color{} = color) do
    true = color.usuario_id == scope.usuario.id

    with {:ok, color = %Color{}} <-
           color
           |> Color.delete_changeset()
           |> Repo.delete() do
      broadcast_color(scope, {:deleted, color})
      {:ok, color}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking color changes.

  ## Examples

      iex> change_color(scope, color)
      %Ecto.Changeset{data: %Color{}}

  """
  def change_color(%Scope{} = scope, %Color{} = color, attrs \\ %{}) do
    true = color.usuario_id == scope.usuario.id

    Color.changeset(color, attrs, scope)
  end

  alias Pets.Mascotas.Mascota
  alias Pets.Cuentas.Scope

  @doc """
  Subscribes to scoped notifications about any mascota changes.

  The broadcasted messages match the pattern:

    * {:created, %Mascota{}}
    * {:updated, %Mascota{}}
    * {:deleted, %Mascota{}}

  """
  def subscribe_mascotas(%Scope{} = scope) do
    Phoenix.PubSub.subscribe(Pets.PubSub, "mascotas")
  end

  def subscribe_mascotas(nil) do
    Phoenix.PubSub.subscribe(Pets.PubSub, "mascotas")
  end

  defp broadcast_mascota(%Scope{} = scope, message) do
    Phoenix.PubSub.subscribe(Pets.PubSub, "mascotas")
  end

  @doc """
  Returns the list of mascotas.

  ## Examples

      iex> list_mascotas(scope)
      [%Mascota{}, ...]

  """
  def list_mascotas(%Scope{} = scope, search_params \\ "") do
    especie_query = from r in Especie, select: struct(r, [:nombre])
    color_query = from c in Color, select: struct(c, [:nombre])
    raza_query = from r in Raza, select: struct(r, [:nombre])

    base_query =
      from m in Mascota,
        preload: [:usuario, color: ^color_query, raza: ^raza_query, especie: ^especie_query]

    query =
      if search_params != "" do
        search_term = "%#{search_params}%"

        from [m] in base_query,
          where: ilike(m.nombre, ^search_term) or ilike(m.tamanio, ^search_term)
      else
        base_query
      end

    Repo.all(query)
  end

  def list_mascotas() do
    especie_query = from r in Especie, select: struct(r, [:nombre])
    color_query = from c in Color, select: struct(c, [:nombre])
    raza_query = from r in Raza, select: struct(r, [:nombre])

    query =
      from m in Mascota,
        preload: [:usuario, color: ^color_query, raza: ^raza_query, especie: ^especie_query]

    Repo.all(query)
  end

  def list_mascotas_for_dropdown(%Scope{} = scope) do
    Repo.all(
      from m in Mascota,
        select: {m.nombre, m.id},
        where: m.usuario_id == ^scope.usuario.id
    )
  end

  @doc """
  Gets a single mascota.

  Raises `Ecto.NoResultsError` if the Mascota does not exist.

  ## Examples

      iex> get_mascota!(scope, 123)
      %Mascota{}

      iex> get_mascota!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_mascota(%Scope{} = scope, id) do
    Repo.get_by(Mascota, id: id, usuario_id: scope.usuario.id)
  end

  def get_mascota(id) do
    Repo.get_by(Mascota, id: id)
  end

  @doc """
  Gets a single mascota owned by the user, raising if not found.

  Raises `Ecto.NoResultsError` if the Mascota does not exist or doesn't belong to the user.

  ## Examples

      iex> get_mascota!(scope, 123)
      %Mascota{}

      iex> get_mascota!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_mascota!(%Scope{} = scope, id) do
    Repo.get_by!(Mascota, id: id, usuario_id: scope.usuario.id)
  end

  def get_mascota_for_show!(%Scope{} = scope, id) do
    query =
      from m in Mascota,
        where: m.id == ^id,
        preload: [
          :usuario,
          color: ^from(c in Color, select: %{id: c.id, nombre: c.nombre}),
          raza: ^from(r in Raza, select: %{id: r.id, nombre: r.nombre}),
          especie: ^from(e in Especie, select: %{id: e.id, nombre: e.nombre})
        ]

    Repo.one(query)
  end

  def get_mascota_for_show!(_, id) do
    query =
      from m in Mascota,
        where: m.id == ^id,
        preload: [
          :usuario,
          color: ^from(c in Color, select: %{id: c.id, nombre: c.nombre}),
          raza: ^from(r in Raza, select: %{id: r.id, nombre: r.nombre}),
          especie: ^from(e in Especie, select: %{id: e.id, nombre: e.nombre})
        ]

    Repo.one(query)
  end

  @doc """
  Creates a mascota.

  ## Examples

      iex> create_mascota(scope, %{field: value})
      {:ok, %Mascota{}}

      iex> create_mascota(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_mascota(%Scope{} = scope, attrs) do
    with {:ok, mascota = %Mascota{}} <-
           %Mascota{}
           |> Mascota.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_mascota(scope, {:created, mascota})

      Phoenix.PubSub.broadcast(Pets.PubSub, "mascotas", {:created, mascota})
      {:ok, mascota}
    end
  end

  @doc """
  Updates a mascota.

  ## Examples

      iex> update_mascota(scope, mascota, %{field: new_value})
      {:ok, %Mascota{}}

      iex> update_mascota(scope, mascota, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mascota(%Scope{} = scope, %Mascota{} = mascota, attrs) do
    true = mascota.usuario_id == scope.usuario.id

    with {:ok, mascota = %Mascota{}} <-
           mascota
           |> Mascota.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_mascota(scope, {:updated, mascota})
      Phoenix.PubSub.broadcast(Pets.PubSub, "mascotas", {:updated, mascota})
      {:ok, mascota}
    end
  end

  @doc """
  Deletes a mascota.

  ## Examples

      iex> delete_mascota(scope, mascota)
      {:ok, %Mascota{}}

      iex> delete_mascota(scope, mascota)
      {:error, %Ecto.Changeset{}}

  """
  def delete_mascota(%Scope{} = scope, %Mascota{} = mascota) do
    true = mascota.usuario_id == scope.usuario.id

    with {:ok, mascota = %Mascota{}} <-
           mascota
           |> Mascota.delete_changeset()
           |> Repo.delete() do
      broadcast_mascota(scope, {:deleted, mascota})
      {:ok, mascota}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking mascota changes.

  ## Examples

      iex> change_mascota(scope, mascota)
      %Ecto.Changeset{data: %Mascota{}}

  """
  def change_mascota(%Scope{} = scope, %Mascota{} = mascota, attrs \\ %{}) do
    true = mascota.usuario_id == scope.usuario.id

    Mascota.changeset(mascota, attrs, scope)
  end

  alias Pets.Mascotas.ImagenMascota
  alias Pets.Cuentas.Scope

  @doc """
  Subscribes to scoped notifications about any imagen_mascota changes.

  The broadcasted messages match the pattern:

    * {:created, %ImagenMascota{}}
    * {:updated, %ImagenMascota{}}
    * {:deleted, %ImagenMascota{}}

  """
  def subscribe_imagenes_mascotas(%Scope{} = scope) do
    key = scope.usuario.id

    Phoenix.PubSub.subscribe(Pets.PubSub, "usuario:#{key}:imagenes_mascotas")
  end

  defp broadcast_imagen_mascota(%Scope{} = scope, message) do
    key = scope.usuario.id

    Phoenix.PubSub.broadcast(Pets.PubSub, "usuario:#{key}:imagenes_mascotas", message)
  end

  @doc """
  Returns the list of imagenes_mascotas.

  ## Examples

      iex> list_imagenes_mascotas(scope)
      [%ImagenMascota{}, ...]

  """
  def list_imagenes_mascotas(%Scope{} = scope) do
    Repo.all_by(ImagenMascota, usuario_id: scope.usuario.id)
  end

  @doc """
  Gets a single imagen_mascota.

  Raises `Ecto.NoResultsError` if the Imagen mascota does not exist.

  ## Examples

      iex> get_imagen_mascota!(scope, 123)
      %ImagenMascota{}

      iex> get_imagen_mascota!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_imagen_mascota!(%Scope{} = scope, id) do
    Repo.get_by!(ImagenMascota, id: id, usuario_id: scope.usuario.id)
  end

  @doc """
  Creates a imagen_mascota.

  ## Examples

      iex> create_imagen_mascota(scope, %{field: value})
      {:ok, %ImagenMascota{}}

      iex> create_imagen_mascota(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_imagen_mascota(%Scope{} = scope, attrs) do
    with {:ok, imagen_mascota = %ImagenMascota{}} <-
           %ImagenMascota{}
           |> ImagenMascota.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_imagen_mascota(scope, {:created, imagen_mascota})
      {:ok, imagen_mascota}
    end
  end

  @doc """
  Updates a imagen_mascota.

  ## Examples

      iex> update_imagen_mascota(scope, imagen_mascota, %{field: new_value})
      {:ok, %ImagenMascota{}}

      iex> update_imagen_mascota(scope, imagen_mascota, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_imagen_mascota(%Scope{} = scope, %ImagenMascota{} = imagen_mascota, attrs) do
    true = imagen_mascota.usuario_id == scope.usuario.id

    with {:ok, imagen_mascota = %ImagenMascota{}} <-
           imagen_mascota
           |> ImagenMascota.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_imagen_mascota(scope, {:updated, imagen_mascota})
      {:ok, imagen_mascota}
    end
  end

  @doc """
  Deletes a imagen_mascota.

  ## Examples

      iex> delete_imagen_mascota(scope, imagen_mascota)
      {:ok, %ImagenMascota{}}

      iex> delete_imagen_mascota(scope, imagen_mascota)
      {:error, %Ecto.Changeset{}}

  """
  def delete_imagen_mascota(%Scope{} = scope, %ImagenMascota{} = imagen_mascota) do
    true = imagen_mascota.usuario_id == scope.usuario.id

    with {:ok, imagen_mascota = %ImagenMascota{}} <-
           Repo.delete(imagen_mascota) do
      broadcast_imagen_mascota(scope, {:deleted, imagen_mascota})
      {:ok, imagen_mascota}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking imagen_mascota changes.

  ## Examples

      iex> change_imagen_mascota(scope, imagen_mascota)
      %Ecto.Changeset{data: %ImagenMascota{}}

  """
  def change_imagen_mascota(%Scope{} = scope, %ImagenMascota{} = imagen_mascota, attrs \\ %{}) do
    true = imagen_mascota.usuario_id == scope.usuario.id

    ImagenMascota.changeset(imagen_mascota, attrs, scope)
  end

  alias Pets.Mascotas.HistorialMedico
  alias Pets.Cuentas.Scope

  @doc """
  Subscribes to scoped notifications about any historial_medico changes.

  The broadcasted messages match the pattern:

    * {:created, %HistorialMedico{}}
    * {:updated, %HistorialMedico{}}
    * {:deleted, %HistorialMedico{}}

  """
  def subscribe_historiales_medicos(%Scope{} = scope) do
    key = scope.usuario.id

    Phoenix.PubSub.subscribe(Pets.PubSub, "usuario:#{key}:historiales_medicos")
  end

  defp broadcast_historial_medico(%Scope{} = scope, message) do
    key = scope.usuario.id

    Phoenix.PubSub.broadcast(Pets.PubSub, "usuario:#{key}:historiales_medicos", message)
  end

  @doc """
  Returns the list of historiales_medicos.

  ## Examples

      iex> list_historiales_medicos(scope)
      [%HistorialMedico{}, ...]

  """
  def list_historiales_medicos(%Scope{} = scope) do
    from(h in HistorialMedico,
      where: h.usuario_id == ^scope.usuario.id,
      order_by: [desc: h.fecha],
      preload: [:mascota]
    )
    |> Repo.all()
  end

  def list_historiales_medicos_for_mascota(mascota_id) do
    from(h in HistorialMedico,
      where: h.mascota_id == ^mascota_id,
      order_by: [desc: h.fecha],
      preload: [:mascota]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single historial_medico.

  Raises `Ecto.NoResultsError` if the Historial medico does not exist.

  ## Examples

      iex> get_historial_medico!(scope, 123)
      %HistorialMedico{}

      iex> get_historial_medico!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_historial_medico!(%Scope{} = scope, id) do
    from(h in HistorialMedico,
      where: h.id == ^id and h.usuario_id == ^scope.usuario.id,
      preload: [:mascota]
    )
    |> Repo.one!()
  end

  def get_historial_medico!(id) do
    from(h in HistorialMedico,
      where: h.id == ^id,
      preload: [:mascota]
    )
    |> Repo.one!()
  end

  @doc """
  Creates a historial_medico.

  ## Examples

      iex> create_historial_medico(scope, %{field: value})
      {:ok, %HistorialMedico{}}

      iex> create_historial_medico(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_historial_medico(%Scope{} = scope, attrs) do
    with {:ok, historial_medico = %HistorialMedico{}} <-
           %HistorialMedico{}
           |> HistorialMedico.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_historial_medico(scope, {:created, historial_medico})
      {:ok, historial_medico}
    end
  end

  @doc """
  Updates a historial_medico.

  ## Examples

      iex> update_historial_medico(scope, historial_medico, %{field: new_value})
      {:ok, %HistorialMedico{}}

      iex> update_historial_medico(scope, historial_medico, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_historial_medico(%Scope{} = scope, %HistorialMedico{} = historial_medico, attrs) do
    true = historial_medico.usuario_id == scope.usuario.id

    with {:ok, historial_medico = %HistorialMedico{}} <-
           historial_medico
           |> HistorialMedico.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_historial_medico(scope, {:updated, historial_medico})
      {:ok, historial_medico}
    end
  end

  @doc """
  Deletes a historial_medico.

  ## Examples

      iex> delete_historial_medico(scope, historial_medico)
      {:ok, %HistorialMedico{}}

      iex> delete_historial_medico(scope, historial_medico)
      {:error, %Ecto.Changeset{}}

  """
  def delete_historial_medico(%Scope{} = scope, %HistorialMedico{} = historial_medico) do
    true = historial_medico.usuario_id == scope.usuario.id

    with {:ok, historial_medico = %HistorialMedico{}} <-
           Repo.delete(historial_medico) do
      broadcast_historial_medico(scope, {:deleted, historial_medico})
      {:ok, historial_medico}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking historial_medico changes.

  ## Examples

      iex> change_historial_medico(scope, historial_medico)
      %Ecto.Changeset{data: %HistorialMedico{}}

  """
  def change_historial_medico(
        %Scope{} = scope,
        %HistorialMedico{} = historial_medico,
        attrs \\ %{}
      ) do
    if historial_medico.usuario_id do
      true = historial_medico.usuario_id == scope.usuario.id
    end

    HistorialMedico.changeset(historial_medico, attrs, scope)
  end

  def change_new_historial_medico(%Scope{} = scope, attrs \\ %{}) do
    %HistorialMedico{usuario_id: scope.usuario.id}
    |> HistorialMedico.changeset(attrs, scope)
  end
end
