require_dependency 'hooks'

Redmine::Plugin.register :pivotal do
  name 'Pivotal Integration'
  author 'Ashvin Jayaram'
  description 'Accepting issues in Redmine creates pivotal stories; accepting Pivotal stories completes the Redmine issue'
  version '0.0.1'

  settings default: {empty: true}, partial: 'settings/pivotal'
end
