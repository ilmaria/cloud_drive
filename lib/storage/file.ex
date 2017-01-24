defmodule Storage.File do
  use Storage.Model

  schema "files" do
    field       :name,           :string
    belongs_to  :owner,          Storage.User
    has_many    :tags,           Storage.Tag
    field       :mime_type,      :string
    field       :size,           :integer
    field       :edit_url,       :string
    field       :download_url,   :string
    field       :google_file?,   :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @required [:name, :mime_type, :download_url]
  @optional [:size, :edit_url, :google_file?]

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> cast_assoc(:owner, required: true)
    |> cast_assoc(:tags)
    |> validate_required(@required)
  end
end
