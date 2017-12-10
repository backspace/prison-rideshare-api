defmodule PrisonRideshareWeb.Slot do
  use PrisonRideshareWeb, :model

  schema "rides" do
    field :start, :naive_datetime
    field :end, :naive_datetime

    timestamps(type: :utc_datetime)
  end
end
