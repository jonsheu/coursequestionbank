class ProblemsController < ApplicationController
  before_filter :set_filter_options
  load_and_authorize_resource
 @@defaults = HashWithIndifferentAccess.new({
   'search' => "",
   'tags' => [],
   'sort_by' => 'Relevancy',
   'problem_type' => [],
   'collections' => [],
   'per_page' => 60, 'page' => 1 })

  def set_filter_options
    session[:filters] ||= HashWithIndifferentAccess.new(@@defaults)

    @@defaults.each do |key, value|
      session[:filters][key] ||= value
    end

    session[:filters][:page] = nil
    session[:filters] = session[:filters].merge params.slice(:page, :per_page)
  end

  def set_filters
    session[:filters] = session[:filters].merge params.slice(:search, :tags, :sort_by)

    if session[:filters][:tags].is_a? String
      session[:filters][:tags] = Tag.parse_list session[:filters][:tags]
    end

    session[:filters][:problem_type] = []
    if params[:problem_type]
      params[:problem_type].each do |key, value|
          session[:filters][:problem_type] << key if value == "1"
      end
    end

    session[:filters][:bloom_category] = []
    if params[:bloom_category]
      params[:bloom_category].each do |key, value|
          session[:filters][:bloom_category] << key if value == "1"
      end
    end

    session[:filters][:collections] = []
    if params[:collections]
      params[:collections].each do |key, value|
          session[:filters][:collections] << Integer(key) if value == "1"
      end
    end
    if session[:filters][:collections].include?(0)
      session[:filters][:collections] = []
    end

    redirect_to problems_path
  end

  def home
      redirect_to problems_path
  end

  def index
    @collections = @current_user.collections
    @problems = Problem.filter(@current_user, session[:filters].clone)

    @sort_by_options = Problem.sort_by_options
    @all_problem_types = Problem.all_problem_types
  end

  def create
    if params[:previous_version] != nil
      previous_version = Problem.find(params[:previous_version])

      begin
        previous_version.supersede(@current_user, params[:ruql_source])

      rescue Exception => e
        if request.xhr?
          render json: {'error' => e.message}
        else
          flash[:error] = "Error in problem source: #{e.message}"
          flash[:ruql_source] = params[:ruql_source]
          flash.keep
          redirect_to :back
        end
        return
      end
    end

    flash[:notice] = "Question created"
    flash.keep
    if request.xhr?
      render json: {'error' => nil}
    else
      redirect_to problems_path
    end
  end

  def remove_from_collection
    collection = Collection.find(params[:collection_id])
    problem_to_remove = Problem.find(params[:id])
    if collection.problems.include? problem_to_remove
      collection.problems.delete(problem_to_remove)
      collection.save
      flash[:notice] = "problem successfully removed from #{collection.name}"
    else
      flash[:notice] = "the problem you attempted to remove does not exist in #{collection.name}"
    end
    flash.keep
    redirect_to edit_collection_path(:id => collection.id)
  end

  def add_tags
    problem = Problem.find(params[:id])
    tags = Tag.parse_list params[:tag_names]
    added = problem.add_tags(tags)
    if request.xhr?
      render :partial => "tags", locals: { problem: problem }
    else
      flash[:notice] = "Tags added" if added.size > 0
      flash.keep
      redirect_to :back
    end
  end

  def remove_tags
    problem = Problem.find(params[:id])
    tags = Tag.parse_list params[:tag_names]
    tags.each { |tag| problem.remove_tag tag }
    flash[:notice] = "Tags removed"
    flash.keep
    redirect_to :back
  end

  def update_multiple_tags
    new_tags = Tag.parse_list params[:tag_names]
    selected = params[:checked_problems] ? params[:checked_problems].keys : []
    if new_tags == []
      flash[:error] = "You need to enter a tag."
    elsif selected == []
      flash[:error] = "You need to select a problem."
    else
      selected.each do |problem_id|
        problem = Problem.find(problem_id)
        flash[:notice] = "Tags were added." if problem.add_tags(new_tags).size > 0
      end
    end
    flash.keep
    redirect_to :back
  end

  def supersede
    @problem = Problem.find(params[:id])
    @ruql_source = flash[:ruql_source]
  end
<<<<<<< Updated upstream
=======

  def bloom_categorize
    @problem = Problem.find(params[:id])
    category = params[:category]
    @problem.bloom_categorize(category)
    flash[:notice] = "Bloom category set."
    flash[:bump_problem] = @problem.id
    redirect_to :back
  end

  def set_privacy
    problem = Problem.find(params[:id])
    privacy = params[:privacy].downcase.strip
    if privacy == 'public'
      problem.is_public = true
    elsif privacy == 'private'
      problem.is_public = false
    else
      return
    end
    problem.save
    flash[:notice] = "Problem changed to #{privacy}"
    flash[:bump_problem] = problem.id
    redirect_to :back
  end
>>>>>>> Stashed changes
end
