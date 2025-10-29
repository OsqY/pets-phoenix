defmodule PetsWeb.MascotaHTML do
  use PetsWeb, :html

  embed_templates "mascota_html/*"

  @doc """
  Renders a mascota form.

  The form is defined in the template at
  mascota_html/mascota_form.html.heex
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :return_to, :string, default: nil

  def mascota_form(assigns)
end
