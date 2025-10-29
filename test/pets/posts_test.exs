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
end
