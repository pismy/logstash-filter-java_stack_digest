# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"

# If the input event contains a Java stack trace, this filter computes a stable digest of it and adds it
# in a field of the output event
class LogStash::Filters::JavaStackDigest < LogStash::Filters::Base

  # Setting the config_name here is required. This is how you
  # configure this filter from your Logstash config.
  #
  # java_stack_digest {
  #   {
  #     source => "stack_trace"
  #   }
  # }
  #
  config_name "java_stack_digest"

  # activates debug traces
  config :debug, :validate => :boolean, :default => false

  # The name of the input field supposed to contain the Java stack trace (default 'stack_trace').
  config :source, :validate => :string, :default => "stack_trace"

  # The name of the output field to assign the computed stack trace digest (default 'stack_digest').
  config :target, :validate => :string, :default => "stack_digest"

  # Determines whether stack trace elements without source info (no filename or line number) should be excluded from the digest (default 'true')
  config :exclude_no_source, :validate => :boolean, :default => true

  # Array of regular expressions to exclude stack trace elements
  # defaults to standard dynamic classes and method invocations
  # config :excludes, :validate => :array, :default => %w["\\$\\$FastClassByCGLIB\\$\\$", "\\$\\$EnhancerBySpringCGLIB\\$\\$", "^sun\\.reflect\\..*\\.invoke", "^com\\.sun\\.", "^sun\\.net\\.", "^java\\.lang\\.reflect\\.Method\\.invoke", "^net\\.sf\\.cglib\\.proxy\\.MethodProxy\\.invoke", "^java\\.util\\.concurrent\\.ThreadPoolExecutor\\.runWorker","^java\\.lang\\.Thread\\.run$" ]
  config :excludes, :validate => :array, :default => [/\$\$FastClassByCGLIB\$\$/, /\$\$EnhancerBySpringCGLIB\$\$/, /^sun\.reflect\..*\.invoke/, /^com\.sun\./, /^sun\.net\./, /^java\.lang\.reflect\.Method\.invoke/, /^net\.sf\.cglib\.proxy\.MethodProxy\.invoke/, /^java\.util\.concurrent\.ThreadPoolExecutor\.runWorker/, /^java\.lang\.Thread\.run$/ ]

  public
  def register
    # Add instance variables

    # Regexp to capture the Error classname from the first stack trace line
    # group 1: error classname
    @error_pattern = /((?:[\w$]+\.){2,}[\w$]+):/

    # Regexp to extract stack trace elements information
    # group 1: classname+method
    # group 2: filename (optional)
    # group 3: line number (optional)
    @stack_element_pattern = /^\s+at\s+((?:[\w$]+\.){2,}[\w$]+)\((?:([^:]+)(?::(\d+))?)?\)/

    # coerce excludes to an array of Regexp
    @excludes = @excludes.collect {|pattern| Regexp::new(pattern)}
  end # def register

  public
  def filter(event)

    stack_trace = event.get(@source)

    return if stack_trace.nil? || stack_trace.empty?

    event.set(@target, compute_digest(stack_trace.split("\n"), 0))

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter

  # computes a Java stack trace digest
  def compute_digest(stack_trace, level)

    # 1: extract error class from first line
    error_class = @error_pattern.match(stack_trace.shift)
    puts "Error (#{level}) #{error_class}:" if @debug
    md5 = Digest::MD5.new
    # digest: error classname
    md5.update error_class[1]

    # 2: read all stack trace elements until stack trace is empty or we hit the next error
    ste_count = 0
    while not stack_trace.empty?
      if stack_trace.first.start_with?(' ') or stack_trace.first.start_with?("\t")
        # current line starts with a whitespace: is it a stack trace element ?
        stack_element = @stack_element_pattern.match(stack_trace.first)
        if stack_element
          # current line is a stack trace element
          ste_count+=1
          if is_excluded?(stack_element)
            puts "  (-) at #{stack_element[1]}(#{stack_element[2]}:#{stack_element[3]})" if @debug
          else
            puts "  (+) at #{stack_element[1]}(#{stack_element[2]}:#{stack_element[3]})" if @debug
            # digest: STE classname and method
            md5.update stack_element[1]
            # digest: line number (if present)
            if not (stack_element[3].nil? or stack_element[3].empty?)
              md5.update stack_element[3]
            end
          end
        end
      elsif(ste_count > 0)
        # current line doesn't start with a whitespace and we've already read stack trace elements: is it the next error in the stack
        break
      end
      # move to next line
      stack_trace.shift
    end

    # 3: if stack trace not empty, compute digest for next error
    if not stack_trace.empty?
      md5.update compute_digest(stack_trace, level+1)
    end

    return md5.hexdigest
  end

  def is_excluded?(stack_element)
    # 1: exclude elements without source info ?
    if @exclude_no_source and (stack_element[2].nil? or stack_element[2].empty?) and (stack_element[3].nil? or stack_element[3].empty?)
      return true
    end
    # 2: Regex based exclusion
    @excludes.each do |pattern|
      if pattern.match(stack_element[1])
        return true
      end
    end
    return false
  end

end # class LogStash::Filters::JavaStackDigest
