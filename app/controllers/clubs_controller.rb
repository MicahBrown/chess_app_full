class ClubsController < ApplicationController
  def new
    @club = Club.new
  end

  def create
    @club = Club.new(club_params.merge(creator: current_user))

    if @club.save
      redirect_to club_path(@club), notice: "Successfully created club!"
    else
      render :new
    end
  end

  def edit
  end

  def update
  end

  def show
  end

  def index
  end

  def destroy
  end

  private

    def club_params
      params.require(:club).permit(:name)
    end
end
