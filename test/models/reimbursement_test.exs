defmodule PrisonRideshareWeb.ReimbursementTest do
  use PrisonRideshare.ModelCase

  alias PrisonRideshareWeb.Reimbursement

  @valid_attrs %{car_expenses: 42}

  test "changeset with valid attributes" do
    changeset = Reimbursement.changeset(%Reimbursement{}, @valid_attrs)
    assert changeset.valid?
  end
end
