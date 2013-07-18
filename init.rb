require 'redmine'
require 'redshares/redshares'
require_dependency 'redshare_observer'
ActiveRecord::Base.observers << :redshare_observer

Redmine::Plugin.register :redshares do
  name 'Redshares plugin'
  author 'Jonathan Zaiat - BIA'
  description 'This is a plugin for Redmine to allow the sharing of issues among users, with readonly or editable permission.'
  version '1.0.0'
  url 'http://github.com/jzaiat/redshares'
  author_url 'http://github.com/jzaiat'
  settings :default => {}, :partial => 'settings/redshare_settings'
  
  requires_redmine :version_or_higher => '2.0.0'

  Redmine::AccessControl.map do |map|
    map.project_module :redshare do |map|
      map.permission :view_redshares, {}, :require => :member
      map.permission :edit_redshares, {:redshares => [:new, :create, :append, :destroy, :autocomplete_for_user]}, :require => :member
      map.permission :delete_issue_redshares, {:redshares => :delete}, :require => :member
    end
  end
  
  settings :default => {}, :partial => 'settings/redshares_settings'
  
end
 
ActionDispatch::Callbacks.to_prepare do
  unless Issue.included_modules.include?(Redshares::Patches::IssuePatch)
    Issue.send(:include, Redshares::Patches::IssuePatch)
  end
  unless Mailer.included_modules.include?(Redshares::Patches::MailerPatch)
    Mailer.send(:include, Redshares::Patches::MailerPatch)
  end

  [IssuesController].each do |controller|
    Redshares::Patches::AddHelpersForRedsharesPatch.apply(controller)
  end
end

# Include hook code here
require File.dirname(__FILE__) + '/lib/acts_as_redshareable'
ActiveRecord::Base.send(:include, Redmine::Acts::Redshareable)