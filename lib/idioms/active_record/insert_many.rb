module InsertMany
  def insert_many(fixtures)
    connection.insert_many(fixtures, table_name)
  end
end

module InsertManyStatement
  def insert_many(fixtures, table_name=self.table_name)
    return if fixtures.empty?

    columns = schema_cache.columns_hash(table_name)

    sample = fixtures.first
    key_list = sample.map { |name, value| quote_column_name(name) }

    value_lists = fixtures.map do |fixture|
      fixture.map do |name, value|
        quote(value, columns[name])
      end
    end

    execute "INSERT INTO #{quote_table_name(table_name)} (#{key_list.join(', ')}) VALUES #{value_lists.map { |value| "(#{value.join(', ')})" }.join(",")}", "Fixture Insert"
  end
end

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.send :include, InsertManyStatement
ActiveRecord::Base.extend InsertMany
