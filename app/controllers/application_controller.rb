class ApplicationController < ActionController::Base

  # 404 page
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end


end
