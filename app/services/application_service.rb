# ApplicationService is an abstract base class intended to be
# inherited by other service classes to provide a consistent
# interface for service object invocation. This class leverages
# the common design pattern of service objects, which encapsulate
# business logic that doesn't naturally fit within the boundaries
# of other domain objects like models or controllers.
#
# The `call` class method provides a universal interface to
# execute the main action of the service, allowing instances of
# the service to be called just like a function, improving readability
# and usage simplicity.
#
# Usage:
#   To use ApplicationService, create a new service class that
#   inherits from it and implement your own `call` instance method.
#   The `call` class method defined in the ApplicationService will
#   automatically instantiate your service object and call its `call`
#   method with any provided arguments.
#
# Example:
#   ```ruby
#   class MyService < ApplicationService
#     def initialize(param)
#       @param = param
#     end
#
#     def call
#       # Your business logic here
#       puts @param
#     end
#   end
#
#   MyService.call("Hello, World!")
#   ```
#
class ApplicationService
  # Creates a new instance of the service class and calls its
  # `call` method with the provided arguments. This method is
  # intended to be overridden in each subclass to implement specific
  # service logic.
  #
  # @param args [Array] arguments passed through to the service instance
  # @param block [Proc] optional block passed through to the service instance
  # @return [Object] the result of the service instance's `call` method
  def self.call(*args, &block)
    new(*args, &block).call
  end
end
