defmodule CloudDrive.Hashids do
  @secret Application.get_env(:cloud_drive, :secret)
  @options Hashids.new(salt: @secret[:hashid_salt], min_len: 5)
  
  def encode(number) do
    Hashids.encode(@options, number)
  end
  
  def decode(number) do
    Hashids.decode(@options, number)
  end
end
