defmodule Storage.Tag do
  use Storage.Model

  schema "tags" do
    field :name,    :string
    field :color,   :string

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :color])
    |> validate_required([:name])
  end
end
