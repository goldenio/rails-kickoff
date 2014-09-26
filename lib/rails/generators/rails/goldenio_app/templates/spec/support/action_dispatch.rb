# http://stackoverflow.com/questions/1671221/rails-assert-selects-annoying-warnings
# http://stackoverflow.com/questions/5591509/suppress-ruby-warnings-when-running-specs
ActionDispatch::Assertions::SelectorAssertions.class_eval do
  alias_method :assert_select_original, :assert_select
  def assert_select *args, &block
    _VERBOSE = $VERBOSE
    $VERBOSE = nil
    assert_select_original *args, &block
    $VERBOSE = _VERBOSE
  end
end
