require 'active_record/connection_adapters/abstract/schema_definitions'

module Bagman
  class SimpleColumn < ActiveRecord::ConnectionAdapters::Column

    attr_reader :name, :options, :type

    def initialize(name, role, type, options={})
      @name, @role, @type, @options = name, role, type, options
    end

    def type_cast(value)
      case type
      when Class
        type.new(value)
      else
        super
      end
    end

    def index_name
      case options[:index]
      when TrueClass
        "index_#{name}"
      when String,Symbol
        options[:index]
      end
    end

    def index?
      !! index_name
    end

    def self.string_to_date(string)
      dd_mm_yyyy_to_date(string) || super
    end

    def self.dd_mm_yyyy_to_date(string)
      Date.strptime(string, "%d/%m/%Y") rescue nil
    end

    def self.string_to_time(string)
      dd_mm_yyyy_to_time(string) || super
    end

    def self.dd_mm_yyyy_to_time(string)
      DateTime.strptime(string, "%d/%m/%Y") rescue nil
    end

  end
end
