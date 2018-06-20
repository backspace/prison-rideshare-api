defmodule PrisonRideshare.Email do
  use Bamboo.Phoenix, view: PrisonRideshare.EmailView

  def report(ride) do
    start =
      Timex.Timezone.convert(Ecto.DateTime.to_erl(ride.start), "America/Winnipeg")
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
    full_month = Timex.parse!(month, "{YYYY}-{0M}") |> Timex.format!("{Mfull} {YYYY}")

    new_email(
      to: person.email,
      from: {"Bar None Bot", "bot@barnonewpg.org"},
      subject: "Commit to bringing visitors to their loved ones for #{full_month}"
    )
    |> assign(:person, person)
    |> assign(:month, full_month)
    |> assign(
      :link,
      "#{Application.get_env(:prison_rideshare, :ui_root)}/calendar/#{month}?token=#{magic_token}"
    )
    |> render(:calendar_link)
  end
end
