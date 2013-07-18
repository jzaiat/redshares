module IssuesRedsharesHelper
  def sidebar_redshares
    unless @sidebar_redshares
      @sidebar_redshares = []
    end
    @sidebar_redshares
  end
end