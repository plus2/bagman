module Bagman
  class Bag
    attr_reader :target_class, :top_level_mixin, :columns

    def initialize(target_class,&blk)
      @target_class = target_class
      @top_level_mixin = Module.new do
        include AngryHash::Extension
      end

      @columns = []

      instance_eval(&blk)
    end

    alias :fields :columns


    def field(name,*args,&blk)
      options = args.extract_options!
      type    = args.shift || :string

      if options[:unbagged]
        # no-op
        # unbagged_field(name, type, options, &blk)
      elsif options[:encrypted]
        crypto_field(name, type, options, &blk)
      else
        bag_field(name, type, options, &blk)
      end
    end

    
    def bag_field(name, type, options, &blk)
      @columns << (column = SimpleColumn.new(name, :bag, type, options))

      target_class.send :define_method, name do
        column.type_cast( self.bag[name] )
      end

      if type == :boolean
        target_class.send :define_method, "#{name}?" do
          column.type_cast( self.bag[name] )
        end
      end

      target_class.send :define_method, "#{name}=" do |value|
        if index_name = column.index_name
          write_attribute(index_name, value)
        end

        self.bag[name] = if s = options[:serialize]
                           s[value]
                         elsif value.is_a? Date
                           value.to_s(:db)
                         else
                           value.to_s
                         end
      end
    end


    def crypto_field(name, type, options, &blk)
      name = name.to_s
      @columns << (column = SimpleColumn.new(name, :crypto, type, options))

      target_class.send :define_method, name do
        column.type_cast( self.crypto_pocket[name] )
      end

      target_class.send :define_method, "#{name}_before_type_cast" do
        self.crypto_pocket[name]
      end

      if options[:shadow]
        target_class.send :define_method, "#{name}_shadow" do
          read_attribute(name)
        end
      end


      target_class.send :define_method, "#{name}=" do |value|
        # we need to flag bag as dirty, or we're never saved.
        self.bag_will_change!

        self.crypto_pocket[name] = final_value = Bagman::Bag.serialise_value(value, options)

        if pepper = options[:shadow]
          shadowed = case pepper
                     when String
                       Gibberish::SHA256( pepper + '--' + final_value )
                     when Symbol
                       send(pepper, final_value)
                     else
                       Gibberish::SHA256( final_value )
                     end

          write_attribute(name, shadowed) 
        end
      end
    end


    def unbagged_field(name, type, options, &blk)
    end



    def self.serialise_value(value, options)
      if s = options[:serialize]
        s[value]
      elsif value.is_a? Date
        value.to_s(:db)
      else
        value.to_s
      end
    end
    

    def collection(name,type,options={},&blk)
      @top_level_mixin.module_eval do
        extend_array name, type
      end

      target_class.send :define_method, name do
        self.bag[name]
      end

      target_class.send :define_method, "#{name}=" do |value|
        if value.is_a? Hash
          value = value.sort_by { |index, _| index.to_i }.map { |_, attributes| attributes }
        end
        self.bag[name] = value
      end
    end


    ## Indices
    def index(*)
    end

    ## Materialise
    def materialise(*)
    end

    ## Validations
    def validates_presence_of(*)
    end

    def validates_storage_type_of(*)
    end

    def validate(*)
    end
  end
end
