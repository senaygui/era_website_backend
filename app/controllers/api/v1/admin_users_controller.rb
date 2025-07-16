module Api
  module V1
    class AdminUsersController < BaseController
      def index
        @admin_users = AdminUser.all
        render json: @admin_users
      end

      def show
        @admin_user = AdminUser.find(params[:id])
        render json: @admin_user
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Admin user not found" }, status: :not_found
      end
    end
  end
end
