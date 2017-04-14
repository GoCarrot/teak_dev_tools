require 'json'

module TeakDevTools
  class EventStream
    attr_reader :events

    def initialize
      @events = []
    end

    def << (event)
      @events << event
      self
    end

    def to_a
      @events
    end

    def to_s
      return nil if @events.empty?
      @events.map { |event|  event.to_s }.join("\n")
    end

    class Event
      attr_reader :component, :action, :description, :delta

      def initialize(component, action, description, delta, human_readable_keys)
        @component = component
        @action = action
        @description = description
        @delta = delta
        @human_readable_keys = human_readable_keys.map { |key| key.to_s }
      end

      def to_s
        human_readable_deltas = @delta == nil ? [] : @delta.reject { |delta| !@human_readable_keys.include?(delta[1]) }
        return @description if human_readable_deltas.empty?

"""#{@description}
#{human_readable_deltas.map { |delta|
  case delta[0]
  when "~"
    if delta[2] == nil
      if delta[3].is_a? String
        "#{delta[1]} assigned '#{delta[3]}'"
      else
        "#{delta[1]} assigned {\n#{JSON.pretty_generate(delta[3]).lines.slice(1..-1).map { |line| line.insert(0, "  ") }.join}"
      end
    else
      if delta[3].is_a? String
        "#{delta[1]} changed from '#{delta[2]}' to '#{delta[3]}'"
      else
         "#{delta[1]} changed from {\n#{JSON.pretty_generate(delta[2]).lines.slice(1..-1).map { |line| line.insert(0, "  ") }.join}\nto {\n#{JSON.pretty_generate(delta[3]).lines.slice(1..-1).map { |line| line.insert(0, "  ") }.join}"
      end
    end
  when "+"
    "#{delta[1]} assigned '#{delta[2]}'"
  else
    JSON.pretty_generate(delta)
  end
}.join("\n  ")}"""
      end
    end
  end
end
