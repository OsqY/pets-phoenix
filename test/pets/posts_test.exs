defmodule Pets.PostsTest do
  use Pets.DataCase

  alias Pets.Posts

  describe "posts" do
    alias Pets.Posts.Post

    import Pets.PostsFixtures

    @invalid_attrs %{user_id: nil, content: nil, fecha: nil, mascota_id: nil}

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Posts.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Posts.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{user_id: 42, content: "some content", fecha: ~D[2025-10-28], mascota_id: 42}

      assert {:ok, %Post{} = post} = Posts.create_post(valid_attrs)
      assert post.user_id == 42
      assert post.content == "some content"
      assert post.fecha == ~D[2025-10-28]
      assert post.mascota_id == 42
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{user_id: 43, content: "some updated content", fecha: ~D[2025-10-29], mascota_id: 43}

      assert {:ok, %Post{} = post} = Posts.update_post(post, update_attrs)
      assert post.user_id == 43
      assert post.content == "some updated content"
      assert post.fecha == ~D[2025-10-29]
      assert post.mascota_id == 43
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)
      assert post == Posts.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end
  end

  describe "comentarios" do
    alias Pets.Posts.Comentario

    import Pets.CuentasFixtures, only: [usuario_scope_fixture: 0]
    import Pets.PostsFixtures

    @invalid_attrs %{usuario_id: nil, content: nil, fecha: nil, post_id: nil, likes: nil}

    test "list_comentarios/1 returns all scoped comentarios" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      comentario = comentario_fixture(scope)
      other_comentario = comentario_fixture(other_scope)
      assert Posts.list_comentarios(scope) == [comentario]
      assert Posts.list_comentarios(other_scope) == [other_comentario]
    end

    test "get_comentario!/2 returns the comentario with given id" do
      scope = usuario_scope_fixture()
      comentario = comentario_fixture(scope)
      other_scope = usuario_scope_fixture()
      assert Posts.get_comentario!(scope, comentario.id) == comentario
      assert_raise Ecto.NoResultsError, fn -> Posts.get_comentario!(other_scope, comentario.id) end
    end

    test "create_comentario/2 with valid data creates a comentario" do
      valid_attrs = %{usuario_id: 42, content: "some content", fecha: ~N[2025-10-29 12:08:00], post_id: 42, likes: 42}
      scope = usuario_scope_fixture()

      assert {:ok, %Comentario{} = comentario} = Posts.create_comentario(scope, valid_attrs)
      assert comentario.usuario_id == 42
      assert comentario.content == "some content"
      assert comentario.fecha == ~N[2025-10-29 12:08:00]
      assert comentario.post_id == 42
      assert comentario.likes == 42
      assert comentario.usuario_id == scope.usuario.id
    end

    test "create_comentario/2 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.create_comentario(scope, @invalid_attrs)
    end

    test "update_comentario/3 with valid data updates the comentario" do
      scope = usuario_scope_fixture()
      comentario = comentario_fixture(scope)
      update_attrs = %{usuario_id: 43, content: "some updated content", fecha: ~N[2025-10-30 12:08:00], post_id: 43, likes: 43}

      assert {:ok, %Comentario{} = comentario} = Posts.update_comentario(scope, comentario, update_attrs)
      assert comentario.usuario_id == 43
      assert comentario.content == "some updated content"
      assert comentario.fecha == ~N[2025-10-30 12:08:00]
      assert comentario.post_id == 43
      assert comentario.likes == 43
    end

    test "update_comentario/3 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      comentario = comentario_fixture(scope)

      assert_raise MatchError, fn ->
        Posts.update_comentario(other_scope, comentario, %{})
      end
    end

    test "update_comentario/3 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      comentario = comentario_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Posts.update_comentario(scope, comentario, @invalid_attrs)
      assert comentario == Posts.get_comentario!(scope, comentario.id)
    end

    test "delete_comentario/2 deletes the comentario" do
      scope = usuario_scope_fixture()
      comentario = comentario_fixture(scope)
      assert {:ok, %Comentario{}} = Posts.delete_comentario(scope, comentario)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_comentario!(scope, comentario.id) end
    end

    test "delete_comentario/2 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      comentario = comentario_fixture(scope)
      assert_raise MatchError, fn -> Posts.delete_comentario(other_scope, comentario) end
    end

    test "change_comentario/2 returns a comentario changeset" do
      scope = usuario_scope_fixture()
      comentario = comentario_fixture(scope)
      assert %Ecto.Changeset{} = Posts.change_comentario(scope, comentario)
    end
  end

  describe "posts" do
    alias Pets.Posts.Post

    import Pets.CuentasFixtures, only: [usuario_scope_fixture: 0]
    import Pets.PostsFixtures

    @invalid_attrs %{usuario_id: nil, content: nil, fecha: nil, mascota_id: nil}

    test "list_posts/1 returns all scoped posts" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      post = post_fixture(scope)
      other_post = post_fixture(other_scope)
      assert Posts.list_posts(scope) == [post]
      assert Posts.list_posts(other_scope) == [other_post]
    end

    test "get_post!/2 returns the post with given id" do
      scope = usuario_scope_fixture()
      post = post_fixture(scope)
      other_scope = usuario_scope_fixture()
      assert Posts.get_post!(scope, post.id) == post
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(other_scope, post.id) end
    end

    test "create_post/2 with valid data creates a post" do
      valid_attrs = %{usuario_id: 42, content: "some content", fecha: ~D[2025-10-29], mascota_id: 42}
      scope = usuario_scope_fixture()

      assert {:ok, %Post{} = post} = Posts.create_post(scope, valid_attrs)
      assert post.usuario_id == 42
      assert post.content == "some content"
      assert post.fecha == ~D[2025-10-29]
      assert post.mascota_id == 42
      assert post.usuario_id == scope.usuario.id
    end

    test "create_post/2 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(scope, @invalid_attrs)
    end

    test "update_post/3 with valid data updates the post" do
      scope = usuario_scope_fixture()
      post = post_fixture(scope)
      update_attrs = %{usuario_id: 43, content: "some updated content", fecha: ~D[2025-10-30], mascota_id: 43}

      assert {:ok, %Post{} = post} = Posts.update_post(scope, post, update_attrs)
      assert post.usuario_id == 43
      assert post.content == "some updated content"
      assert post.fecha == ~D[2025-10-30]
      assert post.mascota_id == 43
    end

    test "update_post/3 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      post = post_fixture(scope)

      assert_raise MatchError, fn ->
        Posts.update_post(other_scope, post, %{})
      end
    end

    test "update_post/3 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      post = post_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(scope, post, @invalid_attrs)
      assert post == Posts.get_post!(scope, post.id)
    end

    test "delete_post/2 deletes the post" do
      scope = usuario_scope_fixture()
      post = post_fixture(scope)
      assert {:ok, %Post{}} = Posts.delete_post(scope, post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(scope, post.id) end
    end

    test "delete_post/2 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      post = post_fixture(scope)
      assert_raise MatchError, fn -> Posts.delete_post(other_scope, post) end
    end

    test "change_post/2 returns a post changeset" do
      scope = usuario_scope_fixture()
      post = post_fixture(scope)
      assert %Ecto.Changeset{} = Posts.change_post(scope, post)
    end
  end

  describe "comentarios" do
    alias Pets.Posts.Comentario

    import Pets.CuentasFixtures, only: [usuario_scope_fixture: 0]
    import Pets.PostsFixtures

    @invalid_attrs %{usuario_id: nil, contenido: nil, likes: nil}

    test "list_comentarios/1 returns all scoped comentarios" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      comentario = comentario_fixture(scope)
      other_comentario = comentario_fixture(other_scope)
      assert Posts.list_comentarios(scope) == [comentario]
      assert Posts.list_comentarios(other_scope) == [other_comentario]
    end

    test "get_comentario!/2 returns the comentario with given id" do
      scope = usuario_scope_fixture()
      comentario = comentario_fixture(scope)
      other_scope = usuario_scope_fixture()
      assert Posts.get_comentario!(scope, comentario.id) == comentario
      assert_raise Ecto.NoResultsError, fn -> Posts.get_comentario!(other_scope, comentario.id) end
    end

    test "create_comentario/2 with valid data creates a comentario" do
      valid_attrs = %{usuario_id: 42, contenido: "some contenido", likes: 42}
      scope = usuario_scope_fixture()

      assert {:ok, %Comentario{} = comentario} = Posts.create_comentario(scope, valid_attrs)
      assert comentario.usuario_id == 42
      assert comentario.contenido == "some contenido"
      assert comentario.likes == 42
      assert comentario.usuario_id == scope.usuario.id
    end

    test "create_comentario/2 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.create_comentario(scope, @invalid_attrs)
    end

    test "update_comentario/3 with valid data updates the comentario" do
      scope = usuario_scope_fixture()
      comentario = comentario_fixture(scope)
      update_attrs = %{usuario_id: 43, contenido: "some updated contenido", likes: 43}

      assert {:ok, %Comentario{} = comentario} = Posts.update_comentario(scope, comentario, update_attrs)
      assert comentario.usuario_id == 43
      assert comentario.contenido == "some updated contenido"
      assert comentario.likes == 43
    end

    test "update_comentario/3 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      comentario = comentario_fixture(scope)

      assert_raise MatchError, fn ->
        Posts.update_comentario(other_scope, comentario, %{})
      end
    end

    test "update_comentario/3 with invalid data returns error changeset" do
      scope = usuario_scope_fixture()
      comentario = comentario_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Posts.update_comentario(scope, comentario, @invalid_attrs)
      assert comentario == Posts.get_comentario!(scope, comentario.id)
    end

    test "delete_comentario/2 deletes the comentario" do
      scope = usuario_scope_fixture()
      comentario = comentario_fixture(scope)
      assert {:ok, %Comentario{}} = Posts.delete_comentario(scope, comentario)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_comentario!(scope, comentario.id) end
    end

    test "delete_comentario/2 with invalid scope raises" do
      scope = usuario_scope_fixture()
      other_scope = usuario_scope_fixture()
      comentario = comentario_fixture(scope)
      assert_raise MatchError, fn -> Posts.delete_comentario(other_scope, comentario) end
    end

    test "change_comentario/2 returns a comentario changeset" do
      scope = usuario_scope_fixture()
      comentario = comentario_fixture(scope)
      assert %Ecto.Changeset{} = Posts.change_comentario(scope, comentario)
    end
  end
end
