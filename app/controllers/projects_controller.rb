class ProjectsController < ApplicationController
  before_filter :login_required
  before_filter :fetch_project, :only => [:destroy, :edit, :update]

  verify :method      => :post, :only => [:create, :refresh],
         :redirect_to => {:action => :index}
  verify :method      => :put, :only => [:update],
         :redirect_to => {:action => :index}
  verify :method      => :delete, :only => [:destroy],
         :redirect_to => {:action => :index}

  def index
    if can_view_projects?
      @projects = Project.list params[:page], current_user.row_limit
    end
  end


  def create
    if can_edit_projects?
      @project = Project.new(params[:project])
      if @project.save
        flash[:notice] = "Project was successfully created."
        redirect_to projects_path
      else
        index
        render :action => 'index'
      end
    end
  end

  def edit
    can_edit_projects?
  end

  def update
    if can_edit_projects?
      if @project.update_attributes(params[:project])
        flash[:notice] = "Project #{@project.name} was successfully updated."
        redirect_to projects_path
      else
        render :action => 'edit'
      end
    end
  end

  def destroy
    name = @project.name || ""
    @project.destroy
    flash[:notice] = "Project #{name} was successfully deleted."
    redirect_to projects_path
  end

  def show
    @project = Project.find(params[:id])
    if params[:iteration_id]
      @iteration = Iteration.find(params[:iteration_id], :include => [{:stories => {:tasks => :task_estimates}}])
    else
      @iteration = @project.latest_iteration
    end
  end

  def refresh
    @project = Project.find(params[:id], :include => [{:latest_iteration => {:stories => {:tasks => :task_estimates}}}])
    @project.refresh
    if @project.save
      flash[:notice] = "Project #{@project.name} was successfully refreshed."
    else
      flash[:error] = "Project #{@project.name} refresh failed."
    end
    redirect_to projects_path
  end

  private

  def can_view_projects?
    return true if current_user.developer?
    flash[:error] = "You do not have access to that page"
    redirect_to home_path
    false
  end

  def can_edit_projects?
    return true if current_user.developer? && current_user.sysadmin?
    flash[:error] = "You do not have access to edit a project"
    redirect_to projects_path
    false
  end

  def fetch_project
    @project = Project.find(params[:id])
  end
end
