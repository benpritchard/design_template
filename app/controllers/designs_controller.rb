class DesignsController < ApplicationController
  def index
  end

  def show
    render params[:name]
  end
end
