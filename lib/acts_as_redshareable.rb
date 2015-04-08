# ActsAsRedshareable
module Redmine
  module Acts
    module Redshareable
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_redshareable(options = {})
          return if self.included_modules.include?(Redmine::Acts::Redshareable::InstanceMethods)
          class_eval do
            has_many :redshares, :dependent => :delete_all
            has_many :redshare_users, :through => :redshares, :source => :user, :validate => false

            scope :redshared_to, lambda { |user_id|
              { :include => :redshares,
                :conditions => ["#{Redshare.table_name}.user_id = ?", user_id] }
            }
            attr_protected :redshare_ids, :redshare_user_ids
          end
          send :include, Redmine::Acts::Redshareable::InstanceMethods
          alias_method_chain :redshare_user_ids=, :uniq_ids
        end
      end

      module InstanceMethods
        def self.included(base)
          base.extend ClassMethods
        end

        # Returns an array of users that are proposed as redshares
        def addable_redshare_users
          members = self.project.users_by_role()
          filter_roles = Role.where(:id => Redshares.settings['roles'])
          valid_users = filter_roles.map{|r| members[r]}.flatten
          valid_users.uniq! #remove duplicates
          #disallow to redshare to assigned
          valid_users.delete self.assigned_to
          users = valid_users - self.redshare_users
          users
        end

        # Adds user as a redshare
        def add_redshare(user)
          self.redshares << Redshare.new(:user => user)
        end

        # Removes user from the redshares list
        def remove_redshare(user)
          return nil unless user && user.is_a?(User)
          Redshare.delete_all "issue_id = #{self.id} AND user_id = #{user.id}"
        end

        # Adds/removes redshare
        def set_redshare(user, redsharing=true)
          redsharing ? add_redshare(user) : remove_redshare(user)
        end

        # Overrides redshare_user_ids= to make user_ids uniq
        def redshare_user_ids_with_uniq_ids=(user_ids)
          if user_ids.is_a?(Array)
            user_ids = user_ids.uniq
          end
          send :redshare_user_ids_without_uniq_ids=, user_ids
        end

        # Returns true if object is redshared by +user+
        def redshared_to?(user)
          !!(user && self.redshare_user_ids.detect {|uid| uid == user.id })
        end
        
        def redshare_editable?(user)
          if self.redshared_to?(user)
           redshare = self.redshares.select{ |r| r.user == user}.first
           return redshare.is_editable?
          end
          false
        end

        def notified_redshares
          notified = redshare_users.active
          notified.reject! {|user| user.mail.blank? || user.mail_notification == 'none'}
          notified
        end

        # Returns an array of redshares' email addresses
        def redshare_recipients
          notified_redshares.collect(&:mail)
        end
        
        #TODO: there should be better ways to do this
        def redshare_mapped_list
          share_type = self.redshares.collect do |redshare|
                        redshare.editable
                       end
          share_type.zip(redshare_users)
        end

        module ClassMethods; end
      end
    end
  end
end
