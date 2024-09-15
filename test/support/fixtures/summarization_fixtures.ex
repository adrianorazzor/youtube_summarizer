defmodule YoutubeSummarizer.SummarizationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `YoutubeSummarizer.Summarization` context.
  """

  @doc """
  Generate a summary.
  """
  def summary_fixture(attrs \\ %{}) do
    {:ok, summary} =
      attrs
      |> Enum.into(%{
        original_text: "some original_text",
        summary_text: "some summary_text"
      })
      |> YoutubeSummarizer.Summarization.create_summary()

    summary
  end
end
