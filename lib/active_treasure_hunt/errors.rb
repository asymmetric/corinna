module ActiveTreasureHunt
  class NotWellFormed < Exception
    def to_s
      "XML not well-formed"
    end
  end
  class NotValid < Exception
    def to_s
      "XML not valid"
    end
  end
  class WrongPass < Exception
    def to_s
      "Wrong password"
    end
  end
  class NoPermission < Exception
    def to_s
      "Insufficient privileges"
    end
  end
  class PassAlreadyAssigned < Exception
    def to_s
      "Password already assigned"
    end
  end
  class NotSubscribed < Exception
    def to_s
      "You are not subscribed to this treasure hunt"
    end
  end
  class NotExist < Exception
    def to_s
      "Treasure hunt does not exist"
    end
  end
  class AlreadyStarted < Exception
    def to_s
      "Treasure hunt already started"
    end
  end
  class OutOfBound < Exception
    def to_s
      "Max allowed fake hints limit reached"
    end
  end
  class NoTransparency < Exception
    def to_s
      "Treasure hunt not transparent"
    end
  end
  class NoTurn < Exception
    def to_s
      "Turn does not exist"
    end
  end
end
