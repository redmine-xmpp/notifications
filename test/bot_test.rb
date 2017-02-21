require File.expand_path('../test_helper', __FILE__)

class BotTest <  ActiveSupport::TestCase
  test 'regular expression for mentions accepts project names' do
    assert_not Bot.mentions_regexp.match('project+myproject').nil?
    assert_not Bot.mentions_regexp.match('project+my_project').nil?
    assert_not Bot.mentions_regexp.match('project+my-project').nil?
    assert_not Bot.mentions_regexp.match('project+"myproject"').nil?
    assert_not Bot.mentions_regexp.match('project+"my_project"').nil?
    assert_not Bot.mentions_regexp.match('project+"my-project"').nil?
  end
end