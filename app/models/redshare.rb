class Redshare < ActiveRecord::Base
  unloadable

  belongs_to :issue
  belongs_to :user

  validates_presence_of :user
  validate :validate_user
  
  # Unredshare things that users are no longer allowed to view
  def self.prune(options={})
    if options.has_key?(:user)
      prune_single_user(options[:user], options)
    else
      pruned = 0
      User.where("id IN (SELECT DISTINCT user_id FROM #{table_name})").all.each do |user|
        pruned += prune_single_user(user, options)
      end
      pruned
    end
  end

  def is_readonly?()
    !self.editable
    #self.role_id == Integer(Redshares.settings['readonly_role'])
  end
  
  def is_editable?()
    #self.role_id == Integer(Redshares.settings['edit_role'])
    self.editable
  end
  
  def to_s
    self.info
  end
 
  def info
   "user:#{self.user_id} editable:#{self.editable}"
  end
  
  protected

  def validate_user
    errors.add :user_id, :invalid unless user.nil? || user.active?
  end

  private

  def self.prune_single_user(user, options={})
    return unless user.is_a?(User)
    pruned = 0
    where(:user_id => user.id).all.each do |redshare|
      next if redshare.redshareable.nil?

      if options.has_key?(:project)
        next unless redshare.redshareable.respond_to?(:project) && redshare.redshareable.project == options[:project]
      end

      if redshare.redshareable.respond_to?(:visible?)
        unless redshare.redshareable.visible?(user)
          redshare.destroy
          pruned += 1
        end
      end
    end
    pruned
  end

end