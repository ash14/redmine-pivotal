module PivotalSettingsHelper
  def self.fetch(list)
    settings = list
    missing_setting = false
    settings = Hash[settings.map do |setting_key|
        setting_value = Setting.plugin_pivotal[setting_key]
        missing_setting = setting_value.blank?

        [setting_key, setting_value]
      end]

    return missing_setting ? false : settings
  end
end
