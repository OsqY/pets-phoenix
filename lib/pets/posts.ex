defmodule Pets.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Pets.Repo

  alias Pets.Posts.Post

  alias Pets.Posts.Comentario
  alias Pets.Cuentas.Scope

  @doc """
  Subscribes to scoped notifications about any comentario changes.

  The broadcasted messages match the pattern:

    * {:created, %Comentario{}}
    * {:updated, %Comentario{}}
    * {:deleted, %Comentario{}}

  """
  def subscribe_comentarios(%Scope{} = scope) do
    key = scope.usuario.id

    Phoenix.PubSub.subscribe(Pets.PubSub, "usuario:#{key}:comentarios")
  end

  defp broadcast_comentario(%Scope{} = scope, message) do
    key = scope.usuario.id

    Phoenix.PubSub.broadcast(Pets.PubSub, "usuario:#{key}:comentarios", message)
  end

  @doc """
  Returns the list of comentarios.

  ## Examples

      iex> list_comentarios(scope)
      [%Comentario{}, ...]

  """
  def list_comentarios(%Scope{} = scope) do
    Repo.all_by(Comentario, usuario_id: scope.usuario.id)
  end

  @doc """
  Gets a single comentario.

  Raises `Ecto.NoResultsError` if the Comentario does not exist.

  ## Examples

      iex> get_comentario!(scope, 123)
      %Comentario{}

      iex> get_comentario!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_comentario!(%Scope{} = scope, id) do
    Repo.get_by!(Comentario, id: id, usuario_id: scope.usuario.id)
  end

  @doc """
  Creates a comentario.

  ## Examples

      iex> create_comentario(scope, %{field: value})
      {:ok, %Comentario{}}

      iex> create_comentario(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comentario(%Scope{} = scope, attrs) do
    with {:ok, comentario = %Comentario{}} <-
           %Comentario{}
           |> Comentario.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_comentario(scope, {:created, comentario})
      {:ok, comentario}
    end
  end

  @doc """
  Updates a comentario.

  ## Examples

      iex> update_comentario(scope, comentario, %{field: new_value})
      {:ok, %Comentario{}}

      iex> update_comentario(scope, comentario, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comentario(%Scope{} = scope, %Comentario{} = comentario, attrs) do
    true = comentario.usuario_id == scope.usuario.id

    with {:ok, comentario = %Comentario{}} <-
           comentario
           |> Comentario.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_comentario(scope, {:updated, comentario})
      {:ok, comentario}
    end
  end

  @doc """
  Deletes a comentario.

  ## Examples

      iex> delete_comentario(scope, comentario)
      {:ok, %Comentario{}}

      iex> delete_comentario(scope, comentario)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comentario(%Scope{} = scope, %Comentario{} = comentario) do
    true = comentario.usuario_id == scope.usuario.id

    with {:ok, comentario = %Comentario{}} <-
           Repo.delete(comentario) do
      broadcast_comentario(scope, {:deleted, comentario})
      {:ok, comentario}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comentario changes.

  ## Examples

      iex> change_comentario(scope, comentario)
      %Ecto.Changeset{data: %Comentario{}}

  """
  def change_comentario(%Scope{} = scope, %Comentario{} = comentario, attrs \\ %{}) do
    true = comentario.usuario_id == scope.usuario.id

    Comentario.changeset(comentario, attrs, scope)
  end

  alias Pets.Posts.Post
  alias Pets.Cuentas.Scope

  @doc """
  Subscribes to scoped notifications about any post changes.

  The broadcasted messages match the pattern:

    * {:created, %Post{}}
    * {:updated, %Post{}}
    * {:deleted, %Post{}}

  """
  def subscribe_posts(%Scope{} = scope) do
    key = scope.usuario.id

    Phoenix.PubSub.subscribe(Pets.PubSub, "usuario:#{key}:posts")
  end

  defp broadcast_post(%Scope{} = scope, message) do
    key = scope.usuario.id

    Phoenix.PubSub.broadcast(Pets.PubSub, "usuario:#{key}:posts", message)
  end

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts(scope)
      [%Post{}, ...]

  """
  def list_posts() do
    mascota_query = from m in Pets.Mascotas.Mascota, select: struct(m, [:id, :nombre])
    usuario_query = from u in Pets.Cuentas.Usuario, select: struct(u, [:id, :email])
    query = from p in Post, preload: [mascota: ^mascota_query, usuario: ^usuario_query]
    Repo.all(query)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(scope, 123)
      %Post{}

      iex> get_post!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(%Scope{} = scope, id) do
    Repo.get_by!(Post, id: id, usuario_id: scope.usuario.id)
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(scope, %{field: value})
      {:ok, %Post{}}

      iex> create_post(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(%Scope{} = scope, attrs) do
    with {:ok, post = %Post{}} <-
           %Post{}
           |> Post.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_post(scope, {:created, post})
      {:ok, post}
    end
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(scope, post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(scope, post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Scope{} = scope, %Post{} = post, attrs) do
    true = post.usuario_id == scope.usuario.id

    with {:ok, post = %Post{}} <-
           post
           |> Post.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_post(scope, {:updated, post})
      {:ok, post}
    end
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(scope, post)
      {:ok, %Post{}}

      iex> delete_post(scope, post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Scope{} = scope, %Post{} = post) do
    true = post.usuario_id == scope.usuario.id

    with {:ok, post = %Post{}} <-
           Repo.delete(post) do
      broadcast_post(scope, {:deleted, post})
      {:ok, post}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(scope, post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Scope{} = scope, %Post{} = post, attrs \\ %{}) do
    true = post.usuario_id == scope.usuario.id

    Post.changeset(post, attrs, scope)
  end
end
