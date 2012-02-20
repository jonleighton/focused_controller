class Post
  extend ActiveModel::Naming
  include ActiveModel::Validations

  class << self
    def posts
      POSTS
    end
    private :posts

    def all
      posts.compact
    end

    def create(attrs = {})
      post = new(attrs)
      post.save
      post
    end

    def persist(post)
      id = posts.length
      posts << post
      id
    end

    def unpersist(post)
      posts[post.id] = nil
    end

    def find(id)
      posts[id.to_i] or raise "not found"
    end

    def count
      posts.compact.length
    end
  end

  attr_reader :id
  attr_accessor :title, :body

  def initialize(attrs = {})
    self.attributes = attrs
  end

  def attributes=(attrs)
    return unless attrs
    attrs.each { |k, v| send("#{k}=", v) }
  end

  def attributes
    { 'title' => title, 'body' => body }
  end

  def to_model
    self
  end

  def to_param
    id.to_s
  end

  def to_key
    [id] if id
  end

  def persisted?
    !id.nil?
  end

  def save
    unless persisted?
      @id = self.class.persist(self)
    end
    true
  end

  def update_attributes(attrs)
    self.attributes = attrs
    save
  end

  def destroy
    self.class.unpersist(self)
    true
  end
end
