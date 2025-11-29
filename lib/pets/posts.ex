defmodule Pets.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Pets.Repo
  alias Pets.Chats

  alias Pets.Posts.Post
  alias Pets.Posts.Comentario
  alias Pets.Posts.Like
  alias Pets.Cuentas.Scope

  # =============================================================================
  # PubSub for Comentarios
  # =============================================================================

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

  def subscribe_post_comentarios(post_id) do
    Phoenix.PubSub.subscribe(Pets.PubSub, "post:#{post_id}:comentarios")
  end

  defp broadcast_post_comentario(post_id, message) do
    Phoenix.PubSub.broadcast(Pets.PubSub, "post:#{post_id}:comentarios", message)
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

  def list_comentarios_for_post(post_id) do
    usuario_query = from u in Pets.Cuentas.Usuario, select: struct(u, [:id, :email])

    from(c in Comentario,
      where: c.post_id == ^post_id,
      order_by: [asc: c.inserted_at],
      preload: [usuario: ^usuario_query]
    )
    |> Repo.all()
  end

  def count_comentarios_for_post(post_id) do
    from(c in Comentario, where: c.post_id == ^post_id, select: count(c.id))
    |> Repo.one()
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
      comentario = Repo.preload(comentario, :usuario)
      broadcast_comentario(scope, {:created, comentario})
      broadcast_post_comentario(comentario.post_id, {:comentario_created, comentario})

      # Notificar al dueño del post (si no es el mismo usuario)
      post = Repo.get!(Post, comentario.post_id)

      if post.usuario_id != scope.usuario.id do
        Chats.notificar_comentario_post(
          post.usuario_id,
          scope.usuario.email,
          post.id
        )
      end

      {:ok, comentario}
    end
  end

  def create_comentario_for_post(%Scope{} = scope, post_id, attrs) do
    attrs = Map.put(attrs, "post_id", post_id)
    create_comentario(scope, attrs)
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
      broadcast_post_comentario(comentario.post_id, {:comentario_deleted, comentario})
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

  def change_new_comentario(%Scope{} = scope, attrs \\ %{}) do
    %Comentario{usuario_id: scope.usuario.id}
    |> Comentario.changeset(attrs, scope)
  end

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

  def subscribe_post_likes do
    Phoenix.PubSub.subscribe(Pets.PubSub, "posts:likes")
  end

  defp broadcast_post_like(message) do
    Phoenix.PubSub.broadcast(Pets.PubSub, "posts:likes", message)
  end

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts(scope)
      [%Post{}, ...]

  """
  def list_posts do
    mascota_query = from m in Pets.Mascotas.Mascota, preload: [:especie]
    usuario_query = from u in Pets.Cuentas.Usuario, select: struct(u, [:id, :email])

    query =
      from p in Post,
        order_by: [desc: p.inserted_at],
        preload: [mascota: ^mascota_query, usuario: ^usuario_query]

    Repo.all(query)
  end

  def list_posts_with_stats(scope) do
    mascota_query = from m in Pets.Mascotas.Mascota, preload: [:especie]
    usuario_query = from u in Pets.Cuentas.Usuario, select: struct(u, [:id, :email])

    likes_subquery =
      from l in Like,
        group_by: l.post_id,
        select: %{post_id: l.post_id, count: count(l.id)}

    comentarios_subquery =
      from c in Comentario,
        group_by: c.post_id,
        select: %{post_id: c.post_id, count: count(c.id)}

    posts =
      from(p in Post,
        order_by: [desc: p.inserted_at],
        preload: [mascota: ^mascota_query, usuario: ^usuario_query]
      )
      |> Repo.all()

    likes_counts =
      Repo.all(likes_subquery)
      |> Map.new(fn %{post_id: id, count: count} -> {id, count} end)

    comentarios_counts =
      Repo.all(comentarios_subquery)
      |> Map.new(fn %{post_id: id, count: count} -> {id, count} end)

    user_liked_posts =
      if scope do
        from(l in Like,
          where: l.usuario_id == ^scope.usuario.id,
          select: l.post_id
        )
        |> Repo.all()
        |> MapSet.new()
      else
        MapSet.new()
      end

    Enum.map(posts, fn post ->
      %{
        id: post.id,
        post: post,
        likes_count: Map.get(likes_counts, post.id, 0),
        comentarios_count: Map.get(comentarios_counts, post.id, 0),
        user_liked: MapSet.member?(user_liked_posts, post.id)
      }
    end)
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
    from(p in Post,
      where: p.id == ^id and p.usuario_id == ^scope.usuario.id
    )
    |> Repo.one!()
  end

  def get_post!(id) do
    mascota_query = from m in Pets.Mascotas.Mascota, preload: [:especie]
    usuario_query = from u in Pets.Cuentas.Usuario, select: struct(u, [:id, :email])

    from(p in Post,
      where: p.id == ^id,
      preload: [mascota: ^mascota_query, usuario: ^usuario_query]
    )
    |> Repo.one!()
  end

  def get_post_with_stats!(id, scope) do
    post = get_post!(id)
    likes_count = count_likes_for_post(id)
    comentarios_count = count_comentarios_for_post(id)

    user_liked =
      if scope do
        user_liked_post?(scope, id)
      else
        false
      end

    %{
      id: id,
      post: post,
      likes_count: likes_count,
      comentarios_count: comentarios_count,
      user_liked: user_liked
    }
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

  def toggle_like_post(%Scope{} = scope, post_id) do
    usuario_id = scope.usuario.id

    case Repo.get_by(Like, usuario_id: usuario_id, post_id: post_id) do
      nil ->
        %Like{}
        |> Like.changeset(%{usuario_id: usuario_id, post_id: post_id})
        |> Repo.insert()
        |> case do
          {:ok, _like} ->
            broadcast_post_like({:post_liked, post_id, usuario_id})

            # Notificar al dueño del post (si no es el mismo usuario)
            post = Repo.get!(Post, post_id)

            if post.usuario_id != usuario_id do
              Chats.notificar_like_post(
                post.usuario_id,
                scope.usuario.email,
                post_id
              )
            end

            {:ok, :liked}

          {:error, changeset} ->
            {:error, changeset}
        end

      %Like{} = like ->
        Repo.delete(like)
        broadcast_post_like({:post_unliked, post_id, usuario_id})
        {:ok, :unliked}
    end
  end

  def user_liked_post?(%Scope{} = scope, post_id) do
    usuario_id = scope.usuario.id

    from(l in Like,
      where: l.usuario_id == ^usuario_id and l.post_id == ^post_id,
      select: count(l.id)
    )
    |> Repo.one()
    |> Kernel.>(0)
  end

  def count_likes_for_post(post_id) do
    from(l in Like, where: l.post_id == ^post_id, select: count(l.id))
    |> Repo.one()
  end

  def get_likes_for_post(post_id) do
    usuario_query = from u in Pets.Cuentas.Usuario, select: struct(u, [:id, :email])

    from(l in Like,
      where: l.post_id == ^post_id,
      preload: [usuario: ^usuario_query]
    )
    |> Repo.all()
  end
end
