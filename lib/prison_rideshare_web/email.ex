defmodule PrisonRideshare.Email do
  use Bamboo.Phoenix, view: PrisonRideshare.EmailView

  def report(ride) do
    start = Timex.Timezone.convert(Ecto.DateTime.to_erl(ride.start), "America/Winnipeg")
    |> Timex.format!("{h12}:{m} {AM} on {WDshort}, {Mshort} {D} {YYYY}")

    new_email(
      to: ["barnone.coordinator+report@gmail.com", "barnone.wpg+report@gmail.com"],
      from: {"Bar None Bot", "bot@barnonewpg.org"},
      subject: "#{ride.driver.name} report for #{start}"
    )
    |> assign(:ride, ride)
    |> assign(:start, start)
    |> render(:report)
  end
end
