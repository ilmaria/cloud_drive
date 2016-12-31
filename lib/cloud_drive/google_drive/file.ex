defmodule CloudDrive.GoogleDrive.File do
  @type t :: %__MODULE__{
    name:         String.t,
    mimeType:     String.t,
    webViewLink:  String.t,
    createdTime:  DateTime.t,
    modifiedTime: DateTime.t,
    size:         non_neg_integer | nil,
    parents:      [String.t]
  }

  defstruct [:name, :mimeType, :webViewLink, :parents,
             :createdTime, :modifiedTime, :size]
end

defimpl Poison.Decoder, for: CloudDrive.GoogleDrive.File do
  use Timex

  def decode(value, _options) do
    %{value | modifiedTime: Timex.parse!(value.modifiedTime, "{ISO:Extended:Z}"),
              createdTime: Timex.parse!(value.createdTime, "{ISO:Extended:Z}")}
  end
end
