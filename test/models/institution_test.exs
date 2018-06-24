defmodule PrisonRideshareWeb.InstitutionTest do
  use PrisonRideshare.ModelCase

  alias PrisonRideshareWeb.Institution

  @valid_attrs %{name: "some content", rate: 42, far: true}
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
