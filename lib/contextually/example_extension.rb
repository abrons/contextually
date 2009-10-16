module Contextually
  module ExampleExtension
    def only_as(*args, &block)
      as(*args, &block)
      roles, params = extract_params(args)
      deny_params = Contextually.roles.keys - roles
      deny_params.push(params)
      deny_access_to(*deny_params)
    end
  
    def as(*args, &block)
      roles, params = extract_params(args)
      roles.each do |role|
        context "as #{role}" do
          before(&Contextually.before(role))
          describe(params.dup, &block)
        end
      end
    end
  
    def deny_access_to(*args)
      roles, params = extract_params(args)
      roles.each do |role|
        block = Contextually.deny_access(role)
        if block
          context "as #{role}" do
            before(&Contextually.before(role))
            describe(params.dup, &block)
          end
        else
          raise Contextually::UndefinedContext, "don't know how to deny access to a #{role}"
        end
      end
    end
  
  private

    def extract_params(args)
      if args.blank? or args.last.is_a?(Symbol) 
        params = ""
      else
        params = args.pop
      end
      args = args.inject([]) { |array, role| array.push(*Contextually.groups[role] || role); array }
      return args, params
    end

  end
end

Spec::Rails::Example::ControllerExampleGroup.send(:extend, Contextually::ExampleExtension) if defined?(Spec)