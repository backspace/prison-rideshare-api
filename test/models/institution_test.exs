defmodule PrisonRideshare.InstitutionTest do
  use PrisonRideshare.ModelCase

  alias PrisonRideshare.Institution

  @valid_attrs %{name: "some content", rate: "120.5"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Institution.changeset(%Institution{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Institution.changeset(%Institution{}, @invalid_attrs)
    refute changeset.valid?
  end
end
