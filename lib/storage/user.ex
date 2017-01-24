defmodule Storage.User do
  use Storage.Model

  schema "users" do
    field     :email,           :string
    field     :name,            :string
    field     :password_hash,   :string
    field     :google_account,  :string
    has_many: :files,           Storage.File

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :name, :password_hash, :google_account])
    |> cast_assoc(:files)
    |> validate_required([:email])
  end
end
