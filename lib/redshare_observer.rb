class RedshareObserver < ActiveRecord::Observer
  def after_create(redshare)
    if redshare
      Mailer.redshare_add(redshare).deliver
    end
  end
end
