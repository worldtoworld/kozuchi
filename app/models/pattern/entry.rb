# -*- encoding : utf-8 -*-
class Pattern::Entry < ActiveRecord::Base
  self.table_name = 'entry_patterns'

  belongs_to :account,
             :class_name => 'Account::Base',
             :foreign_key => 'account_id'

  include ::Entry
  attr_accessible :account_id, :amount, :line_number, :summary, :reversed_amount

  def assignable_attributes
    HashWithIndifferentAccess.new(attributes).slice(:id, :account_id, :amount, :line_number, :summary, :reversed_amount)
  end

end
