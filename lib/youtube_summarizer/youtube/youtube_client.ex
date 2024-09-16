defmodule YoutubeSummarizer.Youtube.Client do
  @moduledoc """
    Client for interacting with the Youtube Data API.
  """

  use HTTPoison.Base
  require Logger

  @base_url "https://www.googleapis.com/youtube/v3"

  def process_url(url) do
    processed_url = @base_url <> url
    Logger.debug("Processed URL: #{processed_url}")
    processed_url
  end

  def process_request_headers(headers, conn) do
    access_token = Plug.Conn.get_session(conn, :oauth_token)
    [{"Authorization", "Bearer #{access_token}"} | headers]
  end

  def process_response_body(body) do
    case Jason.decode(body) do
      {:ok, decoded} -> decoded
      {:error, _} -> %{raw_body: body}
    end
  end

  def fetch_video_data(video_id) do
    case api_key() do
      {:ok, key} ->
        params = [
          key: key,
          part: "snippet",
          id: video_id
        ]
        request_with_error_handling("/videos", params)
      {:error, reason} ->
        {:error, reason}
    end
  end

  def fetch_captions(video_id, conn) do
    Logger.debug("Fetching captions for video_id: #{video_id}")
    get("/captions", process_request_headers([], conn), params: [part: "snippet", videoId: video_id])
    |> handle_response()
  end



  def fetch_subtitle_content(caption_id, conn) do
    Logger.debug("Fetching subtitle content for caption_id: #{caption_id}")
    get("/captions/#{caption_id}", process_request_headers([], conn), params: [tfmt: "srt"])
    |> handle_response()
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    {:ok, body}
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: status_code, body: body}}) do
    {:error, "YouTube API error (#{status_code}): #{inspect(body)}"}
  end

  defp handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, "HTTP request failed: #{inspect(reason)}"}
  end

  defp request_with_error_handling(endpoint, params) do
    Logger.debug("Making request to endpoint: #{endpoint}")
    Logger.debug("With params: #{inspect(params)}")

    case get(endpoint, [], params: params) do
      {:ok, %HTTPoison.Response{status_code: 200, body: %{raw_body: raw_body}}} ->
        {:error, "Unexpected response: #{String.slice(raw_body, 0, 100)}..."}
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}
      {:ok, %HTTPoison.Response{status_code: status_code, body: %{raw_body: raw_body}}} ->
        {:error, "YouTube API error (#{status_code}): #{String.slice(raw_body, 0, 100)}..."}
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "YouTube API error (#{status_code}): #{inspect(body)}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{inspect(reason)}"}
    end
  end

  defp api_key do
    case Application.get_env(:youtube_summarizer, :youtube_api_key) do
      nil ->
        Logger.error("YouTube API key is not set")
        {:error, "YouTube API key is not set"}
      key ->
        {:ok, key}
    end
  end

end
