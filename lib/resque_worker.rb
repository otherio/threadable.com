class ResqueWorker < MethodObject

  class << self

    def perform *args
      call *JSON.parse(args.to_json)
      nil
    end

    private :call

    def queue queue=nil
      @queue = queue.to_sym unless queue.nil?
      @queue
    end

    def enqueue *args
      ::Resque.enqueue self, *args
    end

  end

end
