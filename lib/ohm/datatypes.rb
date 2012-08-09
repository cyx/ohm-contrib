require "bigdecimal"
require "date"
require "json"
require "time"
require "set"

module Ohm
  module DataTypes
    module Type
      Integer   = lambda { |x| x.to_i }
      Decimal   = lambda { |x| BigDecimal(x.to_s) }
      Float     = lambda { |x| x.to_f }
      Symbol    = lambda { |x| x.to_sym }
      Boolean   = lambda { |x| Ohm::DataTypes.bool(x) }
      Time      = lambda { |t| t && (t.kind_of?(::Time) ? t : ::Time.parse(t)) }
      Date      = lambda { |d| d && (d.kind_of?(::Date) ? d : ::Date.parse(d)) }
      Timestamp = lambda { |t| t && UnixTime.at(t.to_i) }
      Hash      = lambda { |h| h && SerializedHash[h.kind_of?(::Hash) ? h : JSON(h)] }
      Array     = lambda { |a| a && SerializedArray.new(a.kind_of?(::Array) ? a : JSON(a)) }
      Set       = lambda { |s| s && SerializedSet.new(s.kind_of?(::Set) ? s : JSON(s)) }
    end

    def self.bool(val)
      case val
      when "false", "0" then false
      when "true", "1"  then true
      else
        !! val
      end
    end

    class UnixTime < Time
      def to_s
        to_i.to_s
      end
    end

    class SerializedHash < Hash
      def to_s
        JSON.dump(self)
      end
    end

    class SerializedArray < Array
      def to_s
        JSON.dump(self)
      end
    end

    class SerializedSet < ::Set
      def to_s
        JSON.dump(to_a.sort)
      end
    end
  end
end
