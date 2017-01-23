defmodule Auth.GuardianSerializer do
  alias Storage.User
  alias Storage.Repo

  @behaviour Guardian.Serializer

  def for_token(user = %User{}) do
    { :ok, "User:#{user.id}" }
  end
  def for_token(_), do: { :error, "Unknown resource type" }

  def from_token("User:" <> id) do
    { :ok, Repo.get(User, String.to_integer(id)) }
  end
  def from_token(_), do: { :error, "Unknown resource type" }
end
