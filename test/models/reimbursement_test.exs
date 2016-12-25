defmodule PrisonRideshare.ReimbursementTest do
  use PrisonRideshare.ModelCase

  alias PrisonRideshare.Reimbursement

  @valid_attrs %{amount: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Reimbursement.changeset(%Reimbursement{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Reimbursement.changeset(%Reimbursement{}, @invalid_attrs)
    refute changeset.valid?
  end
end
