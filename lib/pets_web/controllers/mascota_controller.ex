defmodule PetsWeb.MascotaController do
  use PetsWeb, :controller

  alias Pets.Mascotas
  alias Pets.Mascotas.Mascota

  def index(conn, _params) do
    mascotas = Mascotas.list_mascotas()
    render(conn, :index, mascotas: mascotas)
  end

  def new(conn, _params) do
    changeset = Mascotas.change_mascota(%Mascota{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"mascota" => mascota_params}) do
    current_user = conn.assigns.current_user
    mascota_params_with_user = Map.put(mascota_params, "usuario_id", current_user.id)

    case Mascotas.create_mascota(mascota_params_with_user) do
      {:ok, mascota} ->
        conn
        |> put_flash(:info, "Mascota agregada exitosamente!")
        |> redirect(to: ~p"/mascotas/#{mascota}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    mascota = Mascotas.get_mascota!(id)
    can_user_edit = if conn.assigns.current_scope.usuario.id == mascota.usuario_id, do: true, else: false
    render(conn, :show, mascota: mascota, can_user_edit: can_user_edit)
  end

  def edit(conn, %{"id" => id}) do
    mascota = Mascotas.get_mascota!(id)
    changeset = Mascotas.change_mascota(mascota)
    render(conn, :edit, mascota: mascota, changeset: changeset)
  end

  def update(conn, %{"id" => id, "mascota" => mascota_params}) do
    mascota = Mascotas.get_mascota!(id)
    current_user = conn.assigns.current_scope.usuario

    case mascota.usuario_id == current_user.id do
      true ->
        case Mascotas.update_mascota(mascota, mascota_params) do
          {:ok, mascota} ->
            conn
            |> put_flash(:info, "Mascota updated successfully.")
            |> redirect(to: ~p"/mascotas/#{mascota}")

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, :edit, mascota: mascota, changeset: changeset)
        end

      false ->
        conn
        |> put_flash(:error, "No está autorizado(a) para esta operación.")
        |> redirect(to: ~p"/mascotas")
    end
  end

  def delete(conn, %{"id" => id}) do
    mascota = Mascotas.get_mascota!(id)
    current_user = conn.assigns.current_scope.usuario

    case mascota.usuario_id == current_user.id do
      true ->
        {:ok, _mascota} = Mascotas.delete_mascota(mascota)

        conn
        |> put_flash(:info, "Mascota deleted successfully.")
        |> redirect(to: ~p"/mascotas")

      false ->
        conn
        |> put_flash(:error, "No está autorizado(a) para esta operación.")
        |> redirect(to: ~p"/mascotas")
    end
  end
end
