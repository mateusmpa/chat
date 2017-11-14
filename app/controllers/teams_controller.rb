class TeamsController < ApplicationController
  before_action :set_by_slug_team, only: [:show]
  before_action :set_team, only: [:destroy]

  def index
    @teams = current_user.teams
  end

  def show
    authorize! :read, @team
  end

  def create
    @team = Team.new(team_params)

    respond_to do |format|
      if @team.save
        format.html { redirect_to "/#{@team.slug}" }
      else
        format.html { redirect_to main_app.root_url, notice: @team.errors }
      end
    end
  end

  def destroy
    authorize! :destroy, @team
    @team.destroy

    respond_to do |format|
      format.json { render json: true }
    end
  end

  private

  def set_by_slug_team
    @team = Team.find_by(slug: params[:slug])
  end

  def team_params
    params.require(:team).permit(:slug).merge(user: current_user)
  end

  def set_team
    @team = Team.find(params[:id])
  end
end
