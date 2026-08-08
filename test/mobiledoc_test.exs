defmodule PrisonRideshare.MobiledocTest do
  use ExUnit.Case, async: true

  alias PrisonRideshare.Mobiledoc

  # Exercises every markup and section the log's editor toolbar could produce,
  # including two markups open at once.
  @document %{
    "version" => "0.3.2",
    "atoms" => [],
    "cards" => [],
    "markups" => [["strong"], ["em"], ["a", ["href", "https://example.org"]]],
    "sections" => [
      [1, "h1", [[0, [], 0, "Headline"]]],
      [1, "h2", [[0, [], 0, "Subheadline"]]],
      [
        1,
        "p",
        [
          [0, [], 0, "Plain, "],
          [0, [0], 1, "bold"],
          [0, [], 0, ", "],
          [0, [1], 1, "italic"],
          [0, [], 0, ", a "],
          [0, [2], 1, "link"],
          [0, [], 0, ", and "],
          [0, [0, 1], 2, "both at once"],
          [0, [], 0, "."]
        ]
      ],
      [1, "blockquote", [[0, [], 0, "A block quote."]]],
      [1, "pull-quote", [[0, [], 0, "A pull quote."]]],
      [3, "ul", [[[0, [], 0, "First bullet"]], [[0, [], 0, "Second bullet"]]]],
      [3, "ol", [[[0, [], 0, "First numbered"]], [[0, [], 0, "Second numbered"]]]],
      [1, "p", [[0, [], 0, "Trailing paragraph."]]]
    ]
  }

  @expected """
  # Headline

  ## Subheadline

  Plain, **bold**, _italic_, a [link](https://example.org), and **_both at once_**.

  > A block quote.

  > A pull quote.

  - First bullet
  - Second bullet

  1. First numbered
  2. Second numbered

  Trailing paragraph.\
  """

  test "converts every supported section and markup" do
    assert {:ok, markdown, warnings} = Mobiledoc.to_markdown(@document)
    assert markdown == @expected
    assert warnings == ["pull-quote collapsed to blockquote"]
  end

  test "an empty document converts to an empty string" do
    assert {:ok, "", []} =
             Mobiledoc.to_markdown(%{
               "version" => "0.3.2",
               "atoms" => [],
               "cards" => [],
               "markups" => [],
               "sections" => []
             })
  end

  test "escapes Markdown syntax appearing in text" do
    assert {:ok, markdown, []} = Mobiledoc.to_markdown(document_with_text("a *b* _c_ [d]"))
    assert markdown == "a \\*b\\* \\_c\\_ \\[d\\]"
  end

  test "warns about the section attributes the current renderer cannot render" do
    section = [1, "p", [[0, [], 0, "Centered."]], ["text-align", "center"]]

    assert {:ok, "Centered.", warnings} = Mobiledoc.to_markdown(sections([section]))
    assert warnings == ["dropped section attributes on <p>: text-align=center"]
  end

  test "refuses documents containing cards or atoms rather than dropping them" do
    assert {:error, reason} =
             Mobiledoc.to_markdown(%{
               "sections" => [],
               "cards" => [["some-card", %{}]],
               "atoms" => []
             })

    assert reason =~ "cards"

    assert {:error, atom_reason} =
             Mobiledoc.to_markdown(%{
               "sections" => [],
               "cards" => [],
               "atoms" => [["some-atom", "text", %{}]]
             })

    assert atom_reason =~ "atoms"
  end

  test "refuses anything that is not a mobiledoc document" do
    assert {:error, _} = Mobiledoc.to_markdown(%{"not" => "mobiledoc"})
  end

  defp document_with_text(text), do: sections([[1, "p", [[0, [], 0, text]]]])

  defp sections(sections) do
    %{
      "version" => "0.3.2",
      "atoms" => [],
      "cards" => [],
      "markups" => [],
      "sections" => sections
    }
  end
end
