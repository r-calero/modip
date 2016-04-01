require 'test_helper'

class NotifierTest < ActionMailer::TestCase
  test "docking_compound" do
    mail = Notifier.docking_compound
    assert_equal "Docking compound", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
