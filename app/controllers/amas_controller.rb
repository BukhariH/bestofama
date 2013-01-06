class AmasController < ApplicationController
  layout 'public'

  def index
    @order = params[:order]
    @order ||= 'date'
    params[:page] ||= 1
    @amas = Ama.where('responses > ?', 0).order(@order).reverse_order.paginate(:page => params[:page], :per_page => 25)

    respond_to do |format|
      format.html
    end
  end

  def show
    @ama = Ama.find_by_key(params[:key])
    @users = @ama.users

    respond_to do |format|
      format.html
    end
  end

  def new
    @ama = Ama.new

    respond_to do |format|
      format.html
    end
  end

  def create
    if params[:ama_url] != ''
      require 'api/reddit'
      ama_key = params[:ama_url].match('\/comments\/([a-z0-9]{5,6})\/')[1]
      @ama = Reddit.create_ama(ama_key)

      respond_to do |format|
        if @ama.save
          format.html { redirect_to ama_full_path(:username => @ama.user.username, :key => @ama.key, :slug => @ama.title.parameterize), :notice => "Thank you for your submission, this AMA has now been put in the process queue." }
        else
          format.html { redirect_to submit_path, :notice => "Internal error, AMA was unable to save." }
        end
      end
    else
      redirect_to submit_path, :notice => "No url provided"
    end
  end
end
