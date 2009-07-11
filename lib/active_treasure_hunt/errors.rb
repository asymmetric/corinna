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
      "You don't have enough permissions"
    end
  end
  class PassAlreadyAssigned < Exception
    def to_s
      "Password already assigned (it doesn't make any sense, but it is)"
    end
  end
  class NotSubscribed < Exception
    def to_s
      "You are not subscribed to this treasure hunt"
    end
  end
  class NotExist < Exception
    def to_s
      "Treasure hunt doesn't exists"
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
      "Treasure hunt is not transparent"
    end
  end
  class NoTurn < Exception
    def to_s
      "Turn doesn't exists"
    end
  end
end
