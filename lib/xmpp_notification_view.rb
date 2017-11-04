class XmppNotificationView < ActionView::Base
  include Redmine::I18n
  include Rails.application.routes.url_helpers

  attr_reader :user

  def initialize(context, user)
    @user = user
    super(ActionController::Base.view_paths)
  end

  def redmine_url
    "#{Setting[:protocol]}://#{Setting[:host_name]}"
  end

  def render(*)
    I18n.with_locale(locale) do
      eliminate_multiple_blank_lines(super)
    end
  end

  def eliminate_multiple_blank_lines(text)
    text.gsub(/^$\n+/, "\n").strip
  end

  def locale
    user.language.presence || I18n.default_locale
  end

  def default_url_options
    options = {protocol: Setting.protocol}
    if Setting.host_name.to_s =~ /\A(https?\:\/\/)?(.+?)(\:(\d+))?(\/.+)?\z/i
      host, port, prefix = $2, $4, $5
      options.merge!(host: host, port: port, script_name: prefix)
    else
      options[:host] = Setting.host_name
    end
    options
  end

  def url_for(options)
    options.merge!(only_path: false)
    super
  end
end
