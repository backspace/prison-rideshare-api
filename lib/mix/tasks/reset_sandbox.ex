defmodule Mix.Tasks.ResetSandbox do
  use Mix.Task

  @shortdoc "Reset the database with sandbox data"

  def run(_) do
    Mix.Task.run("ecto.rollback", ["--all"])
    Mix.Task.run("ecto.migrate")

    Mix.Task.run("run", ["priv/repo/slots.exs"])
    Mix.Task.rerun("run", ["priv/repo/sandbox_seeds.exs"])
  end
end
