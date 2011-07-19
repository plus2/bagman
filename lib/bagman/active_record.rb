module Bagman
  module ConnectionAdapters
    module TableDefinition
      def bag_for(klass_symbol)
        klass = klass_symbol.to_s.classify.constantize
        raise "#{klass} doesn't have a bag" unless klass.respond_to?(:bag)
        Bagman::TableBuilder.build_table(self, klass.bag)
      end
    end
  end

  module TableBuilder
    def self.build_table(table, bag)
      table.text :bag

      # build indexed columns
      bag.columns.each do |column|
        table.send(column.type, column.index_name) if column.index?
      end
    end

    # add indexes for indexed columns
    def self.add_indexes(table, table_name, bag)
      bag.columns.each do |column|
        table.add_index(table_name, column.index_name) if column.index?
      end
    end
  end
end


module ActiveRecord
  module ConnectionAdapters
    module SchemaStatements 
      def bag_for_table(table)
        klass = table.to_s.classify.constantize
        raise "#{klass} doesn't have a bag" unless klass.respond_to?(:bag)
        klass.bag
      end

      def add_bag_indexes_for(table_name)
        Bagman::TableBuilder.add_indexes(self, table_name, bag_for_table(table_name.singularize.to_sym))
      end
    end
  end
end

ActiveRecord::ConnectionAdapters::TableDefinition.send(:include, Bagman::ConnectionAdapters::TableDefinition)
