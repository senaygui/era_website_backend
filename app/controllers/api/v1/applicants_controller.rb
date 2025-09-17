module Api
  module V1
    class ApplicantsController < BaseController
      # POST /api/v1/applicants
      def create
        @applicant = Applicant.new(applicant_params)

        # Handle file attachments if provided
        if params.dig(:applicant, :cv).present?
          @applicant.cv.attach(params[:applicant][:cv])
        end
        if params.dig(:applicant, :cover_letter).present?
          @applicant.cover_letter.attach(params[:applicant][:cover_letter])
        end
        if params.dig(:applicant, :other_documents).present?
          Array(params[:applicant][:other_documents]).each do |file|
            @applicant.other_documents.attach(file)
          end
        end

        if @applicant.save
          render json: { message: 'Application submitted successfully', applicant_id: @applicant.id }, status: :created
        else
          render json: { error: @applicant.errors.full_messages.join(', ') }, status: :unprocessable_entity
        end
      end

      private

      def applicant_params
        params.require(:applicant).permit(
          :first_name,
          :middle_name,
          :last_name,
          :email,
          :phone,
          :address,
          :date_of_birth,
          :gender,
          :education_level,
          :years_of_experience,
          :current_employer,
          :current_position,
          :vacancy_id,
          :status,
          :cover_letter_text,
          :notes,
          skills: [],
          other_documents: []
        )
      end
    end
  end
end
