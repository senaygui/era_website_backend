module Api
  module V1
    class ContactMessagesController < BaseController
      def create
        contact_message = ContactMessage.new(contact_message_params)
        if contact_message.save
          render json: { message: "Thank you. Your message has been received." }, status: :created
        else
          render json: { error: contact_message.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      private

      def contact_message_params
        params.require(:contact_message).permit(:name, :email, :phone, :subject, :department, :message, :consent)
      end
    end
  end
end
