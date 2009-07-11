module ActiveTreasureHunt
  module XMLErrors
    NotWellFormed = Class.new ActiveResource::ClientError
    NotValid = Class.new ActiveResource::ClientError
  end
  module PermissionErrors
    WrongPass = Class.new ActiveResource::ClientError
    NoPermission = Class.new ActiveResource::ClientError
    PassAlreadyAssigned = Class.new ActiveResource::ClientError
    NotSubscribed = Class.new ActiveResource::ClientError
  end
  module HuntErrors
    NotExist = Class.new ActiveResource::ClientError
    AlreadyStarted = Class.new ActiveResource::ClientError
    OutOfBound = Class.new ActiveResource::ClientError
    NoTransparency = Class.new ActiveResource::ClientError
    NoTurn = Class.new ActiveResource::ClientError
  end
end
