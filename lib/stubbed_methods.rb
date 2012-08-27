# KEEP OUT
# These are stubbed methods to accomodate testing.
# They are out of bounds.  No touch for kata-fu.
# Assume they represent a stable API you don't get
# to change.

module StubbyPerms
  def initialize(perms)
    @perms = perms
  end
  
  def has?(perm)
    @perms.include? perm
  end
end

class User
  include StubbyPerms
end

class CMInvoice
  include StubbyPerms
  attr_accessor :approval_status, :in_transition
  
  def in_transition?
    @in_transition
  end
end

class UserPermissions
  def has_cm_team_role user
    user.has? :CM_TEAM_ROLE
  end
  
  def has_cm_invoice_view_role user
    user.has? :CM_INVOICE_VIEW_ROLE
  end
  
  def has_invoice_finance_role user
    user.has? :INVOICE_FINANCE_ROLE 
  end
  
  def has_application_access(user, specification = nil)
    return user.has?(specification) if specification
    user.has?(:CM_INVOICE_ROLE) || user.has?(:PA_INVOICE_ROLE) ||
    user.has?(:SDT_INVOICE_ROLE)
  end
  
  def has_read_access user, cm_invoice
    cm_invoice.has? :READ_ACCESS
  end
  
  def has_edit_access user, cm_invoice
    cm_invoice.has? :EDIT_ACCESS
  end
  
  def has_cm_invoice_close_right user, cm_invoice
    cm_invoice.has? :CM_INVOICE_CLOSE_RIGHT
  end
  
  def has_approve_access user, cm_invoice
    cm_invoice.has? :APPROVE_ACCESS
  end
  
  def has_reject_access user, cm_invoice
    cm_invoice.has? :REJECT_ACCESS
  end
  
  def has_configure_rules_access user, cm_invoice
    cm_invoice.has? :CONFIGURE_RULES_ACCESS
  end
  
  def has_view_rules_access user, cm_invoice
    cm_invoice.has? :VIEW_RULES_ACCESS
  end
  
  def has_cm_edit_access user, cm_invoice
    cm_invoice.has? :CM_EDIT_ACCESS
  end
  
  def has_invoice_log_access user, cm_invoice
    cm_invoice.has? :INVOICE_LOG_ACCESS
  end
end
