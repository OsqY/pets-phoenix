alias Pets.Repo
alias Pets.Cuentas.Usuario
alias Pets.Mascotas.{Especie, Raza, Color}

admin =
  case Repo.get_by(Usuario, email: "admin@gmail.com") do
    nil ->
      Repo.insert!(%Usuario{
        email: "admin@gmail.com",
        hashed_password: Bcrypt.hash_pwd_salt("passwordAdmin123_"),
        roles: ["admin"],
        confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second)
      })

    existing ->
      existing
  end

perro = Repo.insert!(%Especie{nombre: "Perro"})
gato = Repo.insert!(%Especie{nombre: "Gato"})
conejo = Repo.insert!(%Especie{nombre: "Conejo"})
hamster = Repo.insert!(%Especie{nombre: "Hámster"})
ave = Repo.insert!(%Especie{nombre: "Ave"})

razas_perro = [
  "Mestizo",
  "Labrador Retriever",
  "Pastor Alemán",
  "Golden Retriever",
  "Bulldog Francés",
  "Beagle",
  "Poodle",
  "Chihuahua",
  "Husky Siberiano",
  "Rottweiler",
  "Boxer",
  "Dálmata",
  "Cocker Spaniel",
  "Pitbull",
  "Schnauzer"
]

razas_gato = [
  "Mestizo",
  "Persa",
  "Siamés",
  "Maine Coon",
  "Bengalí",
  "Ragdoll",
  "Británico de Pelo Corto",
  "Abisinio",
  "Sphynx",
  "Scottish Fold"
]

razas_conejo = [
  "Mestizo",
  "Holland Lop",
  "Mini Rex",
  "Cabeza de León",
  "Angora",
  "Netherland Dwarf"
]

razas_hamster = [
  "Sirio",
  "Roborovski",
  "Ruso",
  "Chino"
]

razas_ave = [
  "Periquito",
  "Canario",
  "Cacatúa",
  "Agapornis",
  "Cotorra"
]

for nombre <- razas_perro ++ razas_gato ++ razas_conejo ++ razas_hamster ++ razas_ave do
  Repo.insert!(%Raza{nombre: nombre, usuario_id: admin.id})
end

colores_perro = [
  "Negro",
  "Blanco",
  "Marrón",
  "Dorado",
  "Gris",
  "Atigrado",
  "Manchado",
  "Bicolor",
  "Tricolor",
  "Crema"
]

colores_gato = [
  "Negro",
  "Blanco",
  "Naranja",
  "Gris",
  "Atigrado",
  "Calicó",
  "Siamés",
  "Bicolor",
  "Tricolor",
  "Crema"
]

colores_conejo = [
  "Blanco",
  "Negro",
  "Gris",
  "Marrón",
  "Manchado",
  "Canela"
]

colores_hamster = [
  "Dorado",
  "Blanco",
  "Gris",
  "Marrón",
  "Manchado"
]

colores_ave = [
  "Verde",
  "Amarillo",
  "Azul",
  "Blanco",
  "Naranja",
  "Multicolor"
]

for nombre <- colores_perro do
  Repo.insert!(%Color{nombre: nombre, especie_id: perro.id, usuario_id: admin.id})
end

for nombre <- colores_gato do
  Repo.insert!(%Color{nombre: nombre, especie_id: gato.id, usuario_id: admin.id})
end

for nombre <- colores_conejo do
  Repo.insert!(%Color{nombre: nombre, especie_id: conejo.id, usuario_id: admin.id})
end

for nombre <- colores_hamster do
  Repo.insert!(%Color{nombre: nombre, especie_id: hamster.id, usuario_id: admin.id})
end

for nombre <- colores_ave do
  Repo.insert!(%Color{nombre: nombre, especie_id: ave.id, usuario_id: admin.id})
end
