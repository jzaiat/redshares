require_dependency 'issue'

module Redshares
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc: 
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development

          has_many :redshares, :class_name => "Redshare", :dependent => :destroy
          acts_as_redshareable

          safe_attributes 'redshare_user_ids',
            :if => lambda {|issue, user| issue.new_record? && user.allowed_to?(:edit_issue_redshares, issue.project)} 

          alias_method_chain :visible?, :redshares
          alias_method_chain :editable?, :redshares
          alias_method_chain :initialize, :redshares
          alias_method_chain :notified_users, :redshares

          scope :redshared, lambda {includes(:project).joins(:redshares).where("#{Redshare.table_name}.user_id = ?", User.current.id)}
          #TODO: use the visible scope of Issue model instead of repeating it here
          scope :orig_visible, lambda {|*args|
            includes(:project).where(Issue.visible_condition(args.shift || User.current, *args))
          }
          scope :visible, lambda {|*args| self.redshared_union_visible}

          #TODO: this is not very efficient, it should use a sql UNION instead.
          def self.redshared_union_visible
            @issues1 = orig_visible
            @issues2 = redshared            
            issues_set = @issues1.map { |i| i.id }.to_set + @issues2.map { |i| i.id }.to_set
            self.includes(:project).where(:id => issues_set.to_a)
          end
        end
      end

      module InstanceMethods
        def initialize_with_redshares(attributes=nil, *args)
          initialize_without_redshares(attributes, args)
          if new_record?
            # set default values for new records only
            self.redshare_user_ids = []
          end
        end
        def visible_with_redshares?(usr=nil)
          user = (usr || User.current)
          is_visible = visible_without_redshares?(user)
          #check whether usr (or current user) is redshared in this issue
          return is_visible || self.redshared_to?(user)
        end
        def editable_with_redshares?(user=User.current)
          if self.visible_without_redshares?(user)
            return editable_without_redshares?(user)
          else
            return self.redshare_editable?(user)
          end
        end
        def notified_users_with_redshares
          previously_notified = notified_users_without_redshares
          currently_notified = notified_redshares + previously_notified
          currently_notified.uniq! #remove duplicates
          currently_notified
        end
      end
    end
  end
end