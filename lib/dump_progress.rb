require 'json'
require_relative 'msg_id'

class DumpProgress

  attr_reader :newest_id
  attr_reader :newest_date
  attr_reader :dumper_state
  attr_writer :dumper_state
  attr_reader :counts

  def initialize(newest_id = nil, newest_date = nil,
                 dumper_state = {}, counts = {})
    @newest_id = (newest_id.to_s.empty?) ? nil : MsgId.new(newest_id)
    @newest_date = newest_date
    @dumper_state = dumper_state
    @counts = counts
  end

  def self.from_hash(hash)
    self.new(
      hash['newest_id'],
      hash['newest_date'],
      hash['dumper_state'],
      hash['counts']
    )
  end

  def to_hash
    {
      :newest_id => @newest_id.to_s,
      :newest_date => @newest_date,
      :dumper_state => @dumper_state,
      :counts => @counts
    }
  end

  def to_json(*a)
    to_hash.to_json(*a)
  end

  def update(msg)
    @counts['total'] = 0 unless @counts['total']
    @counts['total'] += 1
    if msg && !msg['event'].to_s.empty?
      event_type = msg['event']
      @counts[event_type] = 0 unless @counts[event_type]
      @counts[event_type] += 1
    end

    msg_id = (msg['id'].to_s.empty?) ? nil : MsgId.new(msg['id'])
    if msg_id && (!@newest_id || msg_id > @newest_id)
      @newest_id = msg_id
      @newest_date = msg['date'] || @newest_date
    end
  end

end
