module Redshares
  module Hooks
    class ViewsIssuesHook < Redmine::Hook::ViewListener
      render_on :view_issues_sidebar_planning_bottom, :partial => 'issues/redshares_sidebar'
    end
  end
end