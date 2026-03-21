defmodule PrisonRideshare.MailerRateLimiter do
  @behaviour Bamboo.DeliverLaterStrategy
  use GenServer

  require Logger

  @default_interval_ms 30000

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl Bamboo.DeliverLaterStrategy
  def deliver_later(adapter, email, config) do
    GenServer.cast(__MODULE__, {:enqueue, adapter, email, config})
  end

  @impl GenServer
  def init(_opts) do
    {:ok,
     %{
       queue: :queue.new(),
       interval_ms: delivery_interval_ms(),
       in_flight: false
     }}
  end

  @impl GenServer
  def handle_cast({:enqueue, adapter, email, config}, state) do
    state = %{state | queue: :queue.in({adapter, email, config}, state.queue)}
    queue_size = :queue.len(state.queue)
    Logger.info("Mail queued: to=#{inspect(email.to)} subject=#{inspect(email.subject)} queue_size=#{queue_size}")
    {:noreply, maybe_schedule(state)}
  end

  @impl GenServer
  def handle_info(:deliver_next, state) do
    case :queue.out(state.queue) do
      {{:value, {adapter, email, config}}, queue} ->
        remaining = :queue.len(queue)
        Logger.info("Mail sending: to=#{inspect(email.to)} subject=#{inspect(email.subject)} remaining=#{remaining}")
        deliver(adapter, email, config)
        state = %{state | queue: queue}

        if :queue.is_empty(queue) do
          Logger.info("Mail queue drained")
          {:noreply, %{state | in_flight: false}}
        else
          Logger.info("Mail queue scheduling next delivery in #{state.interval_ms}ms remaining=#{remaining}")
          Process.send_after(self(), :deliver_next, state.interval_ms)
          {:noreply, state}
        end

      {:empty, _queue} ->
        {:noreply, %{state | in_flight: false}}
    end
  end

  defp maybe_schedule(%{in_flight: true} = state), do: state

  defp maybe_schedule(state) do
    send(self(), :deliver_next)
    %{state | in_flight: true}
  end

  defp deliver(adapter, email, config) do
    try do
      case adapter.deliver(email, config) do
        {:error, error} ->
          Logger.error("Email delivery failed: #{inspect(error)}")

        _ ->
          Logger.info("Mail sent: to=#{inspect(email.to)} subject=#{inspect(email.subject)}")
      end
    rescue
      exception ->
        Logger.error(Exception.format(:error, exception, __STACKTRACE__))
    catch
      kind, reason ->
        Logger.error(Exception.format(kind, reason, __STACKTRACE__))
    end
  end

  defp delivery_interval_ms do
    config = Application.get_env(:prison_rideshare, PrisonRideshare.Mailer, [])
    config[:rate_limit_ms] || @default_interval_ms
  end
end
