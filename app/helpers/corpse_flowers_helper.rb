# frozen_string_literal: true

module CorpseFlowersHelper
  def has_filters?
    params[:sizes].present? || params[:colors].present? || params[:putridity].present?
  end
  
  def active_filter_count
    count = 0
    count += Array(params[:sizes]).reject(&:blank?).size
    count += Array(params[:colors]).reject(&:blank?).size
    count += Array(params[:putridity]).reject(&:blank?).size
    count
  end
  
  # Helper to format putridity ranges for display
  def putridity_label(level)
    case level
    when 1..3
      "#{level} (Mild)"
    when 4..6
      "#{level} (Moderate)"
    when 7..10
      "#{level} (Strong)"
    else
      level.to_s
    end
  end
end