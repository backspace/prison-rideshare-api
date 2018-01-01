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

  def calendar_link(person, month) do
    {:ok, magic_token, _claims} = PrisonRideshare.PersonGuardian.encode_magic(person)

    new_email(
      to: person.email,
      from: {"Bar None Bot", "bot@barnonewpg.org"},
      subject: "Rideshare calendar for #{month}"
    )
    |> assign(:person, person)
    |> assign(:month, month)
    # FIXME
    |> assign(:link, "https://rideshare.barnonewpg.org/calendar/#{month}?token=#{magic_token}")
    |> render("calendar_link.html")
  end
end
