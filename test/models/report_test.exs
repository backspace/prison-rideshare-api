defmodule PrisonRideshare.ReportTest do
  use PrisonRideshare.ModelCase

  alias PrisonRideshare.Report

  @valid_attrs %{distance: "120.5", food: "120.5", notes: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Report.changeset(%Report{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Report.changeset(%Report{}, @invalid_attrs)
    refute changeset.valid?
  end
end
