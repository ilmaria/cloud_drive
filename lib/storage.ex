defmodule Storage do

  def sync_with_google(user, token) do
    if !user.gdrive_synced? do
      Storage.GoogleDrive.sync(user, token)
      user = Storage.User.changeset(user, gdrive_synced: true)
      Storage.Repo.update(user)
    end
  end

end
