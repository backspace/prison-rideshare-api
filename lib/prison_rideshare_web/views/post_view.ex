defmodule PrisonRideshareWeb.PostView do
  use PrisonRideshareWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :content,
    :inserted_at,
    :updated_at
  ])

  has_one(
    :poster,
    field: :poster_id,
    type: "user"
  )
end
