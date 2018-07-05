defmodule PrisonRideshareWeb.MoneyHelper do
  defmacro money_amount(property, convert_nil_to_zero \\ true) do
    quote do
      def unquote(property)(model, _conn) do
        nil_value = if unquote(convert_nil_to_zero), do: 0, else: nil

        case Map.get(model, unquote(property)) do
          nil -> nil_value
          0 -> 0
          %{amount: amount} -> amount
        end
      end
    end
  end
end
