ActiveAdmin.register Vacancy do
  permit_params :title, :department, :location, :job_type, :deadline, :posted_date,
                :description, :salary, :is_published, :position,
                requirements: [], responsibilities: [], benefits: []

  menu parent: "Vacancies", priority: 1, label: "Vacancies"
  index do
    selectable_column
    column(:title)       { |v| truncate(v.title, length: 60) }
    column(:department)  { |v| truncate(v.department, length: 40) }
    column(:location)    { |v| truncate(v.location, length: 40) }
    column :job_type
    column :deadline
    column :posted_date
    column :is_published
    column :position
    actions
  end

  filter :title
  filter :department
  filter :location
  filter :job_type
  filter :deadline
  filter :posted_date
  filter :is_published
  filter :created_at

  form do |f|
    f.inputs "Vacancy Details" do
      f.input :title
      f.input :department
      f.input :location
      f.input :job_type, as: :select, collection: [
        "Full-Time",
        "Part-Time",
        "Contract",
        "Temporary",
        "Internship",
        "Freelance"
      ]
      f.input :deadline, as: :date_picker
      f.input :posted_date, as: :date_picker
      f.input :description, as: :text, input_html: { rows: 5 }
      f.input :salary
      f.input :position
      f.input :is_published
    end

    f.inputs "Requirements (one per line)" do
      f.input :requirements, as: :text,
        input_html: {
          value: f.object.requirements.join("\n"),
          rows: 5
        },
        hint: "Enter one requirement per line"
    end

    f.inputs "Responsibilities (one per line)" do
      f.input :responsibilities, as: :text,
        input_html: {
          value: f.object.responsibilities.join("\n"),
          rows: 5
        },
        hint: "Enter one responsibility per line"
    end

    f.inputs "Benefits (one per line)" do
      f.input :benefits, as: :text,
        input_html: {
          value: f.object.benefits.join("\n"),
          rows: 5
        },
        hint: "Enter one benefit per line"
    end

    f.actions
  end

  controller do
    before_action :process_arrays, only: [ :create, :update ]

    private

    def process_arrays
      v = params[:vacancy]
      return unless v.is_a?(ActionController::Parameters) || v.is_a?(Hash)
      %i[requirements responsibilities benefits].each do |field|
        next unless v[field].is_a?(String)
        v[field] = v[field].split("\n").map(&:strip).reject(&:blank?)
      end
    end
  end

  show do
    attributes_table do
      row :title
      row :department
      row :location
      row :job_type
      row :deadline
      row :posted_date
      row :description do |v|
        simple_format(v.description)
      end
      row :salary
      row :position
      row :is_published
      row :created_at
      row :updated_at
    end

    panel "Requirements" do
      if vacancy.requirements.any?
        ul do
          vacancy.requirements.each do |req|
            li req
          end
        end
      else
        para "No requirements specified."
      end
    end

    panel "Responsibilities" do
      if vacancy.responsibilities.any?
        ul do
          vacancy.responsibilities.each do |resp|
            li resp
          end
        end
      else
        para "No responsibilities specified."
      end
    end

    panel "Benefits" do
      if vacancy.benefits.any?
        ul do
          vacancy.benefits.each do |benefit|
            li benefit
          end
        end
      else
        para "No benefits specified."
      end
    end
  end
end
