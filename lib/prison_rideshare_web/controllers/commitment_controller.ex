defmodule PrisonRideshareWeb.CommitmentController do
  use PrisonRideshareWeb, :controller

  alias PrisonRideshareWeb.{Commitment}

  def delete(conn, %{"id" => id}) do
    commitment = Repo.get!(Commitment, id)
    PaperTrail.delete!(commitment, version_information(conn))
    send_resp(conn, :no_content, "")
  end
end
