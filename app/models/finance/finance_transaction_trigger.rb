# Developed By Munsoft IT Solutions
# Developers: ABUBAKAR UMAR PANTAMI, MUSA AHMADU, ALIYU NASIR, USMAN IBN MUHAMMAD
# Website: http:///wwww.munsoft.com.ng
# Email: info@munsoft.com.ng

class FinanceTransactionTrigger < ActiveRecord::Base
  belongs_to :finance_category, :class_name => "FinanceTransactionCategory", :foreign_key => 'finance_category_id'
  validates_presence_of :percentage
  validates_numericality_of :percentage,:less_than => 100,:greater_than => 0
end
