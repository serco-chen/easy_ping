module EasyPing
  module Utils
    # turn symbol keys to string keys, shallow mode
    def indifferent_hash(hash)
      Hash[hash.map {|k, v| Symbol === k ? [k.to_s, v] : [k, v] }]
    end

    def indifferent_params(args, *names)
      params = args.pop
      if params
        if Hash === params
          params = indifferent_hash(params)
        else
          args.push(params)
          params = {}
        end
        args.zip(names) {|arg, name| params.merge!(name => arg) if arg }
      else
        raise ArgumentError, "wrong number of arguments (0 for at least 1)"
      end

      params
    end

  end
end
