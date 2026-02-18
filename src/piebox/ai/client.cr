module Piebox
  module AI
    abstract class Client
      abstract def generate(prompt : String) : String
    end
  end
end
