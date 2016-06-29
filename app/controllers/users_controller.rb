class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  load_and_authorize_resource

  # GET /users
  # GET /users.json
  def index
    if current_user.super_admin?
      @users = User.all

    elsif current_user.teacher?
      @user = current_user
      @requests = @user.requests
      @future_requests = @user.requests.where("date >= ?", Date.today)


    elsif current_user.substitute?
      @user = current_user
      @sub_schools = @user.schools.map do |school|
        "%#{school.name}%"
      end
      @requests = User.where(teacher: true).joins(:requests, :schools).where("schools.name ILIKE ANY ( array[?] )", @sub_schools).uniq

      @open_request_check = []

      @requests.map do |user|
         user.requests.where(active: true, sub_claim: false).map do |request|
           @open_request_check << request
         end
       end

      @claims = current_user.requests.order(date: :ASC)

      @future_requests = @user.requests.where("date >= ?", Date.today)



    elsif current_user.admin?
      @users = User.joins(:school).where(:schools => {:name => current_user.schools})
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @request = @user.requests.new
  end

  # GET /users/new
  def new
    @user = User.new

  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to root_path, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :teacher, :substitute, :admin, :super_admin, :password, :grade_ids => [], :subject_ids => [], :school_ids => [], :request_ids => [])
    end
end
