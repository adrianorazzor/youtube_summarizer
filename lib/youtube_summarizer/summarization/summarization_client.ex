defmodule YoutubeSummarizer.Summarization.Client do
  @moduledoc """
  Client for interacting with the Anthropic API.
  """

  use HTTPoison.Base

  @base_url "https://api.anthropic.com/v1"

  def process_url(url) do
    @base_url <> url
  end

  def process_request_headers(headers) do
    [
      {"Content-Type", "application/json"},
      {"X-API-Key", Application.get_env(:youtube_summarizer, :anthropic_api_key)}
      | headers
    ]
  end

  def process_response_body(body) do
    Jason.decode!(body)
  end


  @doc """
  Summarizes the given text using the Anthropic API.
  """
  def summarize(text)do
    request_body = Jason.encode!(%{
      model: "claude-3-opus-20240229",
      max_tokens: 1000,
      messages: [
        %{
          role: "user",
          content: "Please summarize the following text: \n\n#{text}"
        }
      ]
    })

    case post("/chat/completions", request_body) do
      {:ok, %{status_code: 200, body: body}} ->
        summary = body["content"][0]["text"]
        {:ok, summary}

        {:ok, %{status_code: 429}} ->
          {:error, "Anthropic rate limit exceeded"}

        {:ok, %{status_code: status_code, body: body}} ->
          {:error, "Anthropic API error: #{status_code}  - #{body["error"]["message"]}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP rquest failed: #{reason}"}
    end

  end


  @doc """
  Expands the given summary using the Anthropic API.
  """
  def expand(summary) do
    request_body = Jason.encode!(%{
      model: "claude-3-opus-20240229",
      max_tokens: 2000,
      messages: [
        %{
          role: "user",
          content: "Please expand on the following summary with more details: \n\n#{summary}"
        }
      ]
    })

    case post("/chat/completions", request_body) do
      {:ok, %{status_code: 200, body: body}} ->
        expanded_summary = body["content"][0]["text"]
        {:ok, expanded_summary}

      {:ok, %{status_code: 429}} ->
        {:error, "Anthropic API rate limit exceeded"}

      {:ok, %{status_code: status_code, body: body}} ->
        {:error, "Anthropic API error: #{status_code} - #{body["error"]["message"]}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{reason}"}
    end
  end



end
