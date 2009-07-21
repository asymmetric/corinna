module ActiveTreasureHunt

  XMLError = Class.new Exception

  class NotWellFormed < XMLError
    def to_s
      "XML not well-formed"
    end
  end
  class NotValid < XMLError
    def to_s
      "XML not valid"
    end
  end
  class WrongPass < XMLError
    def to_s
      "Wrong password"
    end
  end
  class NoPermission < XMLError
    def to_s
      "Insufficient privileges"
    end
  end
  class PassAlreadyAssigned < XMLError
    def to_s
      "Password already assigned"
    end
  end
  class NotSubscribed < XMLError
    def to_s
      "You are not subscribed to this treasure hunt or it hasn't started yet"
    end
  end
  class NotExist < XMLError
    def to_s
      "Treasure hunt does not exist or it has ended"
    end
  end
  class AlreadyStarted < XMLError
    def to_s
      "Treasure hunt already started"
    end
  end
  class OutOfBound < XMLError
    def to_s
      "Max allowed fake hints limit reached"
    end
  end
  class NoTransparency < XMLError
    def to_s
      "Treasure hunt not transparent"
    end
  end
  class NoTurn < XMLError
    def to_s
      "Turn does not exist"
    end
  end
  class AlreadySubscribed < XMLError
    def to_s
      "Already subscribed"
    end
  end
end
