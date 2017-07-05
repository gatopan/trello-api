class EntitiesController < ApplicationController
  def index
    @entities = Entity.all

    render json: @entities
  end

  def show
    @entity = Entity.find(params[:id])

    render json: @entity
  end

  def create
    @entity = Entity.new(permitted_params)

    if @entity.save
      render json: @entity, status: :ok
    else
      render json: { message: "Could not create Entity with submitted parameters." }, status: :unprocessable_entity
    end
  end

  def update
    @entity = Entity.find(params[:id])

    if @entity.update(permitted_params)
      render json: @entity, status: :ok
    else
      render json: { message: "Could not update Entity #{@entity.id} with submitted parameters." }, status: :unprocessable_entity
    end
  end

  def destroy
    @entity = Entity.find(params[:id])

    if @entity.destroy
      head :no_content, status: :ok
    else
      render json: { message: "Could not destroy Entity #{@entity.id}." } , status: :unprocessable_entity
    end
  end

  private

  def permitted_params
    params.permit!.except(:controller, :action)
  end
end
