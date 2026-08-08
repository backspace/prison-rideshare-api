defmodule Mix.Tasks.ConvertPostsToMarkdown do
  use Mix.Task

  @shortdoc "Convert log posts from mobiledoc to Markdown"

  @moduledoc """
  Rewrites every post's `content` from a mobiledoc JSON blob to Markdown,
  keeping the original in `content_mobiledoc`.

  Posts that already have a `content_mobiledoc` are skipped, so the task is safe
  to re-run. A post whose content will not parse as mobiledoc is reported and
  left alone rather than guessed at.

      mix convert_posts_to_markdown --dry-run
      mix convert_posts_to_markdown
  """

  import Ecto.Query

  alias PrisonRideshare.{Mobiledoc, Repo}
  alias PrisonRideshareWeb.Post

  def run(args) do
    Mix.Task.run("app.start")

    dry_run? = "--dry-run" in args

    posts = Repo.all(from(p in Post, where: is_nil(p.content_mobiledoc), order_by: p.inserted_at))

    if dry_run?, do: Mix.shell().info("Dry run — no changes will be written.\n")
    Mix.shell().info("#{length(posts)} post(s) to convert.\n")

    results = Enum.map(posts, &convert(&1, dry_run?))

    report(results)
  end

  defp convert(post, dry_run?) do
    with {:ok, decoded} <- decode(post.content),
         {:ok, markdown, warnings} <- Mobiledoc.to_markdown(decoded) do
      unless dry_run? do
        post
        |> Ecto.Changeset.change(%{content: markdown, content_mobiledoc: post.content})
        |> Repo.update!()
      end

      {:converted, post.id, warnings}
    else
      {:error, reason} -> {:skipped, post.id, reason}
    end
  end

  defp decode(content) do
    case Jason.decode(content) do
      {:ok, %{} = decoded} -> {:ok, decoded}
      {:ok, _} -> {:error, "content is JSON but not an object; leaving alone"}
      {:error, _} -> {:error, "content is not JSON, so is probably already Markdown"}
    end
  end

  defp report(results) do
    converted = Enum.filter(results, &match?({:converted, _, _}, &1))
    skipped = Enum.filter(results, &match?({:skipped, _, _}, &1))
    warned = Enum.filter(converted, fn {_, _, warnings} -> warnings != [] end)

    Enum.each(warned, fn {_, id, warnings} ->
      Mix.shell().info("converted with warnings: #{id}")
      Enum.each(warnings, &Mix.shell().info("    #{&1}"))
    end)

    Enum.each(skipped, fn {_, id, reason} ->
      Mix.shell().error("skipped: #{id} — #{reason}")
    end)

    Mix.shell().info(
      "\n#{length(converted)} converted (#{length(warned)} with warnings), #{length(skipped)} skipped."
    )
  end
end
