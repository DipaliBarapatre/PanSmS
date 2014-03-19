# Developed By Munsoft IT Solutions
# Developers: ABUBAKAR UMAR PANTAMI, MUSA AHMADU, ALIYU NASIR, USMAN IBN MUHAMMAD
# Website: http:///wwww.munsoft.com.ng
# Email: info@munsoft.com.ng

class Event < ActiveRecord::Base
  validates_presence_of :title, :description, :start_date, :end_date

  named_scope :holidays, :conditions => {:is_holiday => true}
  named_scope :exams, :conditions => {:is_exam => true}
  has_many :batch_events, :dependent => :destroy
  has_many :employee_department_events, :dependent => :destroy
  has_many :user_events, :dependent => :destroy
  belongs_to :origin , :polymorphic => true

  def validate
    unless self.start_date.nil? or self.end_date.nil?
      errors.add(:end_time, "#{t('can_not_be_before_the_start_time')}") if self.end_date < self.start_date
    end
  end

  def is_student_event(student)
    flag = false
    base = self.origin
    unless base.blank?
      if base.respond_to?('batch_id')
        if base.batch_id == student.batch_id
          finance = base.fee_table
          if finance.present?
            flag = true if finance.map{|fee|fee.student_id}.include?(student.id)
          end
        end
      end
    end
    user_events = self.user_events
    unless user_events.nil?
      flag = true if user_events.map{|x|x.user_id }.include?(student.user.id)
    end
    return flag
  end

  def is_employee_event(user)
    user_events = self.user_events
    unless user_events.nil?
      return true if user_events.map{|x|x.user_id }.include?(user.id)
    end
    return false
  end

  def is_active_event
    flag = false
    unless self.origin.nil?
      if self.origin.respond_to?('is_deleted')
        unless self.origin.is_deleted
          flag = true
        end
      else
        flag = true
      end 
    else
      flag = true
    end
    return flag
  end

  def dates
    (start_date.to_date..end_date.to_date).to_a
  end

  class << self
    def is_a_holiday?(day)
      return true if Event.holidays.count(:all, :conditions => ["start_date <=? AND end_date >= ?", day, day] ) > 0
      false
    end
  end

  
end
