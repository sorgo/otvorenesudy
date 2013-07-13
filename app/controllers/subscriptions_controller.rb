# encoding: utf-8

class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @period = Period.find(params[:period_id])

    @subscription = Subscription.new(params[:subscription])

    @subscription.user   = current_user
    @subscription.period = @period

    if @subscription.save
      flash[:notice] = 'Odoberanie bolo úspešne zaregistrované.'
    else
      flash[:error] = 'Nastala chyba. Odoberanie nebolo zaregistrované.'
    end

    redirect_to :back
  end

  def update
    @subscription = Subscription.find(params[:id])

    @subscription.period = Period.find(params[:period_id])

    if @subscription.save
      flash[:notice] = 'Odoberanie bolo úspešne aktualizované.'
    else
      flash[:error] = 'Nastala chyba. Odoberanie nebolo aktualizované.'
    end

    redirect_to :back
  end

  def destroy
    @subscription = Subscription.find(params[:id])

    @subscription.destroy

    flash[:notice] = 'Odoberanie bolo úspešne zrušené.'

    redirect_to :back
  end
end
