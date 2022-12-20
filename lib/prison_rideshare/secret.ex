defmodule PrisonRideshare.Secret do
  use Ecto.Type

  def type, do: :string

  def cast(string) do
    {:ok, string}
  end

  def load(string) do
    {:ok, string}
  end

  def dump(string) do
    {:ok, string}
  end

  def autogenerate do
    :crypto.strong_rand_bytes(32) |> Base.encode64() |> binary_part(0, 32)
  end
end
