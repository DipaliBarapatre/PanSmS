# Developed By Munsoft IT Solutions
# Developers: ABUBAKAR UMAR PANTAMI, MUSA AHMADU, ALIYU NASIR, USMAN IBN MUHAMMAD
# Website: http:///wwww.munsoft.com.ng
# Email: info@munsoft.com.ng

class Subject < ActiveRecord::Base

  belongs_to :batch
  belongs_to :elective_group
  has_many :timetable_entries,:foreign_key=>'subject_id'
  has_many :employees_subjects
  has_many :employees ,:through => :employees_subjects
  has_many :students_subjects
  has_many :students, :through => :students_subjects
  has_many :grouped_exam_reports
  has_and_belongs_to_many_with_deferred_save :fa_groups
  validates_presence_of :name, :max_weekly_classes, :code,:batch_id
  validates_presence_of :credit_hours, :if=>:check_grade_type
  validates_numericality_of :max_weekly_classes
  validates_uniqueness_of :code, :case_sensitive => false, :scope=>[:batch_id,:is_deleted] ,:if=> 'is_deleted == false'
  named_scope :for_batch, lambda { |b| { :conditions => { :batch_id => b.to_i, :is_deleted => false } } }
  named_scope :without_exams, :conditions => { :no_exams => false, :is_deleted => false }

  before_save :fa_group_valid

  def check_grade_type
    batch = self.batch
    batch.gpa_enabled? or batch.cwa_enabled?
  end

  def inactivate
    update_attributes(:is_deleted=>true)
    self.employees_subjects.destroy_all
  end

  def lower_day_grade
    subjects = Subject.find_all_by_elective_group_id(self.elective_group_id) unless self.elective_group_id.nil?
    selected_employee = nil
    subjects.each do |subject|
      employees = subject.employees
      employees.each do |employee|
        if selected_employee.nil?
          selected_employee = employee
        else
          selected_employee = employee if employee.max_hours_per_day.to_i < selected_employee.max_hours_per_day.to_i
        end
      end
    end
    return selected_employee
  end

  def lower_week_grade
    subjects = Subject.find_all_by_elective_group_id(self.elective_group_id) unless self.elective_group_id.nil?
    selected_employee = nil
    subjects.each do |subject|
      employees = subject.employees
      employees.each do |employee|
        if selected_employee.nil?
          selected_employee = employee
        else
          selected_employee = employee if employee.max_hours_per_week.to_i  < selected_employee.max_hours_per_week.to_i
        end
      end
    end
    return selected_employee
  end

  private

  def fa_group_valid
    fa_groups.group_by(&:cce_exam_category_id).values.each do |fg|
      if fg.length > 2
        errors.add(:fa_group, "cannot have more than 2 fa group under a single exam category")
        return false
      end
    end
  end
  
end
