defmodule PetsWeb.PostController do
  use PetsWeb, :controller

  alias Pets.Mascotas
  alias Pets.Mascotas.Mascota
  alias Pets.Posts
  alias Pets.Posts.Post

  def index(conn, _params) do
    posts = Posts.list_posts()
    render(conn, :index, posts: posts)
  end

  def new(conn, _params) do
    changeset = Posts.change_post(%Post{})
    mascotas = Mascotas.list_mascotas_for_dropdown()
    render(conn, :new, changeset: changeset, mascotas: mascotas)
  end

  def create(conn, %{"post" => post_params}) do
    current_user = conn.assigns.current_user
    params_with_user = Map.put(post_params, "user_id", current_user.id)

    case Posts.create_post(params_with_user) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        mascotas = Mascotas.list_mascotas_for_dropdown()
        render(conn, :new, changeset: changeset, mascotas: mascotas)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    render(conn, :show, post: post)
  end

  def edit(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    changeset = Posts.change_post(post)
    render(conn, :edit, post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Posts.get_post!(id)

    case Posts.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, post: post, changeset: changeset)
    end
  end

  @spec delete(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def delete(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    {:ok, _post} = Posts.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: ~p"/posts")
  end
end
