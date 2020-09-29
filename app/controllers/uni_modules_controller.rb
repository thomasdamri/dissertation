class UniModulesController < ApplicationController
  before_action :set_uni_module, only: [:show, :edit, :update, :destroy]

  # GET /uni_modules
  # GET /uni_modules.json
  def index
    @uni_modules = UniModule.all
  end

  # GET /uni_modules/1
  # GET /uni_modules/1.json
  def show
  end

  # GET /uni_modules/new
  def new
    @uni_module = UniModule.new
  end

  # GET /uni_modules/1/edit
  def edit
  end

  # POST /uni_modules
  # POST /uni_modules.json
  def create
    @uni_module = UniModule.new(uni_module_params)

    @uni_module.staff_modules.build(user: current_user)

    puts "-----"
    puts @uni_module.valid?
    puts @uni_module.errors.full_messages

    respond_to do |format|
      if @uni_module.save
        format.html { redirect_to @uni_module, notice: 'Module was successfully created.' }
        format.json { render :show, status: :created, location: @uni_module }
      else
        format.html { render :new }
        format.json { render json: @uni_module.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /uni_modules/1
  # PATCH/PUT /uni_modules/1.json
  def update
    respond_to do |format|
      if @uni_module.update(uni_module_params)
        format.html { redirect_to @uni_module, notice: 'Uni module was successfully updated.' }
        format.json { render :show, status: :ok, location: @uni_module }
      else
        format.html { render :edit }
        format.json { render json: @uni_module.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /uni_modules/1
  # DELETE /uni_modules/1.json
  def destroy
    @uni_module.destroy
    respond_to do |format|
      format.html { redirect_to uni_modules_url, notice: 'Uni module was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_uni_module
      @uni_module = UniModule.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def uni_module_params
      params.require(:uni_module).permit(:name, :code)
    end
end
