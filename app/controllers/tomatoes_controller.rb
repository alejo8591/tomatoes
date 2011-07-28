class TomatoesController < ApplicationController
  before_filter :authenticate_user!
  
  # GET /tomatoes
  # GET /tomatoes.xml
  def index
    @tomatoes = current_user.tomatoes.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tomatoes }
    end
  end

  # GET /tomatoes/1
  # GET /tomatoes/1.xml
  def show
    @tomato = current_user.tomatoes.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tomato }
    end
  end

  # GET /tomatoes/new
  # GET /tomatoes/new.xml
  def new
    @tomato = current_user.tomatoes.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tomato }
    end
  end

  # GET /tomatoes/1/edit
  def edit
    @tomato = current_user.tomatoes.find(params[:id])
  end

  # POST /tomatoes
  # POST /tomatoes.xml
  def create
    @tomato = current_user.tomatoes.build(params[:tomato])

    respond_to do |format|
      if @tomato.save
        format.js do
          @highlight = @tomato
          
          today_tomatoes = current_user.tomatoes.where(:created_at.gt => Time.now.beginning_of_day)
          @long_break = true if 0 == today_tomatoes.size % 2
          if @long_break
            flash.now[:notice] = "You just finished your #{ActiveSupport::Inflector::ordinalize(today_tomatoes.size)} pomodoro, you deserve a long break!"
          else
            flash.now[:notice] = 'Pomodoro finished, tomato created, it\'s time for a break.'
          end
          
          @tomato = current_user.tomatoes.build
          @tomatoes = current_user.tomatoes.order_by([[:created_at, :desc]]).group_by do |tomato|
            date = tomato.created_at
            Time.mktime(date.year, date.month, date.day)
          end
        end
        format.html { redirect_to(root_url, :notice => 'Tomato created, now it\'s time for a break.') }
        format.xml  { render :xml => @tomato, :status => :created, :location => @tomato }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tomato.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tomatoes/1
  # PUT /tomatoes/1.xml
  def update
    @tomato = current_user.tomatoes.find(params[:id])

    respond_to do |format|
      if @tomato.update_attributes(params[:tomato])
        format.html { redirect_to(@tomato, :notice => 'Tomato was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tomato.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tomatoes/1
  # DELETE /tomatoes/1.xml
  def destroy
    @tomato = current_user.tomatoes.find(params[:id])
    @tomato.destroy

    respond_to do |format|
      format.html { redirect_to(tomatoes_url) }
      format.xml  { head :ok }
    end
  end
  
  # POST /tomatoes/track
  def track
    respond_to do |format|
      begin
        Tomato.track(params[:ids])
        format.js do
          flash.now[:notice] = 'Tomatoes successfully tracked to your Freckle account.'
        end
      rescue => e
        format.js do
          flash.now[:alert] = "Hey, something goes wrong: #{e}"
        end
      end
    end
  end
end
