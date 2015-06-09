class PivotalController < ApplicationController
  unloadable
  skip_before_filter :verify_authenticity_token
  skip_before_filter :check_if_login_required

  def post
    settings = PivotalSettingsHelper.fetch(%i(pivotal_api_token pivotal_project_id pivotal_external_integration_id redmine_completed_status_id))
    if settings == false
      render json: {}
      return
    end

    if params['kind'] != 'story_update_activity'
      render json: {}
      return
    end

    params['changes'].each do |change|
      next unless change['kind'] == 'story' && change['new_values']['current_state'] == 'accepted'

      pivotal = TrackerApi::Client.new(token: settings[:pivotal_api_token])
      project = pivotal.project(settings[:pivotal_project_id])
      pivotal_story = project.story(change['id'])

      next unless pivotal_story.integration_id == settings[:pivotal_external_integration_id].to_i

      issue = Issue.find(pivotal_story.external_id.scan(/\d+/).first)
      issue.status = IssueStatus.find(settings[:redmine_completed_status_id])
      issue.save!
    end

    render json: {}
  end
end
