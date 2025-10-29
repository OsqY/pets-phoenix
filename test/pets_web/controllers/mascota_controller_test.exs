defmodule PetsWeb.MascotaControllerTest do
  use PetsWeb.ConnCase

  import Pets.MascotasFixtures

  @create_attrs %{nombre: "some nombre", descripcion: "some descripcion", edad: 42, peso: 120.5}
  @update_attrs %{nombre: "some updated nombre", descripcion: "some updated descripcion", edad: 43, peso: 456.7}
  @invalid_attrs %{nombre: nil, descripcion: nil, edad: nil, peso: nil}

  describe "index" do
    test "lists all mascotas", %{conn: conn} do
      conn = get(conn, ~p"/mascotas")
      assert html_response(conn, 200) =~ "Listing Mascotas"
    end
  end

  describe "new mascota" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/mascotas/new")
      assert html_response(conn, 200) =~ "New Mascota"
    end
  end

  describe "create mascota" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/mascotas", mascota: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/mascotas/#{id}"

      conn = get(conn, ~p"/mascotas/#{id}")
      assert html_response(conn, 200) =~ "Mascota #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/mascotas", mascota: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Mascota"
    end
  end

  describe "edit mascota" do
    setup [:create_mascota]

    test "renders form for editing chosen mascota", %{conn: conn, mascota: mascota} do
      conn = get(conn, ~p"/mascotas/#{mascota}/edit")
      assert html_response(conn, 200) =~ "Edit Mascota"
    end
  end

  describe "update mascota" do
    setup [:create_mascota]

    test "redirects when data is valid", %{conn: conn, mascota: mascota} do
      conn = put(conn, ~p"/mascotas/#{mascota}", mascota: @update_attrs)
      assert redirected_to(conn) == ~p"/mascotas/#{mascota}"

      conn = get(conn, ~p"/mascotas/#{mascota}")
      assert html_response(conn, 200) =~ "some updated nombre"
    end

    test "renders errors when data is invalid", %{conn: conn, mascota: mascota} do
      conn = put(conn, ~p"/mascotas/#{mascota}", mascota: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Mascota"
    end
  end

  describe "delete mascota" do
    setup [:create_mascota]

    test "deletes chosen mascota", %{conn: conn, mascota: mascota} do
      conn = delete(conn, ~p"/mascotas/#{mascota}")
      assert redirected_to(conn) == ~p"/mascotas"

      assert_error_sent 404, fn ->
        get(conn, ~p"/mascotas/#{mascota}")
      end
    end
  end

  defp create_mascota(_) do
    mascota = mascota_fixture()

    %{mascota: mascota}
  end
end
