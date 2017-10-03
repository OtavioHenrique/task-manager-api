class Api::V2::TaskSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :short_description, :done, :is_late, 
              :deadline, :user_id, :created_at, :updated_at

  def short_description
    object.description[0..40]
  end

  def is_late
    Time.current > object.deadline if object.deadline.present?
  end
  
  belongs_to :user
end
