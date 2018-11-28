defmodule PrisonRideshareWeb.OverlapRideView do
  use PrisonRideshareWeb, :view
  use JaSerializer.PhoenixView

  def type(_, _), do: "ride"

  has_many(
    :commitments,
    type: "commitment",
    include: true,
    serializer: PrisonRideshareWeb.CommitmentView
  )
end
