defmodule Storage.File do
  use Storage.Model

  schema "files" do
    belongs_to  :owner,          Storage.User
    field       :name,           :string
    field       :tags,           {:array, :integer}, default: []
    field       :mime_type,      :string
    field       :size,           :integer
    field       :edit_url,       :string
    field       :download_url,   :string
    field       :google_file?,   :boolean, default: true

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:owner, :name, :tags, :mime_type, :size,
                     :edit_url, :download_url, :google_file?])
    |> validate_required([:owner, :name, :mime_type, :download_url])
  end
end
