defmodule Pets.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pets.Posts` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        content: "some content",
        fecha: ~D[2025-10-28],
        mascota_id: 42,
        user_id: 42
      })
      |> Pets.Posts.create_post()

    post
  end
end
