class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_locale

  def set_locale
    I18n.locale = :fr
  end

  def default_url_options
    { locale: I18n.locale }
  end
end
