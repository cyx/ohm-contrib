require "cutest"
require "ohm"

prepare do
  Ohm.flush
end

def assert_nothing_raised(*exceptions)
  begin
    yield
  rescue *exceptions
    flunk(caller[1])
  end
end
