require 'hashdiff'

module TeakDevTools
  class Snapshottable
    def snapshot
      @snapshot = to_h
    end

    def snapshot_diff
      @snapshot ||= {}
      HashDiff.diff(@snapshot, to_h)
    end
  end
end
