defmodule Mix.Tasks.ResetSandbox do
  use Mix.Task

  def run(_) do
    Mix.Task.run "ecto.rollback", ["--all"]
    Mix.Task.run "ecto.migrate"
    Mix.Task.run "run", ["priv/repo/sandbox_seeds.exs"]
  end
end
