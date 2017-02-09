class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
        if Rails.env.production? 
          force_ssl
        end
  include SessionsHelper
  before_action :set_locale

  def set_locale
  if cookies[:site_locale] && I18n.available_locales.include?(cookies[:site_locale].to_sym)
    l = cookies[:site_locale].to_sym
  else
    l = I18n.default_locale
    cookies.permanent[:site_locale] = l
  end
  I18n.locale = l
    logger.debug "* Locale set to '#{I18n.locale}'"
  end
  
  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end
end
