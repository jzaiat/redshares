require_dependency 'mailer'

module Redshares
  module Patches
    module MailerPatch
      def self.included(base) # :nodoc: 
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
        end
      end

      module InstanceMethods
        # Builds a Mail::Message object used to email recipients of the added Redshare.
        #
        # Example:
        #   redshare_add(redshare) => Mail::Message object
        #   Mailer.redshare_add(redshare).deliver => sends an email to redshare recipients
        def redshare_add(redshare)
          redmine_headers 'Project' => redshare.issue.project.identifier,
                          'Issue-Id' => redshare.issue.id,
                          'Issue-Author' => redshare.issue.author.login
          redmine_headers 'Issue-Assignee' => redshare.issue.assigned_to.login if redshare.issue.assigned_to
          message_id redshare.issue
          @shared_by = (redshare.issue.assigned_to)? redshare.issue.assigned_to.to_s : redshare.issue.author.to_s
          @redshare_type = redshare.issue.tracker
          @issue = redshare.issue
          @issue_url = url_for(:controller => 'issues', :action => 'show', :id => redshare.issue)          
          subject = l(:mail_subject_redshare, :redshare_type => @redshare_type)

          recipients = redshare.user.mail
          mail :to => recipients,
            :subject => "[#{redshare.issue.project.name} - #{redshare.issue.tracker.name} ##{redshare.issue.id}] (#{redshare.issue.status.name}) #{subject}" 
        end

      end
    end
  end
end