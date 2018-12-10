defmodule PrisonRideshareWeb.OverlapRideView do
  use PrisonRideshareWeb, :view
  use JaSerializer.PhoenixView

  def type(_, _), do: "rides"

  has_many(
    :commitments,
    type: "commitments",
    include: true,
    serializer: PrisonRideshareWeb.OverlapCommitmentView
  )
end
