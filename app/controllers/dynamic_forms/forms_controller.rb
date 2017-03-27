class DynamicForms::FormsController < ApplicationController
  layout 'comfy/admin/cms'
  before_filter :initialize_comfy

  def initialize_comfy
    @site = Comfy::Cms::Site.first
  end

  def index
    @forms = ::Form.page(params[:page] || 1)
    render :template => "forms/index"
  end

  # the Forms#show action actually renders FormSubmissions#new for displaying the form
  def show
    @form = ::Form.find(params[:id])
    @form_submission = @form.form_submissions.build
    render :template => 'form_submissions/new'
  end

  def new
    @form = ::Form.new(:submit_label => 'Submit')
    render :template => "forms/new"
  end

  def edit
    @form = ::Form.find(params[:id])
    render :template => "forms/edit"
  end

  def create
    # check to see if preview should be rendered rather than saving changes
    preview_new and return if params[:commit].to_s.downcase == 'preview'

    @form = ::Form.new(form_params)
    if @form.save
      flash[:success] = translate(:form_created, :scope => [:dynamic_forms, :controllers, :forms], :name => @form.name)
      redirect_to form_path(@form)
    else
      render :action => 'new', :template => "forms/new"
    end
  end

  def update
    # check to see if preview should be rendered rather than saving changes
    preview_edit and return if form_params[:commit].to_s.downcase == 'preview'

    @form = ::Form.find(params[:id])

    if @form.update_attributes(form_params)
      flash[:success] = translate(:form_updated, :scope => [:dynamic_forms, :controllers, :forms], :name => @form.name)
      redirect_to form_path(@form)
    else
      render :action => 'edit', :template => "forms/edit"
    end
  end

  def destroy
    form = ::Form.find(params[:id])
    form.destroy
    flash[:success] = translate(:form_deleted, :scope => [:dynamic_forms, :controllers, :forms], :name => form.name)
    redirect_to forms_path
  end

  private

  def preview_new
    @form = ::Form.new(form_params)
    if @form.valid?
      @form_submission = @form.form_submissions.build
      @form_submission.form = @form # Believe it or not, this is necessary
    end
    render :action => 'new', :template => "forms/new"
  end

  def preview_edit
    @form = ::Form.new(form_params)
    @form.id = form_params[:id]
    if @form.valid?
      @form_submission = @form.form_submissions.build
      @form_submission.form = @form # Believe it or not, this is necessary
    end
    render :action => 'edit', :template => "forms/edit"
  end

  def form_params
    #  => [:sti_type, :position, :label, :required, :min_length, :max_length, :_destroy]
    params.require(:form).permit!
  end

end
