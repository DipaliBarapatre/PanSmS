# Developed By Munsoft IT Solutions
# Developers: ABUBAKAR UMAR PANTAMI, MUSA AHMADU, ALIYU NASIR, USMAN IBN MUHAMMAD
# Website: http:///wwww.munsoft.com.ng
# Email: info@munsoft.com.ng
class GroupedExamReport < ActiveRecord::Base
  belongs_to :batch
  belongs_to :student
  belongs_to :subject
end
