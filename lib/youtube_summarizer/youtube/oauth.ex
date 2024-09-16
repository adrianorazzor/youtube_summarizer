defmodule YoutubeSummarizer.Youtube.OAuth do
  use OAuth2.Strategy
  require Logger

  def client do
    OAuth2.Client.new([
      strategy: __MODULE__,
      client_id: Application.get_env(:youtube_summarizer, :youtube_client_id),
      client_secret: Application.get_env(:youtube_summarizer, :youtube_client_secret),
      redirect_uri: Application.get_env(:youtube_summarizer, :youtube_redirect_uri),
      site: "https://accounts.google.com",
      authorize_url: "https://accounts.google.com/o/oauth2/auth",
      token_url: "https://oauth2.googleapis.com/token"
    ])
  end

  def authorize_url! do
    client()
    |> OAuth2.Client.put_param(:client_id, client().client_id)
    |> OAuth2.Client.put_param(:response_type, "code")
    |> OAuth2.Client.put_param(:scope, "https://www.googleapis.com/auth/youtube.force-ssl https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile")
    |> OAuth2.Client.authorize_url!()
  end

  def get_token!(params \\ [], headers \\ []) do
    Logger.debug("Getting token with params: #{inspect(params)}")
    client = client()
    |> OAuth2.Client.put_param(:client_secret, client().client_secret)
    |> OAuth2.Client.put_param(:grant_type, "authorization_code")

    case OAuth2.Client.get_token(client, params, headers) do
      {:ok, client} ->
        access_token = client.token.access_token
        case Jason.decode(access_token) do
          {:ok, decoded} ->
            %{client | token: %{client.token | access_token: decoded["access_token"]}}
          {:error, _} ->
            Logger.error("Failed to decode access token: #{access_token}")
            client
        end
      {:error, error} ->
        Logger.error("Failed to get token: #{inspect(error)}")
        raise error
    end
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param(:client_secret, client.client_secret)
    |> put_header("accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
