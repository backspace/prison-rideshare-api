defmodule PrisonRideshareWeb.PersonTest do
  use PrisonRideshare.ModelCase

  alias PrisonRideshareWeb.Person

  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Person.changeset(%Person{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Person.changeset(%Person{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "determines initials without whitespace and capitals" do
    assert Person.initials(%Person{name: " francine pascal "}) == "FP"
  end

  test "sets initials for a blank name" do
    assert Person.initials(%Person{name: ""}) == "??"
  end

  test "sets initials for a nil name" do
    assert Person.initials(%Person{name: nil}) == "??"
  end

  test "sets initials for a nil person" do
    assert Person.initials(nil) == "??"
  end

  test "sets initials for a hyphenated name" do
    assert Person.initials(%Person{name: "a hyphenated-name"}) == "AHN"
  end
end
