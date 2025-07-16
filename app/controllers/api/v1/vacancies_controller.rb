module Api
  module V1
    class VacanciesController < BaseController
      before_action :set_vacancy, only: [:show]

      # GET /api/v1/vacancies
      def index
        @vacancies = Vacancy.published.active.ordered
        
        # Apply filters if provided
        @vacancies = @vacancies.by_department(params[:department]) if params[:department].present?
        @vacancies = @vacancies.by_location(params[:location]) if params[:location].present?
        @vacancies = @vacancies.by_job_type(params[:job_type]) if params[:job_type].present?
        
        render json: @vacancies.map { |v| vacancy_attributes(v, include_details: true) }
      end

      # GET /api/v1/vacancies/active
      def active
        @vacancies = Vacancy.published.active.ordered
        render json: @vacancies.map { |v| vacancy_attributes(v, include_details: true) }
      end

      # GET /api/v1/vacancies/expired
      def expired
        @vacancies = Vacancy.published.expired.ordered
        render json: @vacancies.map { |v| vacancy_attributes(v, include_details: true) }
      end

      # GET /api/v1/vacancies/:id
      def show
        render json: vacancy_attributes(@vacancy, include_details: true)
      end

      private

      def set_vacancy
        @vacancy = Vacancy.published.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Vacancy not found' }, status: :not_found
      end

      def vacancy_attributes(vacancy, include_details: false)
        {
          id: vacancy.id,
          title: vacancy.title,
          department: vacancy.department,
          location: vacancy.location,
          type: vacancy.job_type,
          deadline: vacancy.deadline,
          posted_date: vacancy.posted_date,
          description: vacancy.description,
          salary: vacancy.salary,
          is_active: vacancy.active?,
          created_at: vacancy.created_at,
          updated_at: vacancy.updated_at
        }.tap do |attrs|
          if include_details
            attrs.merge!(
              requirements: vacancy.requirements || [],
              responsibilities: vacancy.responsibilities || [],
              benefits: vacancy.benefits || []
            )
          end
        end
      end
    end
  end
end
