defmodule PrisonRideshareWeb.RideTest do
  use PrisonRideshare.ModelCase

  alias PrisonRideshareWeb.Ride

  import Money.Sigils

  @valid_attrs %{
    name: "some content",
    address: "some content",
    contact: "some content",
    end: %{day: 17, month: 4, year: 2010, hour: 14, min: 0, sec: 0},
    notes: "some content",
    passengers: 42,
    start: %{day: 17, month: 4, year: 2010, hour: 14, min: 0, sec: 0},
    first_time: true,
    medium: "phone",
    request_confirmed: true
  }
  @invalid_attrs %{}

  setup do
    {:ok, %{institution: PrisonRideshare.Repo.insert!(%PrisonRideshareWeb.Institution{})}}
  end

  test "changeset with valid attributes", %{institution: institution} do
    changeset = Ride.changeset(%Ride{institution_id: institution.id}, @valid_attrs)
    assert changeset.errors == []
    assert changeset.valid?
  end

  test "changeset with invalid attributes", %{institution: institution} do
    changeset = Ride.changeset(%Ride{institution_id: institution.id}, @invalid_attrs)
    refute changeset.valid?
  end

  @valid_report_attrs %{
    distance: 10,
    report_notes: "Notes!",
    food_expenses: 100
  }

  test "report changeset with valid attributes calculates the car expenses" do
    changeset = Ride.report_changeset(%Ride{rate: ~M[40]}, @valid_report_attrs)

    assert changeset.valid?
    assert Ecto.Changeset.get_field(changeset, :car_expenses) == ~M[400]
  end

  test "report changeset ignores submitted car expenses when not overridable" do
    changeset = Ride.report_changeset(%Ride{rate: ~M[40]}, %{distance: 10, car_expenses: 100})

    assert changeset.valid?
    assert Ecto.Changeset.get_field(changeset, :car_expenses) == ~M[400]
  end

  test "report changeset allows car expenses to override calculated value when overridable" do
    changeset =
      Ride.report_changeset(%Ride{rate: ~M[40], overridable: true}, %{
        distance: 10,
        car_expenses: 100
      })

    assert changeset.valid?
    assert Ecto.Changeset.get_field(changeset, :car_expenses) == ~M[100]
  end

  test "changeset without a distance does not calculate car expenses", %{institution: institution} do
    changeset =
      Ride.changeset(%Ride{institution_id: institution.id, rate: ~M[40]}, %{
        start: @valid_attrs.start,
        end: @valid_attrs.end,
        name: @valid_attrs.name,
        passengers: 1,
        address: "an address",
        contact: "contact",
        report_notes: "hello"
      })

    assert changeset.valid?
    assert Ecto.Changeset.get_field(changeset, :report_notes) == "hello"
    assert Ecto.Changeset.get_field(changeset, :car_expenses) == 0
  end

  test "changeset with overridable does not calculate car expenses", %{institution: institution} do
    changeset =
      Ride.changeset(%Ride{institution_id: institution.id, rate: ~M[40], overridable: true}, %{
        start: @valid_attrs.start,
        end: @valid_attrs.end,
        name: @valid_attrs.name,
        passengers: 1,
        address: "an address",
        contact: "contact",
        report_notes: "hello",
        distance: 11,
        car_expenses: ~M[1001]
      })

    assert changeset.errors == []
    assert changeset.valid?
    assert Ecto.Changeset.get_field(changeset, :car_expenses) == ~M[1001]
  end

  test "report changeset with invalid attributes" do
    changeset = Ride.report_changeset(%Ride{}, @invalid_attrs)
    refute changeset.valid?
  end
end
