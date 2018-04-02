alias PrisonRideshareWeb.Slot

require Logger

defmodule Ugh do
  def date_to_day_type(date) do
    case Timex.weekday(date) do
      1 -> :monday_tuesday
      2 -> :monday_tuesday
      3 -> :wednesday_thursday
      4 -> :wednesday_thursday
      5 -> :friday
      6 -> :saturday
      7 -> :sunday
    end
  end

  def to_ecto(timex) do
    timex
    |> Timex.to_datetime()
    |> Timex.Protocol.to_naive_datetime()
  end
end

day_type_slots = %{
  monday_tuesday: [
    "2*17-22"
  ],
  wednesday_thursday: [
    "1*12-16",
    "2*17-22"
  ],
  friday: [
    "1*12-16"
  ],
  saturday: [
    "1*08-12",
    "2*12-17",
    "1*18-22"
  ],
  sunday: [
    "1*08-12",
    "3*12-17"
  ]
}

first_day =
  (List.first(System.argv) || Timex.format!(DateTime.utc_now, "{YYYY}-{0M}-01"))
  |> Timex.parse!("{YYYY}-{0M}-{0D}")

days_in_month =
  first_day
  |> Timex.days_in_month()

dates_in_month =
  Enum.map(0..(days_in_month - 1), fn day_of_month ->
    Timex.shift(first_day, days: day_of_month)
  end)

Logger.info("dates in month:")
Logger.info(inspect(dates_in_month))

slots =
  Enum.flat_map(dates_in_month, fn date ->
    day_type = Ugh.date_to_day_type(date)
    day_slots = day_type_slots[day_type]

    Enum.map(day_slots, fn day_slot ->
      [count, window] = String.split(day_slot, "*")
      [slot_start_text, slot_end_text] = String.split(window, "-")

      {date_part, _time_part} = Timex.to_erl(date)

      slot_start =
        Timex.to_datetime(
          NaiveDateTime.from_erl!({date_part, {String.to_integer(slot_start_text), 0, 0}}),
          "America/Winnipeg"
        )
        |> Ugh.to_ecto()

      slot_end =
        Timex.to_datetime(
          NaiveDateTime.from_erl!({date_part, {String.to_integer(slot_end_text), 0, 0}}),
          "America/Winnipeg"
        )
        |> Ugh.to_ecto()

      %Slot{
        start: slot_start,
        end: slot_end,
        count: String.to_integer(count)
      }
    end)
  end)

Logger.info(inspect(slots))

Enum.each(slots, fn slot ->
  PrisonRideshare.Repo.insert!(slot)
end)
