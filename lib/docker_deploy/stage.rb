module DockerDeploy
  class Stage
    attr_reader :name, :servers, :variables

    def initialize(context, name)
      @context = context
      @name = name
      @servers = []
      @variables = {}
      @ports = {}
      @deploy = ["docker:build", "docker:push", :pull, :restart]
    end

    def env(variables = {})
      @variables.merge!(variables)
    end

    def port(ports = {})
      @ports.merge!(ports)
    end

    def deploy(sequence = nil)
      @deploy = sequence if sequence
      @deploy
    end

    def host(name = nil)
      @host = name if name
      @host
    end

    def server(server)
      @servers << SSHKit::Host.new(server)
    end

    def mappings
      @context.ports.merge(@ports).each_with_object("") do |(from, to), s|
        s << " -p %d:%d " % [from, to]
      end
    end

    def options
      @context.variables.merge(@variables).each_with_object("") do |(k, v), s|
        s << " -e %s=%s " % [Shellwords.escape(k), Shellwords.escape(v)] if v.present?
      end
    end
  end
end
