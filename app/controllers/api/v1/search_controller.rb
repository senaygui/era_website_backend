module Api
  module V1
    class SearchController < BaseController
      def index
        render json: SiteSearch.new(params[:q], page: params[:page] || 1).call
      end
    end
  end
end
