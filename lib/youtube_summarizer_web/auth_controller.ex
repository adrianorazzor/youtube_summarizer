defmodule YoutubeSummarizerWeb.AuthController do
  use YoutubeSummarizerWeb, :controller
  require Logger

  alias YoutubeSummarizer.Youtube.OAuth

  def request(conn, _params) do
    auth_url = OAuth.authorize_url!()
    Logger.debug("Authorization URL: #{auth_url}")
    redirect(conn, external: auth_url)
  end

  def callback(conn, %{"code" => code}) do
    client = OAuth.client()
    Logger.debug("Callback received. Code: #{code}")
    Logger.debug("Client ID: #{client.client_id}")
    Logger.debug("Redirect URI: #{client.redirect_uri}")

    try do
      client = OAuth.get_token!(code: code)
      Logger.debug("Token received: #{inspect(client.token)}")

      # Use the token to fetch user info
      user_url = "https://www.googleapis.com/oauth2/v2/userinfo"
      headers = [{"Authorization", "Bearer #{client.token.access_token}"}]

      case HTTPoison.get(user_url, headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          user = Jason.decode!(body)
          Logger.debug("User info: #{inspect(user)}")

          conn
          |> put_session(:oauth_token, client.token.access_token)
          |> put_session(:user, user)
          |> redirect(to: "/summarizer")

        {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
          Logger.error("Failed to fetch user info. Status: #{status}, Body: #{body}")
          conn
          |> put_flash(:error, "Failed to fetch user information.")
          |> redirect(to: "/")

        {:error, %HTTPoison.Error{reason: reason}} ->
          Logger.error("HTTPoison error: #{inspect(reason)}")
          conn
          |> put_flash(:error, "An error occurred while fetching user information.")
          |> redirect(to: "/")
      end
    rescue
      e ->
        Logger.error("Error during authentication process: #{inspect(e)}")
        conn
        |> put_flash(:error, "An error occurred during authentication.")
        |> redirect(to: "/")
    end
  end
end
