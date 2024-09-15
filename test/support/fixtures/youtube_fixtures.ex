defmodule YoutubeSummarizer.YoutubeFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `YoutubeSummarizer.Youtube` context.
  """

  @doc """
  Generate a video.
  """
  def video_fixture(attrs \\ %{}) do
    {:ok, video} =
      attrs
      |> Enum.into(%{
        language: "some language",
        subtitle_text: "some subtitle_text",
        url: "some url"
      })
      |> YoutubeSummarizer.Youtube.create_video()

    video
  end
end
