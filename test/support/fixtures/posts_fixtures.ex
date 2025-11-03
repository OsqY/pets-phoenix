defmodule Pets.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pets.Posts` context.
  """

  @doc """
  Generate a comentario.
  """
  def comentario_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        content: "some content",
        fecha: ~N[2025-10-29 12:08:00],
        likes: 42,
        post_id: 42,
        usuario_id: 42
      })

    {:ok, comentario} = Pets.Posts.create_comentario(scope, attrs)
    comentario
  end

  @doc """
  Generate a post.
  """
  def post_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        content: "some content",
        fecha: ~D[2025-10-29],
        mascota_id: 42,
        usuario_id: 42
      })

    {:ok, post} = Pets.Posts.create_post(scope, attrs)
    post
  end
end
