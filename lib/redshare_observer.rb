class RedshareObserver < ActiveRecord::Observer
  def after_create(redshare)
    if redshare
      Mailer.redshare_add(redshare).deliver if redshare.user.notify_about?(redshare)
    end
  end
end
