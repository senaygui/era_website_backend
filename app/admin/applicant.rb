ActiveAdmin.register Applicant do
  permit_params :first_name, :middle_name, :last_name, :email, :phone, :address,
                :date_of_birth, :gender, :education_level, :years_of_experience,
                :current_employer, :current_position, :vacancy_id, :status,
                :cover_letter_text, :notes, skills: [], cv: [], cover_letter: [], other_documents: []

  menu parent: "Vacancies", priority: 2, label: "Applicants"
  scope :all, default: true
  scope :applied, -> { where(status: "applied") }
  scope :under_review, -> { where(status: "under_review") }
  scope :shortlisted, -> { where(status: "shortlisted") }
  scope :interview_scheduled, -> { where(status: "interview_scheduled") }
  scope :hired, -> { where(status: "hired") }
  scope :rejected, -> { where(status: "rejected") }
  scope :recent

  index do
    selectable_column
    column(:full_name) { |a| content_tag(:span, truncate(a.full_name.to_s, length: 60), title: a.full_name.to_s) }
    column(:email)     { |a| content_tag(:span, truncate(a.email.to_s, length: 40), title: a.email.to_s) }
    column(:phone)     { |a| content_tag(:span, truncate(a.phone.to_s, length: 24), title: a.phone.to_s) }
    column :vacancy do |applicant|
      title = applicant.vacancy&.title.to_s
      link_to truncate(title, length: 60), admin_vacancy_path(applicant.vacancy), title: title
    end
    column :status do |applicant|
      status_tag applicant.status, class: status_class(applicant.status)
    end
    column :created_at
    actions
  end

  filter :first_name
  filter :last_name
  filter :email
  filter :phone
  filter :status, as: :select, collection: proc { Applicant.statuses.keys.map { |s| [ s.humanize, s ] } }
  filter :vacancy
  filter :education_level
  filter :years_of_experience
  filter :created_at

  form do |f|
    f.inputs "Personal Information" do
      f.input :first_name
      f.input :middle_name
      f.input :last_name
      f.input :email
      f.input :phone
      f.input :address
      f.input :date_of_birth, as: :date_picker
      f.input :gender, as: :select, collection: Applicant.genders.keys.map { |g| [ g.humanize, g ] }
    end

    f.inputs "Professional Information" do
      f.input :education_level, as: :select, collection: [
        "High School",
        "Associate Degree",
        "Bachelor's Degree",
        "Master's Degree",
        "PhD",
        "Professional Certification",
        "Other"
      ]
      f.input :years_of_experience
      f.input :current_employer
      f.input :current_position
      f.input :skills, as: :text, input_html: {
        value: f.object.skills&.join("\n"),
        rows: 5
      }, hint: "Enter one skill per line"
    end

    f.inputs "Application Details" do
      f.input :vacancy_id, as: :select, collection: Vacancy.all.map { |v| [ v.title, v.id ] }
      f.input :status, as: :select, collection: Applicant.statuses.keys.map { |s| [ s.humanize, s ] }
      f.input :cover_letter_text, input_html: { rows: 5 }
      f.input :notes, input_html: { rows: 5 }
    end

    f.inputs "Documents" do
      f.input :cv, as: :file, hint: f.object.cv.attached? ? "Current file: #{f.object.cv_filename}" : "No file attached"
      f.input :cover_letter, as: :file, hint: f.object.cover_letter.attached? ? "Current file: #{f.object.cover_letter_filename}" : "No file attached"
      f.input :other_documents, as: :file, input_html: { multiple: true }, hint: "You can select multiple files"
    end

    f.actions
  end

  show do
    columns do
      column span: 2 do
        panel "Personal Information" do
          attributes_table_for applicant do
            row :full_name
            row :email
            row :phone
            row :address
            row :date_of_birth
            row :age
            row :gender
          end
        end

        panel "Professional Information" do
          attributes_table_for applicant do
            row :education_level
            row :years_of_experience
            row :current_employer
            row :current_position
          end

          panel "Skills" do
            if applicant.skills.any?
              ul do
                applicant.skills.each do |skill|
                  li skill
                end
              end
            else
              para "No skills listed."
            end
          end
        end
      end

      column do
        panel "Application Details" do
          attributes_table_for applicant do
            row :vacancy do |a|
              link_to a.vacancy.title, admin_vacancy_path(a.vacancy)
            end
            row :status do |a|
              status_tag a.status, class: status_class(a.status)
            end
            row :created_at
            row :updated_at
          end
        end

        panel "Cover Letter" do
          if applicant.cover_letter_text.present?
            div do
              simple_format applicant.cover_letter_text
            end
          else
            para "No cover letter text provided."
          end
        end

        panel "Admin Notes" do
          if applicant.notes.present?
            div do
              simple_format applicant.notes
            end
          else
            para "No notes added."
          end
        end

        panel "Documents" do
          attributes_table_for applicant do
            row :cv do |a|
              if a.cv.attached?
                div do
                  link_to a.cv_filename, rails_blob_path(a.cv, disposition: "attachment")
                end
              else
                span "No CV attached"
              end
            end
            row :cover_letter do |a|
              if a.cover_letter.attached?
                div do
                  link_to a.cover_letter_filename, rails_blob_path(a.cover_letter, disposition: "attachment")
                end
              else
                span "No cover letter attached"
              end
            end
            row :other_documents do |a|
              if a.other_documents.attached?
                ul do
                  a.other_documents.each do |doc|
                    li link_to doc.filename.to_s, rails_blob_path(doc, disposition: "attachment")
                  end
                end
              else
                span "No other documents attached"
              end
            end
          end
        end
      end
    end
  end

  controller do
    before_action :process_arrays, only: [ :create, :update ]
  end

  # Helper method for status colors
  member_action :update_status, method: :post do
    resource.update(status: params[:status])
    redirect_to resource_path, notice: "Status updated to #{params[:status]}"
  end

  action_item :change_status, only: :show do
    dropdown_menu "Change Status" do
      Applicant.statuses.keys.each do |status|
        next if resource.status == status
        # Correct path helper for member_action :update_status
        item status.humanize,
             update_status_admin_applicant_path(id: resource.id, status: status),
             method: :post,
             data: { turbo: false }
      end
    end
  end

  # Helper method for status colors
  sidebar "Quick Actions", only: :show do
    ul do
      li link_to "View Vacancy", admin_vacancy_path(resource.vacancy)
      li link_to "Download CV", rails_blob_path(resource.cv, disposition: "attachment") if resource.cv.attached?
      li link_to "Download Cover Letter", rails_blob_path(resource.cover_letter, disposition: "attachment") if resource.cover_letter.attached?
    end
  end

  # Helper method for status colors
  collection_action :export_csv, method: :get do
    # Implementation for CSV export
    send_data Applicant.to_csv, filename: "applicants-#{Date.today}.csv"
  end

  action_item :export_csv, only: :index do
    link_to "Export as CSV", export_csv_admin_applicants_path
  end

  # Helper method for status colors in the admin interface
  sidebar "Status Legend", only: :index do
    ul do
      li span("Applied", class: "status_tag blue")
      li span("Under Review", class: "status_tag orange")
      li span("Shortlisted", class: "status_tag purple")
      li span("Interview Scheduled", class: "status_tag yellow")
      li span("Hired", class: "status_tag green")
      li span("Rejected", class: "status_tag red")
    end
  end

  # Helper method for status colors
  before_action only: :index do
    @page_title = "Applicants"
  end

  # Helper method for status colors
  before_action only: :show do
    @page_title = "Applicant: #{resource.full_name}"
  end

  # Helper method for status colors
  controller do
    def process_arrays
      if params[:applicant][:skills].is_a?(String)
        params[:applicant][:skills] = params[:applicant][:skills].split("\n").map(&:strip).reject(&:blank?)
      end
    end

    def status_class(status)
      case status
      when "applied" then "blue"
      when "under_review" then "orange"
      when "shortlisted" then "purple"
      when "interview_scheduled" then "yellow"
      when "hired" then "green"
      when "rejected" then "red"
      else "default"
      end
    end
    helper_method :status_class
  end
end
