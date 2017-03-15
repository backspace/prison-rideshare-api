defmodule PrisonRideshare.DecomposeAmount do
  def decompose_amount(amount, components) do
    match = Enum.find(components, fn(component) -> component.amount == amount end)

    if match do
      [match]
    else
      mm = Enum.reduce_while(components, [], fn component, acc ->
        if component.amount.amount < amount.amount do
          components_without_this_one = components -- [component]
          reduced_amount = Money.subtract(amount, component.amount)

          decomposed_reduced_amount = decompose_amount(reduced_amount, components_without_this_one)

          if decomposed_reduced_amount do
            {:halt, [component] ++ decomposed_reduced_amount}
          else
            {:cont, nil}
          end
        else
          {:cont, nil}
        end
      end)

      if mm do
        mm
      else
        nil
      end
    end
  end
end
