module Pivotal
  include Rails.application.routes.url_helpers

  class Hooks < Redmine::Hook::ViewListener
    def controller_issues_edit_before_save(context)
      before_save(context)
    end

    def controller_issues_bulk_edit_before_save(context)
      before_save(context)
    end

    private
    def before_save(context = {})
      settings = PivotalSettingsHelper.fetch(%i(pivotal_api_token pivotal_project_id redmine_accepted_status_id pivotal_external_integration_id))
      return if settings == false

      pivotal = TrackerApi::Client.new(token: settings[:pivotal_api_token])
      project = pivotal.project(settings[:pivotal_project_id])

      if context[:issue].status.id == settings[:redmine_accepted_status_id].to_i
        pivotal_owner = project.memberships.find { |m| m.person.email === User.current.email_address.address }
        story_attributes = {
          name: context[:issue].subject,
          description: context[:issue].description,
          labels: ['redmine'],
          integration_id: settings[:pivotal_external_integration_id].to_i,
          external_id: issue_url(context[:issue].id)[1..-1] # drop leading slash
        }

        story_attributes[:owner_ids] = [pivotal_owner.person.id] if pivotal_owner
        project.create_story(story_attributes)
      end
    end
  end
end

