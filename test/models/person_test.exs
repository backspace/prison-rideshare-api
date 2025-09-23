defmodule PrisonRideshareWeb.PersonTest do
  use PrisonRideshare.ModelCase

  alias PrisonRideshareWeb.Person

  test "changeset with name/email and landline is valid" do
    changeset =
      Person.changeset(%Person{}, %{
        name: "chelsea",
        email: "chelsea@example.com",
        landline: "5145551313"
      })

    assert changeset.valid?
  end

  test "changeset with name/email and mobile is valid" do
    changeset =
      Person.changeset(%Person{}, %{
        name: "manning",
        email: "manning@example.com",
        mobile: "5145551313"
      })

    assert changeset.valid?
  end

  test "changeset with name/email and no phone is valid" do
    changeset =
      Person.changeset(%Person{}, %{name: "chelsea manning", email: "chelsea.manning@example.com"})

    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Person.changeset(%Person{}, %{name: "no"})
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
