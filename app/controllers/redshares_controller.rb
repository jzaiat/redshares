class RedsharesController < ApplicationController
  unloadable
  before_filter :require_login, :find_redshareables, :only => [:redshare, :unredshare]

  def redshare
    set_redshare(@redshareables, User.current, true)
  end

  def unredshare
    set_redshare(@redshareables, User.current, false)
  end

  before_filter :find_project, :authorize, :only => [:new, :create, :append, :destroy, :autocomplete_for_user]

  def new
  end

  def create
    editable = params[:editable]
    user_ids = []
    if params[:redshare].is_a?(Hash)
      user_ids << (params[:redshare][:user_ids] || params[:redshare][:user_id])
    else
      user_ids << params[:user_id]
    end
    user_ids.flatten.compact.uniq.each do |user_id|
      Redshare.create(:issue => @redshared, :user_id => user_id, :editable => editable)
    end
    respond_to do |format|
      format.html { redirect_to_referer_or {render :text => 'Redshare added.', :layout => true}}
      format.js
      format.api { render_api_ok }
    end
  end
  
  def append
    if params[:redshare].is_a?(Hash)
      user_ids = params[:redshare][:user_ids] || [params[:redshare][:user_id]]
      @users = User.active.find_all_by_id(user_ids)
    end
  end

  def destroy
    @redshared.set_redshare(User.find(params[:user_id]), false)
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
      format.api { render_api_ok }
    end
  end


  def autocomplete_for_user
    if @redshared
      @users = @redshared.addable_redshare_users
      q = params[:q].to_s.downcase
      @users = @users.select{|u| u.to_s.downcase.include?(q)} 
    end
    render :layout => false
  end
  
  private

  def find_project
    if params[:object_type] && params[:object_id]
      klass = Object.const_get(params[:object_type].camelcase)
      return false unless klass.respond_to?('redshared_to')
      @redshared = klass.find(params[:object_id])
      @project = @redshared.project
    elsif params[:project_id]
      @project = Project.visible.find_by_param(params[:project_id])
    end
  rescue
    render_404
  end

  def find_redshareables
    klass = Object.const_get(params[:object_type].camelcase) rescue nil
    if klass && klass.respond_to?('redshared_to')
      @redshareables = klass.find_all_by_id(Array.wrap(params[:object_id]))
      raise Unauthorized if @redshareables.any? {|w| w.respond_to?(:visible?) && !w.visible?}
    end
    render_404 unless @redshareables.present?
  end

  def set_redshare(redshareables, user, redsharing)
    redshareables.each do |redshareable|
      redshareable.set_redshare(user, redsharing)
    end
    respond_to do |format|
      format.html { redirect_to_referer_or {render :text => (redsharing ? 'Redshare added.' : 'Redshare removed.'), :layout => true}}
      format.js { render :partial => 'set_redshare', :locals => {:user => user, :redshared => redshareables} }
    end
  end
end
