defmodule CloudDrive.GoogleDrive.File do
  @type t :: %__MODULE__{
            name: String.t,
            mimeType: String.t,
            webViewLink: String.t,
            createdTime: String.t,
            modifiedTime String.t,
            size: non_neg_integer}

  defstruct name: "",
            mimeType: "",
            webViewLink: "",
            createdTime: "",
            modifiedTime "",
            size: 0
end
