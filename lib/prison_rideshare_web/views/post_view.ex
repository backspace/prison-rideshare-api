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
    type: "user",
    include: true,
    serializer: PrisonRideshareWeb.UserView
  )
end
