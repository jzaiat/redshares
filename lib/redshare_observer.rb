class RedshareObserver < ActiveRecord::Observer
  def after_create(redshare)
    if redshare
      Mailer.redshare_add(redshare).deliver unless redshare.user.mail_notification.blank? || redshare.user.mail_notification == 'none'
    end
  end
end
