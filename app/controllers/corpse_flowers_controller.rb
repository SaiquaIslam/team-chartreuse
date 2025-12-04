# frozen_string_literal: true

class CorpseFlowersController < ApplicationController
  def index
    @corpse_flowers = CorpseFlower.all
    
    # Apply search (M1 PR2)
    @corpse_flowers = @corpse_flowers.search(params[:search]) if params[:search].present?
    
    # Apply filters (M2 PR1 - US04)
    @corpse_flowers = @corpse_flowers.filter_by_size(params[:sizes]) if params[:sizes].present?
    @corpse_flowers = @corpse_flowers.filter_by_color(params[:colors]) if params[:colors].present?
    
    # Handle putridity ranges (convert ranges to individual levels)
    if params[:putridity_ranges].present?
      putridity_levels = expand_putridity_ranges(params[:putridity_ranges])
      @corpse_flowers = @corpse_flowers.filter_by_putridity(putridity_levels)
    end
    
    # Order by newest first
    @corpse_flowers = @corpse_flowers.order(created_at: :desc)
    
    # Get available filter options (M2 PR1)
    @available_sizes = %w[small medium large]
    @available_colors = CorpseFlower.distinct_colors
    @putridity_ranges = [
      { label: 'Mild (1-3)', value: '1-3' },
      { label: 'Moderate (4-6)', value: '4-6' },
      { label: 'Strong (7-10)', value: '7-10' }
    ]
  end

  def show
    @corpse_flower = CorpseFlower.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to corpse_flowers_path, alert: 'Corpse flower not found.'
  end
  
  private
  
  # Helper to check if any filters are active
  def filters_active?
    params[:sizes].present? || params[:colors].present? || params[:putridity_ranges].present?
  end
  helper_method :filters_active?
  
  # Convert range strings like "1-3" to arrays like [1, 2, 3]
  def expand_putridity_ranges(ranges)
    ranges.flat_map do |range|
      start_val, end_val = range.split('-').map(&:to_i)
      (start_val..end_val).to_a
    end
  end
end