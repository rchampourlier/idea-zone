# Puts a session_token token in the session if it's not already
# present.
defmodule IdeaZone.Plugs.SessionToken do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    unless get_session(conn, :session_token) do
      length = 32
      session_token = :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
      put_session(conn, :session_token, session_token)
    end
    conn
  end
end
