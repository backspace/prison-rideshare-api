defmodule PrisonRideshare.Mobiledoc do
  @moduledoc """
  Converts mobiledoc 0.3.x documents to Markdown.

  Only the feature set the log's editor could produce is supported: the
  `strong`/`em`/`a` markups and the `p`/`h1`/`h2`/`blockquote`/`pull-quote`/`ul`/`ol`
  sections. Cards and atoms are an error rather than a silent omission — the
  editor was configured with neither, so encountering one means the document is
  not what we think it is.
  """

  @markup_section 1
  @image_section 2
  @list_section 3
  @card_section 10

  @text_marker 0

  @doc """
  Converts a decoded mobiledoc document.

  Returns `{:ok, markdown, warnings}` or `{:error, reason}`.
  """
  def to_markdown(%{"sections" => sections} = doc) do
    markups = Map.get(doc, "markups", [])

    cond do
      Map.get(doc, "cards", []) != [] ->
        {:error, "document declares cards, which the converter cannot represent"}

      Map.get(doc, "atoms", []) != [] ->
        {:error, "document declares atoms, which the converter cannot represent"}

      true ->
        sections
        |> Enum.reduce_while({[], []}, fn section, {blocks, warnings} ->
          case section_to_markdown(section, markups) do
            {:ok, block, new_warnings} -> {:cont, {[block | blocks], warnings ++ new_warnings}}
            {:error, reason} -> {:halt, {:error, reason}}
          end
        end)
        |> case do
          {:error, reason} ->
            {:error, reason}

          {blocks, warnings} ->
            markdown =
              blocks
              |> Enum.reverse()
              |> Enum.reject(&(String.trim(&1) == ""))
              |> Enum.join("\n\n")

            {:ok, markdown, warnings}
        end
    end
  end

  def to_markdown(_), do: {:error, "not a mobiledoc document (no sections)"}

  defp section_to_markdown([@markup_section, tag, markers | rest], markups) do
    attribute_warnings =
      case rest do
        [attributes] when attributes != [] ->
          ["dropped section attributes on <#{tag}>: #{Enum.join(attributes, "=")}"]

        _ ->
          []
      end

    text = markers_to_markdown(markers, markups)

    case String.downcase(tag) do
      "h1" ->
        {:ok, "# " <> text, attribute_warnings}

      "h2" ->
        {:ok, "## " <> text, attribute_warnings}

      "h3" ->
        {:ok, "### " <> text, attribute_warnings}

      "blockquote" ->
        {:ok, prefix_lines(text, "> "), attribute_warnings}

      "pull-quote" ->
        {:ok, prefix_lines(text, "> "),
         attribute_warnings ++ ["pull-quote collapsed to blockquote"]}

      _ ->
        {:ok, text, attribute_warnings}
    end
  end

  defp section_to_markdown([@list_section, tag, items], markups) do
    ordered? = String.downcase(tag) == "ol"

    text =
      items
      |> Enum.with_index(1)
      |> Enum.map_join("\n", fn {markers, index} ->
        bullet = if ordered?, do: "#{index}. ", else: "- "
        bullet <> markers_to_markdown(markers, markups)
      end)

    {:ok, text, []}
  end

  defp section_to_markdown([@image_section, src], _markups), do: {:ok, "![](#{src})", []}

  defp section_to_markdown([@card_section, name | _], _markups),
    do: {:error, "card section encountered: #{name}"}

  defp section_to_markdown(section, _markups),
    do: {:error, "unrecognised section: #{inspect(section)}"}

  # Markers carry markup open/close instructions rather than nesting, so we
  # rebuild the tree with a stack: each open pushes a frame, each close pops one
  # and folds its text into its parent.
  defp markers_to_markdown(markers, markups) do
    markers
    |> Enum.reduce([%{markup: nil, parts: []}], fn marker, stack ->
      [type, open_indices, close_count, value] = marker

      stack =
        Enum.reduce(open_indices, stack, fn index, acc ->
          [%{markup: Enum.at(markups, index), parts: []} | acc]
        end)

      text = if type == @text_marker, do: escape(value), else: ""
      stack = push_text(stack, text)

      Enum.reduce(1..close_count//1, stack, fn _, acc -> close_frame(acc) end)
    end)
    |> collapse()
  end

  defp push_text([top | rest], text), do: [%{top | parts: [text | top.parts]} | rest]

  defp close_frame([frame, parent | rest]) do
    [%{parent | parts: [wrap(frame.markup, render_parts(frame.parts)) | parent.parts]} | rest]
  end

  defp close_frame(stack), do: stack

  defp collapse([%{parts: parts}]), do: render_parts(parts)
  defp collapse(stack), do: stack |> close_frame() |> collapse()

  defp render_parts(parts), do: parts |> Enum.reverse() |> Enum.join()

  defp wrap(nil, text), do: text

  defp wrap([tag | attrs], text) do
    case String.downcase(tag) do
      bold when bold in ["strong", "b"] -> "**#{text}**"
      italic when italic in ["em", "i"] -> "_#{text}_"
      "code" -> "`#{text}`"
      "a" -> "[#{text}](#{href(attrs)})"
      _ -> text
    end
  end

  defp href([attributes]) when is_list(attributes) do
    attributes
    |> Enum.chunk_every(2)
    |> Enum.find_value("", fn
      ["href", value] -> value
      _ -> nil
    end)
  end

  defp href(_), do: ""

  defp escape(text), do: String.replace(text, ~r/([\\`*_\[\]])/, "\\\\\\1")

  defp prefix_lines(text, prefix) do
    text
    |> String.split("\n")
    |> Enum.map_join("\n", &(prefix <> &1))
  end
end
