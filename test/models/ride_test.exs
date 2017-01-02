defmodule PrisonRideshare.RideTest do
  use PrisonRideshare.ModelCase

  alias PrisonRideshare.Ride

  @valid_attrs %{name: "some content", address: "some content", contact: "some content", end: %{day: 17, month: 4, year: 2010, hour: 14, min: 0, sec: 0}, notes: "some content", passengers: 42, start: %{day: 17, month: 4, year: 2010, hour: 14, min: 0, sec: 0}}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Ride.changeset(%Ride{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Ride.changeset(%Ride{}, @invalid_attrs)
    refute changeset.valid?
  end
end
