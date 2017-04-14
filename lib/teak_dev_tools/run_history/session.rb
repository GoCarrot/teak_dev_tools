require 'date'
require 'json'

module TeakDevTools
  class RunHistory::Session < Snapshottable
    attr_reader :id, :state_transitions, :user_id, :heartbeats, :requests, :attribution_payload

    class Event < EventStream::Event
      def initialize(action, description, delta)
        super(:teak_session, action, description, delta, [:id, :current_state, :start_date, :user_id, :attribution_payload])
      end
    end

    def initialize(id, start_date)
      @id = id
      @user_id = nil
      @start_date = start_date
      @state_transitions = [[nil, "Allocated"]]
      @heartbeats = []
      @requests = {}
      @attribution_payload = nil
    end

    def current_state
      @state_transitions.last.last
    end

    def attach_request(id, json, event_stream)
      raise "Duplicate request created #{id}" unless not @requests.has_key?(id)
      @requests[id] = {
        request: json,
        reply: nil
      }

      if json["endpoint"].match(/\/games\/(?:\d+)\/users\.json/)
        snapshot
        if @attribution_payload == nil
          raise "Attribution payload contains 'do_not_track_event'" unless not json["payload"].has_key?("do_not_track_event")
          @attribution_payload = json["payload"]
          event_stream = event_stream << Event.new(:attribution, "Session Attribution", snapshot_diff)
        else
          raise "Additional payload does not specify 'do_not_track_event'" unless json["payload"].has_key?("do_not_track_event")
          event_stream = event_stream << Event.new(:update, "User Data Update", snapshot_diff)
        end
      end
      event_stream
    end

    def attach_reply(id, json, event_stream)
      raise "Reply for non-existent request #{id}" unless @requests.has_key?(id)
      raise "Duplicate reply created #{id}" unless @requests[id][:reply] == nil
      @requests[id][:reply] = json
      event_stream
    end

    def self.new_event(event, current_session, sessions, event_stream)
      case event
      when /^io.teak.sdk.Session@([a-fA-F0-9]+)\: (.*)/
        json = JSON.parse($2)
        current_session = self.new($1, DateTime.strptime(json["startDate"].to_s,'%s'))
        event_stream << Event.new(:initalized, "Session Created", current_session.snapshot_diff)
      when /^State@([a-fA-F0-9]+)\: (.*)/
        session = sessions.find { |s| s.id == $1 }
        raise "State transition for non-existent session" unless session != nil
        event_stream = session.on_new_state(JSON.parse($2), event_stream)
      when /^Heartbeat@([a-fA-F0-9]+)\: (.*)/
        raise "Heartbeat for nil session" unless current_session != nil
        raise "Heartbeat for non-current session" unless current_session.id == $1
        json = JSON.parse($2)
        #raise "Heartbeat for different userId than current" unless current_session.user_id == json["userId"]
        current_session.heartbeats << DateTime.strptime(json["timestamp"].to_s,'%s')
      when /^IdentifyUser@([a-fA-F0-9]+)\: (.*)/
        #IdentifyUser@ddff9ae: {"userId":"demo-app-thingy-3","timezone":"-7.00","locale":"en_US"}
      else
        puts "Unrecognized Teak.Session event: #{event}"
      end
      [current_session, event_stream]
    end

    def on_new_state(json, event_stream)
      snapshot
      raise "State transition consistency failed" unless current_state == json["previousState"]
      @state_transitions << [json["previousState"], json["state"]]
      event_stream << Event.new(:state_change, "State Transition", snapshot_diff)
    end

    def to_h
      {
        id: @id,
        current_state: current_state,
        state_transitions: @state_transitions,
        user_id: @user_id,
        start_date: @start_date,
        attribution_payload: @attribution_payload
      }
    end
  end
end
