#class ExistingValidator < ActiveModel::EachValidator
#  # You can`t register with restricted login!!!
#  def validate_each(record, attribute, value)
#    record.errors[attribute] << ": Using #{attribute} '#{value}' is forbidden, sorry" unless
#        !User::RESTRICTED_LOGINS.index(value) #.find {|login| value =~ /#{login}/}
#  end
#end

class RootEntry < ActiveRecord::Base

  validates :body, :presence => true, :length => {:minimum => 2, :maximum => 150}

  def type
    self.parent? ? 'parent' : 'response'
  end

  def type_partial
    self.parent? ? 'main/entries/parent' : 'main/entries/response'
  end

  def parent?
    self.parent_id.nil?
  end

  def children
    RootEntry.where(:parent_id => self.id)
  end
end
