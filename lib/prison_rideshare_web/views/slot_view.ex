defmodule PrisonRideshareWeb.SlotView do
  use PrisonRideshareWeb, :view
  use JaSerializer.PhoenixView

  attributes [:start, :end]

  def start(%{start: nil}, _conn), do: nil
  def start(%{start: start}, _conn), do: "#{NaiveDateTime.to_iso8601(start)}Z"

  def unquote(:"end")(%{end: nil}, _conn), do: nil
  def unquote(:"end")(%{end: end_time}, _conn), do: "#{NaiveDateTime.to_iso8601(end_time)}Z"
end
