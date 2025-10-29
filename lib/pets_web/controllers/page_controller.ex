defmodule PetsWeb.PageController do
  use PetsWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def hello(conn, _params) do
    html(conn, "holaa")
  end

  def goodbye(conn, _params) do
    html(conn, "goodbyee")
  end
end
