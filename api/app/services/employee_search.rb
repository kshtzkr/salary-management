class EmployeeSearch
  SORTABLE_FIELDS = %w[full_name job_title department country_code annual_salary_cents hired_on created_at].freeze

  def initialize(scope:, params:)
    @scope = scope
    @params = params
  end

  def call
    filtered = by_archived(scope)
    filtered = by_search(filtered)
    filtered = by_country(filtered)
    filtered = by_job_title(filtered)
    filtered = by_department(filtered)
    filtered = by_status(filtered)
    filtered.order("#{sort_field} #{sort_direction}")
  end

  private

  attr_reader :scope, :params

  def by_archived(relation)
    return relation unless truthy?(params[:include_archived])

    relation.unscope(where: :deleted_at)
  end

  def by_search(relation)
    term = params[:query].to_s.strip
    return relation if term.blank?

    relation.where(
      "LOWER(full_name) LIKE :term OR LOWER(work_email) LIKE :term OR LOWER(job_title) LIKE :term OR LOWER(department) LIKE :term",
      term: "%#{term.downcase}%"
    )
  end

  def by_country(relation)
    return relation if params[:country].blank?

    relation.where(country_code: params[:country].to_s.upcase)
  end

  def by_job_title(relation)
    return relation if params[:job_title].blank?

    relation.where(job_title: params[:job_title])
  end

  def by_department(relation)
    return relation if params[:department].blank?

    relation.where(department: params[:department])
  end

  def by_status(relation)
    return relation if params[:employment_status].blank?

    relation.where(employment_status: params[:employment_status])
  end

  def sort_field
    field = params[:sort].presence || "full_name"
    SORTABLE_FIELDS.include?(field) ? field : "full_name"
  end

  def sort_direction
    params[:direction].to_s.downcase == "desc" ? "DESC" : "ASC"
  end

  def truthy?(value)
    ActiveModel::Type::Boolean.new.cast(value)
  end
end
