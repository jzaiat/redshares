require 'redshares/hooks/views_issues_hook'     

Rails.configuration.to_prepare do
  require 'redshares/patches/issue_patch'
  require 'redshares/patches/mailer_patch'
end

module Redshares

  def self.settings() Setting[:plugin_redshares].blank? ? {} : Setting[:plugin_redshares] end
    
end