class TreasureHunt
  class << self
    def create(xml)
      self.new(xml)
    end

    def find(*arguments)
      scope   = arguments.slice!(0)
      options = arguments.slice!(0) || {}

      case scope
      when :all   then find_every(options)
      when :first then find_every(options).first
      when :last  then find_every(options).last
      when :one   then find_one(options)
      else             find_single(scope, options)
      end
    end

    def delete(id)
    end

    def exists?(id)
    end

    private
    def find_every(options)
    end

    def find_one(options)
    end

    def find_single(scope, options)
    end
  end

  include HTTParty
  base_uri 'xanadu.doesntexist.com/stanis'
  format :xml

  def initialize(xml)
  end

  def id
    attributes[self.class.primary_key]
  end

  def id=(id)
    attributes[self.class.primary_key] = id
  end

  def new?
    id.nil?
  end

  def save
    new? ? create : update
  end
  
  def destroy
  end

  protected

  def create
  end

  def update
  end
end
