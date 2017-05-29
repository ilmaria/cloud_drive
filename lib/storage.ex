defmodule CloudDrive.Storage do
    alias CloudDrive.Storage

    @type storage_item :: Storage.User | Storage.File | Storage.Tag
    @type storage_table :: :users | :files | :tags

    @spec get(storage_table, String.t) :: {:ok, storage_item} | :no_item_found
    def get(table, id) do
        case :ets.lookup(table, id) do
            [item] -> elem(item, 1)
            [] -> :no_item_found
        end
    end

    @spec insert(storage_table, storage_item)
    def insert(table, item) do
        :ets.insert(table, {item.id, item})
    end

    @spec delete(storage_table, storage_item)
    def delete(table, id) do
        :ets.delete(table, id)
    end
end
