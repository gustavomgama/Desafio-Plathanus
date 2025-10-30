RSpec::Matchers.define :make_database_queries do |options = {}|
  supports_block_expectations

  match do |block|
    query_count = 0
    callback = lambda do |*args|
      query_count += 1 unless args.last[:name] == 'SCHEMA'
    end

    ActiveSupport::Notifications.subscribed(callback, 'sql.active_record', &block)
    @query_count = query_count

    if options[:count]
      query_count == options[:count]
    else
      query_count > 0
    end
  end

  failure_message do |block|
    "expected block to make #{options[:count] || 'some'} database queries, but made #{@query_count}"
  end

  failure_message_when_negated do |block|
    "expected block not to make database queries, but made #{@query_count}"
  end

  description do
    "make #{options[:count] || 'some'} database queries"
  end
end
