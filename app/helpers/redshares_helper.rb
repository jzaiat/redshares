module RedsharesHelper
  def redshare_link(objects, user)
    return '' unless user && user.logged?
    objects = Array.wrap(objects)

    redshared = objects.any? {|object| object.redshared_to?(user)}
    css = [redshare_css(objects), redshared ? 'icon icon-fav' : 'icon icon-fav-off'].join(' ')
    text = redshared ? l(:button_unredshare) : l(:button_redshare)
    url = redshare_path(
      :object_type => objects.first.class.to_s.underscore,
      :object_id => (objects.size == 1 ? objects.first.id : objects.map(&:id).sort)
    )
    method = redshared ? 'delete' : 'post'

    link_to text, url, :remote => true, :method => method, :class => css
  end

  # Returns the css class used to identify redshare links for a given +object+
  def redshare_css(objects)
    objects = Array.wrap(objects)
    id = (objects.size == 1 ? objects.first.id : 'bulk')
    "#{objects.first.class.to_s.underscore}-#{id}-redshare"
  end

  # Returns a comma separated list of users redsharing the given object
  def redshares_list(object)
    remove_allowed = User.current.allowed_to?("delete_#{object.class.name.underscore}_redshares".to_sym, object.project) && object.editable?(User.current)
    content = ''.html_safe

    lis = object.redshare_mapped_list.collect do |element|
      editable = element[0]
      user = element[1]
      
      s = ''.html_safe
      s << avatar(user, :size => "16").to_s
      s << link_to_user(user, :class => 'user')
      
      redshares_type = editable ? l(:edit_share) : l(:readonly_share)
      
      s << ('<span class="redshare_role"> ('+ redshares_type +')</span>').html_safe
      if remove_allowed
        url = {:controller => 'redshares',
               :action => 'destroy',
               :object_type => object.class.to_s.underscore,
               :object_id => object.id,
               :user_id => user}
        s << ' '
        s << link_to(image_tag('delete.png'), url,
                     :remote => true, :method => 'delete', :class => "delete")
      end
      content << content_tag('li', s, :class => "user-#{user.id}")
    end      
    content.present? ? content_tag('ul', content, :class => 'redshares') : content
  end

  def redshares_checkboxes(object, users, checked=nil)
    users.map do |user|
      c = checked.nil? ? object.redshared_to?(user) : checked
      tag = check_box_tag 'issue[redshare_user_ids][]', user.id, c, :id => nil
      content_tag 'label', "#{tag} #{h(user)}".html_safe,
                  :id => "issue_redshare_user_ids_#{user.id}",
                  :class => "floating"
    end.join.html_safe
  end
end