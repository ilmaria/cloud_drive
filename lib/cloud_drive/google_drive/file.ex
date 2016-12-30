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
