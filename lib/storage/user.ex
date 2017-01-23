defmodule Storage.User do
  use Storage.Model

  schema "users" do
    field :email,           :string
    field :name,            :string
    field :password_hash,   :string
    field :google_account,  :string

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :name, :password_hash, :google_account])
    |> validate_required([:email])
  end
end
