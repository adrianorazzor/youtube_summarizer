defmodule YoutubeSummarizer.Youtube.Client do
  @moduledoc """
    Client for interacting with the Youtube Data API.
  """

  @doc """
    Fetches subtitle text for a given Youtube video URL and language
  """
  def fetch_subtitles(_url, _language) do
    # TODO: Implement Youtube API call to fetch subtitles
    {:ok, "Sambple subtitle text"}
  end



end
