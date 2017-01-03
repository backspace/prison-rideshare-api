defmodule PrisonRideshare.MoneyHelper do
  defmacro money_amount(property) do
    quote do
      def unquote(property)(model, _conn) do
        case Map.get(model, unquote(property)) do
          nil -> 0
          %{amount: amount} -> amount
        end
      end
    end
  end
end
