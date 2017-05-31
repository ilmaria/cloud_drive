defmodule CloudDrive.Storage do
    alias CloudDrive.Storage

    @type storage_item :: Storage.User | Storage.File | Storage.Tag
    @type storage_table :: :users | :files | :tags
    @type match_pattern :: atom() | tuple()

    @spec get(storage_table, String.t) :: {:ok, storage_item} | :no_item_found
    def get(table, id) do
        case :ets.lookup(table, id) do
            [item] -> elem(item, 1)
            [] -> :no_item_found
        end
    end

    @spec insert(storage_table, storage_item, keyword()) :: true
    def insert(table, item, opts \\ []) do
        id = opts |> Keyword.get(:id) || item.id
        :ets.insert(table, {id, item})
    end

    @spec delete(storage_table, storage_item) :: true
    def delete(table, id) do
        :ets.delete(table, id)
    end

    @spec match(storage_table, match_pattern) :: [storage_item]
    def match(table, match_pattern) do
        :ets.match_object(table, match_pattern)
    end

    @spec all(storage_table) :: [storage_item]
    def all(table) do
        :ets.match_object(table, {:'_'})
    end

    @spec select(storage_table, any()) :: [storage_item]
    def select(table, func) do
        match_spec = :ets.fun2ms(func)
        :ets.select(table, match_spec)
    end
end
