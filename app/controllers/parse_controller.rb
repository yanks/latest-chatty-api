class ParseController < ApplicationController
  # def full
  #   @feed = Feed.new(:story_id => params[:id])
  #   render :action => 'index'
  # end
  
  def index
    Feed.work_safe = request.subdomains.include?('ws')
    @feed = Feed.new(:story_id => params[:id], :page => params[:page], :parse_children => false)
  end
  
  def thread
    @feed = Feed.new(:root_id => params[:id], :parse_children => true)
    
    if @feed.posts.empty?
      page = Downloader.parse_url("http://www.shacknews.com/laryn.x?id=#{params[:id]}")

      root_id = page.find_first('//div[@class="root"]')[:id].gsub('root_', '').to_i
      @feed = Feed.new(:root_id => root_id, :parse_children => true)
    end
    
    render :action => 'index'
  end
end
