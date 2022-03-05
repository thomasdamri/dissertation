class ApplicationController < ActionController::Base
  include Pagy::Backend

  # Ensure all pages (unless manually skipped) are authorized via CanCanCan
  # Do not authorize on devise pages, as they deal with logging in
  check_authorization unless: :devise_controller?

  # Redirect to standard 404 page when denied access through CanCanCan
  rescue_from CanCan::AccessDenied do |ex|
    not_found
  end

  # 404 page
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end


end
