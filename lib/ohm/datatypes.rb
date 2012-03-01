require "bigdecimal"
require "date"
require "json"
require "time"

module Ohm
  module DataTypes
    module Type
      Integer   = lambda { |x| x.to_i }
      Decimal   = lambda { |x| BigDecimal(x.to_s) }
      Float     = lambda { |x| x.to_f }
      Boolean   = lambda { |x| !x || x == 'false' ? false : true }
      Time      = lambda { |t| t && (t.kind_of?(::Time) ? t : ::Time.parse(t)) }
      Date      = lambda { |d| d && (d.kind_of?(::Date) ? d : ::Date.parse(d)) }
      Timestamp = lambda { |t| t && UnixTime.at(t.to_i) }
      Hash      = lambda { |h| h && (h.kind_of?(::Hash) ? SerializedHash[h] : JSON(h)) }
      Array     = lambda { |a| a && (a.kind_of?(::Array) ? SerializedArray.new(a) : JSON(a)) }
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
  end
end