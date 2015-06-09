module PivotalSettingsHelper
  def self.fetch(list)
    settings = list
    missing_setting = false
    settings = Hash[settings.map do |setting_key|
        setting_value = Setting.plugin_pivotal[setting_key]

        if setting_value.blank?
          logger.warn("Pivotal plugin setting #{setting_key} is empty")
          missing_setting = true
        end

        [setting_key, setting_value]
      end]

    return missing_setting ? false : settings
  end
end
