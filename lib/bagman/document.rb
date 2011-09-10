module Bagman
  module Document

    extend ActiveSupport::Concern


    CryptoPocketKey = '_crypto'


    included do
      before_save :serialize_bag
    end


    def bag
      @bag ||= decode_or_initialize_bag
    end


    def bag=(bag)
      case bag
      when NilClass
        @bag = AngryHash.new
      when String
        @bag = decode_or_initialize_bag(bag)
      else
        @bag = AngryHash[bag]
      end.tap {
        mixin_top_level_mixin
      }
    end


    def decode_or_initialize_bag(bag_string=nil)
      begin
        bag_string ||= read_attribute('bag')
        AngryHash[ ActiveSupport::JSON.decode( bag_string ) ]
      rescue
        initialize_bag(AngryHash.new)
      end.tap {|bag|
        mixin_top_level_mixin(bag)
      }
    end


    def mixin_top_level_mixin(hash=@bag)
      hash.extend self.class.bag.top_level_mixin unless hash.__angry_hash_extension # XXX angry hash should have an API for this
    end


    def initialize_bag(bag)
      bag.tap do |b|
        self.class.bag.columns.select { |c| c.options.has_key?(:default) }.each do |column|
          b[column.name] = column.options[:default]
        end
      end 
    end


    def serialize_bag
      if @bag
        encrypt_crypto_pocket
        write_attribute(:bag, ActiveSupport::JSON.encode(@bag))
        @bag = nil
      end
    end



    ###################
    #  crypto pocket  #
    ###################

    def crypto_pocket
      @crypto_pocket ||= decrypt_crypto_pocket
    end


    def crypto_pocket=(bag)
      @crypto_pocket = AngryHash[bag] if bag
    end


    def decrypt_crypto_pocket
      if crypto_pocket = bag[CryptoPocketKey]
        ActiveSupport::JSON.decode( encryptor.dec(crypto_pocket) )
      else
        {}
      end
    rescue
      {}
    end


    def encrypt_crypto_pocket
      if @crypto_pocket.is_a?(Hash)
        bag[CryptoPocketKey] = encryptor.enc(@crypto_pocket.to_json)
      end
    end


    def encryptor
      @encryptor ||= begin
                       cfg = Davidson.app_config
                       password = cfg.crypto.password || cfg.missing!('crypto.password')
                       Gibberish::AES.new(password)
                     end
    end
      


    # Fills a bag with data from a source document, setting only those values present in the target document
    def fill_bag_from(source)
      self.class.bag.columns.each do |column|
        column_name = column.name
        if source.respond_to?(column_name) && self.send(column_name).blank?
          self.send("#{column_name}=", source.send(column_name)) 
        end
      end
    end


    def reload(*args)
      @bag = nil
      super
    end


    def as_json(opts={})
      bag.dup.tap {|b|
        b.id = id
      }
    end


    module ClassMethods

      def bag(&blk)
        if block_given?
          @bagman_has_no_bag = false
          @bag = Bag.new(self, &blk)
        else
          unless @bag
            @bag = __super_bag
            @bagman_has_no_bag = ! @bag
          end

          raise "no bag defined" if @bagman_has_no_bag

          @bag
        end
      end


      def __super_bag
        superclass.bag if superclass.respond_to?(:bag)
      end


      def bag_field(name)
        class_eval <<-EOMETHOD
          def #{name}=(value)
            bag["#{name}"] = value
          end

          def #{name}
            bag["#{name}"]
          end
        EOMETHOD
      end
    end
  end

end

