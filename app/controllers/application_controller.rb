class ApplicationController < ActionController::Base
  protect_from_forgery

  after_filter :set_cache_headers

  protected

  def set_cache_headers
    response.headers['Cache-Control'] = 'public, max-age=300'
  end
end
