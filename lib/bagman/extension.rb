require 'angry_hash/extension'

module Bagman
  module Extension
    include AngryHash::Extension

    def self.included(base)
      base.extend AngryHash::Extension::ClassMethods
      base.extend ClassMethods
    end

    module ClassMethods
      def field(name,*args,&blk)
        options = args.extract_options!
        type    = args.shift || :string

        column = SimpleColumn.new(name, :extended, type)

        define_method name do
          column.type_cast( self[name] )
          # TODO typecasting, racial profiling
        end

        define_method "#{name}=" do |value|
          self[name] = value.to_s
        end
      end
    end

  end
end
