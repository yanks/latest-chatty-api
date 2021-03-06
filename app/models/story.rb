class Story
  attr_reader :id, :name, :date, :preview, :body, :comment_count
  
  def self.all
    url = "http://www.shacknews.com/"
    
    # get stories
    page = Downloader.parse_url(url)
    
    news = page.find_first('.//div[contains(@class, "news")]')
    
    news.find('div[contains(@class, "story")]').collect do |story_element|
      returning Story.new do |story|
        story.parse_html story_element.to_s
      end
    end
  end
  
  def initialize(story_id = nil)
    if story_id
      url = "http://www.shacknews.com/onearticle.x/#{story_id}"
      parse_html Downloader.get(url).clean_html
    end
  end
  
  def parse_html(html)
    page = Downloader.parse_string(html)
    
    story = page.find_first('.//div[contains(@class, "story")]')
    
    if story
      @id   = story.find_first('h1//a').attributes[:href].split('/').last.to_i
      @name = story.find_first('h1//a').content
      @date = Time.parse(story.find_first('.//span[contains(@class, "date")]').to_s.inner_html.strip)
    
      @body = story.find_first('div[contains(@class, "body")]').to_s.inner_html.gsub('&#13;', '').strip
      @body.gsub! /<a.+?Read more<\/a>/, ''
      @body.gsub! '...', ''
      @body.strip!
    
      @preview = @body.gsub(/<.+?>/, '')
      @comment_count = page.find_first('//span[contains(@class, "commentcount")]').content.to_i
    end
  end
  
  def attributes
    {
      :id             => id,
      :name           => name,
      :preview        => preview,
      :date           => date,
      :body           => body,
      :comment_count  => comment_count
    }
  end
  
  def to_json(options = {})
    attributes.to_json(options)
  end
  
  def to_xml(options = {})
    attributes.to_xml({ :root => 'story' }.merge(options))
  end
end