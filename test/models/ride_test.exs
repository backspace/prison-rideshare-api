defmodule PrisonRideshare.RideTest do
  use PrisonRideshare.ModelCase

  alias PrisonRideshare.{Institution, Ride}

  import Money.Sigils

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

  @valid_report_attrs %{
    distance: 10,
    report_notes: "Notes!",
    food_expenses: 100
  }

  test "report changeset with valid attributes calculates the car expenses" do
    changeset = Ride.report_changeset(%Ride{institution: %Institution{rate: ~M[40]}}, @valid_report_attrs)
    assert changeset.valid?
    assert Ecto.Changeset.get_field(changeset, :car_expenses) == ~M[400]
  end

  test "report changeset with invalid attributes" do
    changeset = Ride.report_changeset(%Ride{}, @invalid_attrs)
    refute changeset.valid?
  end
end
