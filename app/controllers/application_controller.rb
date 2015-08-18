class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :logged_in_user, only: [:start, :show, :move, :newap, :removeap]

  include SessionsHelper
  include ApplicationHelper

  def start
    # logged in home page
    @sites = Site.order(:name)
    @site_text = nil
    render "main"
  end

  def show
    # show map and APs for site chosen from dropdown menu
    # also set up a bunch of variables used by the view
    @sites = Site.order(:name)
    @site_uuid = params[:site_select]
    unless @sites.pluck(:uuid).include?(@site_uuid)
      return redirect_to '/404.html'
    end
    # switch view based on dropdown value
    @site_text = @sites.find(@site_uuid).name
    site_path = "/images/maps/#{@site_uuid}"
    # create maps directory if it does not exist yet
    Dir.mkdir "./public#{site_path}" if !Dir.exist? "./public#{site_path}"
    @site_img = nil
    files = Dir.entries("./public#{site_path}").reject {|f| f[/^\./]}
    unless files.empty?
      filename = files.max_by {|f| f.gsub(/-.*/, "").to_i}
      @site_img = "#{site_path}/#{filename}"
      @site_x, @site_y = FastImage.size("./public#{@site_img}")
    end

    unless @site_img.nil?
      # [hostname, weburl, jsonurl, shortname, x_pos, y_pos]
      @aps_not_added, @aps_added = nil
      ap_arrs = Ap.where(site: @site_uuid).pluck(:hostname, :weburl, :jsonurl, :name, :x_pos, :y_pos)
      # make requests for all ap info at once
      conn_threads = []
      ap_arrs.each do |ap|
        conn_threads << Thread.new { ap_config(ap) }
      end
      conn_threads.each(&:join) # wait for threads to finish
      @ap_names = ap_arrs.map {|x| x[3]}
      @ap_hosts = ap_arrs.map {|x| x[0]}
      @site_names = @sites.pluck(:comment)
      @site_abbrevs = @sites.pluck(:name)
      @aps_not_added, @aps_added = ap_arrs.partition { |ap| ap[4].nil? and ap[5].nil? }
    end

    render 'main'
  end

  def move
    # send realtime drag and drop information to database
    hostname = params["coords"]["id"]
    ap_to_update = Ap.where(hostname: hostname)
    ap_to_update.update_all(x_pos: params["coords"]["x_pos"], y_pos: params["coords"]["y_pos"])
    render nothing: true
  end

  def upload
    # upload image file as site map
    @sites = Site.all
    site_to_update = @sites.where(uuid: params[:site])
    Site.update(params[:site], map: params[:map])

    redirect_to :back
  end

  private
    def logged_in_user
      # before_action: check if user is logged in
      unless logged_in?
        flash[:danger] = "You need to log in to access this page."
        redirect_to '/login'
      end
    end
    
end