# frozen_string_literal: true

class CorpseFlowersController < ApplicationController
  def index
    @corpse_flowers = CorpseFlower.all
    @corpse_flowers = @corpse_flowers.search(params[:search]) if params[:search].present?
    @corpse_flowers = @corpse_flowers.order(created_at: :desc)
  end

  def show
    @corpse_flower = CorpseFlower.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to corpse_flowers_path, alert: 'Corpse flower not found.'
  end
end