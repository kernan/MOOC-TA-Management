class TaTest < ActiveRecord::Base
  belongs_to :course
  has_many :questions, :dependent => :destroy
  has_many :test_results
  has_many :teaching_assistants, :through => :test_results
  attr_accessible :name, :questions_attributes
  accepts_nested_attributes_for :questions, :reject_if => lambda { |a| a[:content].blank? }, :allow_destroy => true
  validates :name, :presence => true
end
