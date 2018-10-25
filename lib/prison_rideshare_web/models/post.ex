defmodule PrisonRideshareWeb.Post do
  use PrisonRideshareWeb, :model

  schema "posts" do
    field(:content, :string)
    belongs_to(:poster, PrisonRideshareWeb.User, foreign_key: :poster_id)

    timestamps(type: :utc_datetime)
  end
end
