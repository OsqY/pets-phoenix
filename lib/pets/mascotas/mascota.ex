defmodule Pets.Mascotas.Mascota do
  use Ecto.Schema
  import Ecto.Changeset

  @estado_options [
    "En Adopción": :EnAdopcion,
    "Con Hogar": :ConHogar,
    Adoptado: :Adoptado,
    "En proceso de Adopción": :EnProcesoAdopcion
  ]

  @energia_options [
    Alta: :Alta,
    Media: :Media,
    Baja: :Baja
  ]

  schema "mascotas" do
    field :nombre, :string
    field :descripcion, :string
    field :edad, :integer
    field :sexo, :string
    field :tamanio, :string
    field :peso, :float
    field :sociable_mascotas, :boolean
    field :sociable_personas, :boolean
    field :necesidades_especiales, :string
    field :historia, :string

    field :estado, Ecto.Enum, values: Keyword.values(@estado_options)
    field :energia, Ecto.Enum, values: Keyword.values(@energia_options)

    belongs_to :usuario, Pets.Cuentas.Usuario
    belongs_to :color, Pets.Mascotas.Color
    belongs_to :especie, Pets.Mascotas.Especie
    belongs_to :raza, Pets.Mascotas.Raza

    has_many :posts, Pets.Posts.Post

    embeds_many :imagenes, Imagenes, on_replace: :delete do
      field :url, :string
      field :imagen, :any, virtual: true
    end

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(mascota, attrs, usuario_scope) do
    mascota
    |> cast(attrs, [
      :nombre,
      :descripcion,
      :edad,
      :sexo,
      :tamanio,
      :peso,
      :color_id,
      :especie_id,
      :raza_id,
      :sociable_mascotas,
      :sociable_personas,
      :energia,
      :historia,
      :necesidades_especiales,
      :estado
    ])
    |> validate_required([
      :nombre,
      :descripcion,
      :edad,
      :sexo,
      :tamanio,
      :peso,
      :color_id,
      :especie_id,
      :raza_id,
      :sociable_mascotas,
      :sociable_personas,
      :energia,
      :estado
    ])
    |> put_change(:usuario_id, usuario_scope.usuario.id)
    |> cast_embed(:imagenes, with: &imagen_changeset/2)
  end

  def estado_options, do: @estado_options
  def energia_options, do: @energia_options

  def humanize_estado(atom) do
    Enum.find_value(@estado_options, "N/A", fn {label, val} ->
      if val == atom, do: label
    end)
  end

  def humanize_energia(atom) do
    Enum.find_value(@energia_options, "N/A", fn {label, val} ->
      if val == atom, do: label
    end)
  end

  def imagen_changeset(imagen, params) do
    imagen |> cast(params, [:url, :imagen])
  end

  @doc """
  Changeset para validar el borrado de una mascota.
  Previene el borrado si tiene posts asociados.
  """
  def delete_changeset(mascota) do
    mascota
    |> change()
    |> no_assoc_constraint(:posts,
      message: "No se puede eliminar esta mascota porque tiene publicaciones asociadas."
    )
  end
end
