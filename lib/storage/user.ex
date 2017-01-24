defmodule Storage.User do
  use Storage.Model

  schema "users" do
    field     :email,           :string
    field     :name,            :string
    field     :password_hash,   :string
    field     :google_account,  :string
    field     :gdrive_synced?,  :boolean
    has_many  :files,           Storage.File

    timestamps(type: :utc_datetime)
  end

  @required [:email]
  @optional [:name, :password_hash, :gdrive_synced?, :google_account]

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> cast_assoc(:files)
    |> validate_required(@required)
  end
end
