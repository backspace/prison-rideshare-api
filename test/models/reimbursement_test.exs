defmodule PrisonRideshare.ReimbursementTest do
  use PrisonRideshare.ModelCase

  alias PrisonRideshare.Reimbursement

  @valid_attrs %{car_expenses: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Reimbursement.changeset(%Reimbursement{}, @valid_attrs)
    assert changeset.valid?
  end
end
