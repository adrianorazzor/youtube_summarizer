defmodule YoutubeSummarizer.Youtube.Client do
  @moduledoc """
    Client for interacting with the Youtube Data API.
  """

  use HTTPoison.Base

  @base_url "https://googleapis.com/youtube/v3"

  def process_url(url) do
    @base_url <> url
  end

  def process_request_headers(headers) do
    [{"Content-Type", "application/json"} | headers]
  end

  def process_response_body(body) do
    Jason.decode!(body)
  end

  @doc """
    Fetches subtitle text for a given Youtube video URL and language.
  """
  def fetch_subtitles(url, language) do
    with {:ok, video_id} <- extract_video_id(url),
         {:ok, caption_id} <- get_caption_id(video_id, language),
         {:ok, subtitle_text} <- get_subtitle_text(caption_id) do
      {:ok, subtitle_text}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp extract_video_id(url) do
    case Regex.run(~r{(?:youtube\.com/watch\?v=|youtu\.be/)([^&\?]+)}, url) do
      [_, video_id] -> {:ok, video_id}
      _ -> {:error, "Invalid YoutTube URL"}
    end
  end

defp get_caption_id(video_id, language) do
  params = [
    part: "snippet",
    videoId: video_id,
    key: Application.get_env(:youtube_summarizer, :youtube_api_key)
  ]

  case get("/captions", [], params: params) do
    {:ok, %{status_code: 200, body: body}} ->
      caption = Enum.find(body["items"], fn item ->
        item["snippet"]["language"] == language
      end)

      if caption do
        {:ok, caption["id"]}
      else
        {:error, "No captions found for the specified language"}
      end

      {:ok, %{status_code: status_code, body: body}} ->
        {:error, "YouTube API error: #{status_code} - #{body["error"]["message"]}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{reason}"}
  end
end

defp get_subtitle_text(caption_id) do
  params = [
    tfmt: "srt",
    key: Application.get_env(:youtube_summarizer, :youtube_api_key)
  ]

  case get("/captions/#{caption_id}", [], params: params) do
    {:ok, %{status_code: 200, body: body}} ->
      {:ok, parse_srt(body)}

    {:ok, %{status_code: status_code, body: body}} ->
      {:error, "YouTube API error: #{status_code} - #{body["error"]["message"]}"}

    {:error, %HTTPoison.Error{reason: reason}} ->
      {:error, "HTTP request failed: #{reason}"}
  end
end

defp parse_srt(srt_content) do
  srt_content
  |> String.split("\n\n")
  |> Enum.map(fn block ->
    [_index, _timestamp | text] = String.split(block, "\n")
    Enum.join(text, " ")
  end)
  |> Enum.join(" ")
  |> String.trim()
end


end
