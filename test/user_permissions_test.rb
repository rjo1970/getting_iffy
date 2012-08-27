require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'set'

require_relative '../user_permissions'
require_relative '../lib/stubbed_methods'

class TestUserPermissions < MiniTest::Unit::TestCase
  
  FULL_CM = User.new([:CM_TEAM_ROLE, :CM_INVOICE_ROLE])
  FULL_PA = User.new([:PA_INVOICE_ROLE])
  FINANCE = User.new([:INVOICE_FINANCE_ROLE])
  
  def test_nil_user
    up = UserPermissions.new(nil, nil)
    perms = up.get_permissions
    assert_equal(Set.new, perms)
  end
  
  def test_default_permission
    up = UserPermissions.new(User.new([]), nil)
    perms = up.get_permissions
    assert_equal((Set.new [:DEFAULT_PERMISSION]), perms)
  end

  def test_view_role
    up = UserPermissions.new(User.new([:CM_INVOICE_VIEW_ROLE]), nil)
    perms = up.get_permissions
    assert_equal((
      Set.new [:DEFAULT_PERMISSION, :CM_INVOICE_USER_PERMISSION,
        :INVOICE_VIEW_PERMISSION, :ACCESS_ALL_INVOICE_PERMISSION]), perms)
  end
  
  def test_cm_team_role
    up = UserPermissions.new(FULL_CM, nil)
    perms = up.get_permissions
    assert_equal((Set.new [:DEFAULT_PERMISSION, :CM_TEAM_ROLE_PERMISSION,
       :CM_INVOICE_USER_PERMISSION, :CM_ANY_INVOICE_PERMISSION]), perms)
  end
  
  def test_cm_non_cm_role
    up = UserPermissions.new(User.new([:NON_CM_ROLE]), nil)
    perms = up.get_permissions
    assert_equal((Set.new [:DEFAULT_PERMISSION]), perms)
  end
  
  def test_delegated_user_with_read_rights
    user = User.new([:CM_INVOICE_ROLE, :READ_ACCESS_RIGHT])
    invoice = CMInvoice.new([:READ_ACCESS, :VIEW_RULES_ACCESS])
    up = UserPermissions.new(user, invoice)
    perms = up.get_permissions
    assert_equal((Set.new [:DEFAULT_PERMISSION, :CM_INVOICE_USER_PERMISSION,
       :INVOICE_VIEW_PERMISSION, :VIEW_RULES_PERMISSION,
       :CM_ANY_INVOICE_PERMISSION]), perms)
  end
  
  def test_cm_all_rights_new_invoice
    invoice = CMInvoice.new([:READ_ACCESS, :CM_EDIT_ACCESS, :VIEW_RULES_ACCESS])
    invoice.approval_status = :NEW_STATUS
    up = UserPermissions.new(FULL_CM, invoice)
    perms = up.get_permissions
    assert_equal((Set.new [:DEFAULT_PERMISSION, :CM_INVOICE_USER_PERMISSION,
      :INVOICE_VIEW_PERMISSION, :CM_EDIT_SETUP_PERMISSION,
      :CM_BILLING_PERIOD_ADD_PERMISSION, :VIEW_RULES_PERMISSION,
      :CM_ANY_INVOICE_PERMISSION, :CM_TEAM_ROLE_PERMISSION]), perms)
  end

  def test_cm_all_rights_cm_state
    invoice = CMInvoice.new([:READ_ACCESS, :EDIT_ACCESS, :CM_EDIT_ACCESS,
      :VIEW_RULES_ACCESS, :APPROVE_ACCESS])
    invoice.approval_status = :CM_STATUS
    up = UserPermissions.new(FULL_CM, invoice)
    perms = up.get_permissions
    assert_equal((Set.new [:DEFAULT_PERMISSION, :CM_INVOICE_USER_PERMISSION,
      :INVOICE_VIEW_PERMISSION, :CM_EDIT_SETUP_PERMISSION,
      :CM_BILLING_PERIOD_EDIT_PERMISSION, :INVOICE_APPROVE_PERMISSION,
      :COMMENT_ADD_PERMISSION, :VIEW_RULES_PERMISSION,
      :CM_ANY_INVOICE_PERMISSION, :CM_TEAM_ROLE_PERMISSION]), perms)
  end
  
  def test_cm_all_rights_approved_state
    invoice = CMInvoice.new([:READ_ACCESS, :VIEW_RULES_ACCESS, :CM_EDIT_ACCESS])
    invoice.approval_status = :APPROVED_STATUS
    up = UserPermissions.new(FULL_CM, invoice)
    perms = up.get_permissions
    assert_equal((Set.new [:DEFAULT_PERMISSION, :CM_INVOICE_USER_PERMISSION,
      :INVOICE_VIEW_PERMISSION, :VIEW_RULES_PERMISSION, :CM_BILLING_PERIOD_ADD_PERMISSION,
      :CM_ANY_INVOICE_PERMISSION, :CM_TEAM_ROLE_PERMISSION]), perms)
  end
  
  def test_cm_all_rights_cm_state_in_transition
    invoice = CMInvoice.new([:READ_ACCESS, :EDIT_ACCESS, :CM_EDIT_ACCESS,
      :VIEW_RULES_ACCESS, :APPROVE_ACCESS])
    invoice.approval_status = :CM_STATUS
    invoice.in_transition = true
    up = UserPermissions.new(FULL_CM, invoice)
    perms = up.get_permissions
    assert_equal((Set.new [:DEFAULT_PERMISSION, :CM_INVOICE_USER_PERMISSION,
      :INVOICE_VIEW_PERMISSION, :CM_EDIT_SETUP_PERMISSION,
      :CM_BILLING_PERIOD_EDIT_PERMISSION, :INVOICE_APPROVE_PERMISSION, 
      :VIEW_RULES_PERMISSION, :COMMENT_ADD_PERMISSION,
      :COMMENT_ADD_PERMISSION, :CM_EDIT_BILLING_PERIOD_TRANSITION_PERMISSION,
      :CM_ANY_INVOICE_PERMISSION, :CM_TEAM_ROLE_PERMISSION]), perms)
  end
  
  def test_cm_all_rights_cm_state_in_transition_closed
    invoice = CMInvoice.new([:READ_ACCESS, :CM_EDIT_ACCESS, :VIEW_RULES_ACCESS])
    invoice.approval_status = :CLOSED_STATUS
    invoice.in_transition = true
    up = UserPermissions.new(FULL_CM, invoice)
    perms = up.get_permissions
    assert_equal((Set.new [:DEFAULT_PERMISSION, :CM_INVOICE_USER_PERMISSION,
      :INVOICE_VIEW_PERMISSION, :VIEW_RULES_PERMISSION, :CM_ANY_INVOICE_PERMISSION,
      :CM_TEAM_ROLE_PERMISSION]), perms)
  end

  def test_cm_all_rights_pa_state
    invoice = CMInvoice.new([:READ_ACCESS, :CM_EDIT_ACCESS, :VIEW_RULES_ACCESS])
    invoice.approval_status = :PA_STATUS
    invoice.in_transition = false
    up = UserPermissions.new(FULL_CM, invoice)
    perms = up.get_permissions
    assert_equal((Set.new [:DEFAULT_PERMISSION, :CM_INVOICE_USER_PERMISSION,
      :INVOICE_VIEW_PERMISSION, :VIEW_RULES_PERMISSION, :CM_ANY_INVOICE_PERMISSION,
      :CM_TEAM_ROLE_PERMISSION]), perms)
  end
  
  def test_pa_all_rights_pa_state
    invoice = CMInvoice.new([:READ_ACCESS, :EDIT_ACCESS, :APPROVE_ACCESS,
       :REJECT_ACCESS, :CONFIGURE_RULES_ACCESS])
    invoice.approval_status = :CM_STATUS
    up = UserPermissions.new(FULL_PA, invoice)
    perms = up.get_permissions
    assert_equal((Set.new [:DEFAULT_PERMISSION, :CM_INVOICE_USER_PERMISSION,
      :INVOICE_VIEW_PERMISSION, :INVOICE_APPROVE_PERMISSION, :INVOICE_REJECT_PERMISSION,
      :COMMENT_ADD_PERMISSION, :CONFIGURE_RULES_PERMISSION,
      :PA_ANY_INVOICE_PERMISSION]), perms)
  end
  
  def test_pa_all_rights_closed_state
    invoice = CMInvoice.new([:READ_ACCESS])
    invoice.approval_status = :CLOSED_STATUS
    up = UserPermissions.new(FULL_PA, invoice)
    perms = up.get_permissions
    assert_equal((Set.new [:DEFAULT_PERMISSION, :CM_INVOICE_USER_PERMISSION,
      :INVOICE_VIEW_PERMISSION, :PA_ANY_INVOICE_PERMISSION]), perms)    
  end
  
  def test_pa_all_rights_cm_state
    invoice = CMInvoice.new([:READ_ACCESS, :CONFIGURE_RULES_ACCESS])
    invoice.approval_status = :CM_STATUS
    up = UserPermissions.new(FULL_PA, invoice)
    perms = up.get_permissions
    assert_equal((Set.new [:DEFAULT_PERMISSION, :CM_INVOICE_USER_PERMISSION,
      :INVOICE_VIEW_PERMISSION, :PA_ANY_INVOICE_PERMISSION,
      :CONFIGURE_RULES_PERMISSION]), perms)    
  end
  
  def test_finance_pa_state
    invoice = CMInvoice.new([:READ_ACCESS])
    invoice.approval_status = :PA_STATUS
    up = UserPermissions.new(FINANCE, invoice)
    perms = up.get_permissions
    assert_equal((Set.new [:DEFAULT_PERMISSION, :FINANCE_INVOICE_PERMISSION,
      :CM_INVOICE_USER_PERMISSION, :INVOICE_VIEW_PERMISSION,
      :ACCESS_ALL_INVOICE_PERMISSION]), perms) 
  end
  
  def test_finance_user_finance_state
    invoice = CMInvoice.new([:READ_ACCESS, :EDIT_ACCESS, :INVOICE_LOG_ACCESS,
      :APPROVE_ACCESS, :REJECT_ACCESS])
    invoice.approval_status = :FINANCE_STATUS
    up = UserPermissions.new(FINANCE, invoice)
    perms = up.get_permissions
    assert_equal((Set.new [:DEFAULT_PERMISSION, :FINANCE_INVOICE_PERMISSION,
      :CM_INVOICE_USER_PERMISSION, :INVOICE_VIEW_PERMISSION,
      :ACCESS_ALL_INVOICE_PERMISSION, :INVOICE_APPROVE_PERMISSION,
      :INVOICE_REJECT_PERMISSION, :COMMENT_ADD_PERMISSION,
      :INVOICE_LOG_PERMISSION]), perms)
  end
  
  def test_finance_user_closed_state
    invoice = CMInvoice.new([:READ_ACCESS, :INVOICE_LOG_ACCESS])
    invoice.approval_status = :CLOSED_STATUS
    up = UserPermissions.new(FINANCE, invoice)
    perms = up.get_permissions
    assert_equal((Set.new [:DEFAULT_PERMISSION, :FINANCE_INVOICE_PERMISSION,
      :CM_INVOICE_USER_PERMISSION, :INVOICE_VIEW_PERMISSION,
      :ACCESS_ALL_INVOICE_PERMISSION, :INVOICE_LOG_PERMISSION]), perms)
  end
  
  def test_finance_user_approved_state
    invoice = CMInvoice.new([:READ_ACCESS, :INVOICE_LOG_ACCESS, :CM_INVOICE_CLOSE_RIGHT])
    invoice.approval_status = :APPROVED_STATUS
    up = UserPermissions.new(FINANCE, invoice)
    perms = up.get_permissions
    assert_equal((Set.new [:DEFAULT_PERMISSION, :FINANCE_INVOICE_PERMISSION,
      :CM_INVOICE_USER_PERMISSION, :INVOICE_VIEW_PERMISSION,
      :ACCESS_ALL_INVOICE_PERMISSION, :INVOICE_CLOSE_PERMISSION,
      :INVOICE_LOG_PERMISSION]), perms)
  end
  
  def test_finance_user_approved_and_closed_state
    invoice = CMInvoice.new([:READ_ACCESS, :INVOICE_LOG_ACCESS])
    invoice.approval_status = :CLOSED_STATUS
    up = UserPermissions.new(FINANCE, invoice)
    perms = up.get_permissions
    assert_equal((Set.new [:DEFAULT_PERMISSION, :FINANCE_INVOICE_PERMISSION,
      :CM_INVOICE_USER_PERMISSION, :INVOICE_VIEW_PERMISSION,
      :ACCESS_ALL_INVOICE_PERMISSION, :INVOICE_LOG_PERMISSION]), perms)
  end
  
  def test_sdt_user
    
  end

end
