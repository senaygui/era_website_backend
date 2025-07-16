module Api
  module V1
    class BidsController < BaseController
      def index
        Rails.logger.info "Processing bids index request"
        begin
          @bids = Bid.published.order(publish_date: :desc)
          
          # Filter by status if provided
          if params[:status].present?
            @bids = @bids.where(status: params[:status])
          end
          
          # Filter by category if provided
          if params[:category].present?
            @bids = @bids.by_category(params[:category])
          end
          
          # Filter by type if provided
          if params[:type].present?
            @bids = @bids.by_type(params[:type])
          end
          
          Rails.logger.info "Found #{@bids.count} bids"
          render json: @bids.with_attached_documents.map { |bid| bid_attributes(bid) }
        rescue => e
          Rails.logger.error "Error in bids index: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render json: { error: "Internal server error" }, status: :internal_server_error
        end
      end

      def active
        Rails.logger.info "Processing active bids request"
        begin
          @bids = Bid.active.order(deadline_date: :asc)
          Rails.logger.info "Found #{@bids.count} active bids"
          render json: @bids.with_attached_documents.map { |bid| bid_attributes(bid) }
        rescue => e
          Rails.logger.error "Error in active bids: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render json: { error: "Internal server error" }, status: :internal_server_error
        end
      end

      def closed
        Rails.logger.info "Processing closed bids request"
        begin
          @bids = Bid.closed.order(deadline_date: :desc)
          Rails.logger.info "Found #{@bids.count} closed bids"
          render json: @bids.with_attached_documents.map { |bid| bid_attributes(bid) }
        rescue => e
          Rails.logger.error "Error in closed bids: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render json: { error: "Internal server error" }, status: :internal_server_error
        end
      end

      def show
        Rails.logger.info "Processing bid show request for ID: #{params[:id]}"
        begin
          @bid = Bid.published.find(params[:id])
          render json: bid_attributes(@bid)
        rescue ActiveRecord::RecordNotFound
          Rails.logger.error "Bid not found with ID: #{params[:id]}"
          render json: { error: "Bid not found" }, status: :not_found
        rescue => e
          Rails.logger.error "Error in bid show: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          render json: { error: "Internal server error" }, status: :internal_server_error
        end
      end

      private

      def bid_attributes(bid)
        {
          id: bid.id,
          bid_number: bid.bid_number,
          title: bid.title,
          category: bid.category,
          type: bid.type_of_bid,
          status: bid.status,
          publishDate: bid.publish_date,
          deadlineDate: bid.deadline_date,
          budget: bid.budget,
          fundingSource: bid.funding_source,
          description: bid.description,
          eligibility: parse_json_field(bid.eligibility),
          contactPerson: bid.contact_person,
          contactEmail: bid.contact_email,
          contactPhone: bid.contact_phone,
          awardStatus: bid.award_status,
          awardedTo: bid.awarded_to,
          awardDate: bid.award_date,
          contractValue: bid.contract_value,
          documents: bid.documents.attached? ? bid.documents.map { |document| 
            {
              id: document.id,
              name: document.filename.to_s,
              size: ActiveStorage::Analyzer::SizeAnalyzer.new(document.blob).metadata[:size].to_s + " bytes",
              type: document.content_type.split('/').last,
              url: url_for(document)
            }
          } : [],
          created_at: bid.created_at,
          updated_at: bid.updated_at
        }
      end

      def parse_json_field(field)
        return [] if field.nil?
        
        if field.is_a?(String)
          begin
            JSON.parse(field)
          rescue JSON::ParserError
            []
          end
        else
          field
        end
      end
    end
  end
end
