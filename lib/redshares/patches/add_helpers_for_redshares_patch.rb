# This module patches a controller so that the methods from RedsharesHelper and
# IssuesRedsharesHelper are available in its views.
module Redshares
  module Patches
    module AddHelpersForRedsharesPatch
      def self.apply(controller)
        controller.send(:helper, 'redshares')
        controller.send(:helper, 'issues_redshares')
      end
    end
  end
end