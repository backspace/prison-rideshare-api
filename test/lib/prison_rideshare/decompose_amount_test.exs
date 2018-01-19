import Money.Sigils

defmodule PrisonRideshare.DecomposeAmountTest do
  use ExUnit.Case
  alias PrisonRideshare.DecomposeAmount

  test "it finds a single component" do
    component = %{amount: ~M[100]}

    assert DecomposeAmount.decompose_amount(~M[100], [component]) == [component]
  end

  test "it finds an exact match" do
    matching_component = %{amount: ~M[100]}
    other_component = %{amount: ~M[200]}

    assert DecomposeAmount.decompose_amount(~M[100], [other_component, matching_component]) == [
             matching_component
           ]
  end

  test "it finds components that sum to the amount" do
    first_component = %{amount: ~M[100]}
    second_component = %{amount: ~M[50]}

    assert DecomposeAmount.decompose_amount(~M[150], [first_component, second_component]) == [
             first_component,
             second_component
           ]
  end

  test "it finds components that sum to the amount among many" do
    one = %{amount: ~M[1]}
    ten = %{amount: ~M[10]}
    hundred = %{amount: ~M[100]}
    thousand = %{amount: ~M[1000]}

    assert DecomposeAmount.decompose_amount(~M[1010], [one, ten, hundred, thousand]) == [
             ten,
             thousand
           ]
  end

  test "it returns nil if no match is found" do
    component = %{amount: ~M[100]}

    refute DecomposeAmount.decompose_amount(~M[50], [component])
  end
end
