# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Pets.Repo.insert!(%Pets.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Pets.Repo
alias Pets.Cuentas.Usuario

Repo.insert(%Usuario{
  email: "admin@gmail.com",
  password: "passwordAdmin123_",
  roles: ["admin"],
  confirmed_at: NaiveDateTime.utc_now()
})
