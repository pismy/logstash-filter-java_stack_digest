function StackDigester(exclude_no_source, inclusion_patterns, exclusion_patterns) {
    // Regexp to capture the Error classname from the first stack trace line
    // group 1: error classname
    this.error_pattern = /((?:[\w$]+\.){2,}[\w$]+):/

    // Regexp to extract stack trace elements information
    // group 1: classname+method
    // group 2: filename (optional)
    // group 3: line number (optional)
    this.stack_element_pattern = /^\s+at\s+((?:[\w$]+\.){2,}[\w$]+)\((?:([^:]+)(?::(\d+))?)?\)/

    this.exclude_no_source = exclude_no_source;

    this.inclusion_patterns = inclusion_patterns;

    this.exclusion_patterns = exclusion_patterns;

    this.compute = function(stack_trace, debugged_stack) {
        var digest = md5.create();

        // 1: extract error class from first line
        var cur_stack_trace_line = stack_trace.shift();
        var error_class = cur_stack_trace_line.match(this.error_pattern);

        // populate debugged stack
        var highlighted_line = cur_stack_trace_line.replace(this.error_pattern, "<span class='error-class' title='Error class'>$1</span>:");
        debugged_stack.push("<div class='line error'><span class='marker' title='Stack error'>E</span>" + highlighted_line+"</div>");

        // digest: error classname
        digest.update(error_class[1]);

        // 2: read all stack trace elements until stack trace is empty or we hit the next error
        var ste_count = 0;
        while (stack_trace.length > 0) {
            cur_stack_trace_line = stack_trace[0];
            if (cur_stack_trace_line.startsWith(' ') || cur_stack_trace_line.startsWith('\t')) {
                // current line starts with a whitespace: is it a stack trace element ?
                var stack_element = cur_stack_trace_line.match(this.stack_element_pattern);
                if (stack_element) {
                    // current line is a stack trace element
                    ste_count += 1;
                    var excluded = this.is_excluded(stack_element);
                    if (!excluded) {
                        // digest: STE classname and method
                        digest.update(stack_element[1]);
                        // digest: line number (if present)
                        if (stack_element[3]) {
                            digest.update(stack_element[3]);
                        }
                    }
                    // populate debugged stack
                    var highlighted_line = cur_stack_trace_line.replace(this.stack_element_pattern, function(match, classname_and_method, file, line) {
                        var fileAndLine = file ? "<span class='file' title='File'>" + file + "</span>" + (line ? ":<span class='ln' title='Line'>" + line + "</span>" : "") : "";
                        return "\tat <span class='classname-and-method' title='Classname and method'>" + classname_and_method + "</span>(" + fileAndLine + ")";
                    });
                    if(excluded) {
                        debugged_stack.push("<div class='line excluded ste'><span class='marker' title='"+excluded+"'>-</span>" + highlighted_line + "</div>");
                    } else {
                        debugged_stack.push("<div class='line match ste'><span class='marker'>+</span>" + highlighted_line + "</div>");
                    }
                } else {
                    debugged_stack.push("<div class='line ignored'><span class='marker'>?</span>" + cur_stack_trace_line + "</div>");
                }
            } else if (ste_count > 0) {
                // current line doesn't start with a whitespace and we've already read stack trace elements: it looks like the next error in the stack
                break
            } else {
                // current line doesn't start with a whitespace and we've not read any stack trace element yet: it looks like a wrapping error message
                debugged_stack.push("<div class='line ignored'><span class='marker'>?</span>" + cur_stack_trace_line+"</div>");
            }
            // move to next line
            stack_trace.shift();
        }

        // 3: if stack trace not empty, compute digest for next error
        if (stack_trace.length > 1) {
            digest.update(this.compute(stack_trace, debugged_stack));
        }

        return digest.hex();
    }

    // Determines whether the given stack trace element (Regexp match) should be excluded from digest computation
    this.is_excluded = function(stack_element) {
        // 1: exclude elements without source info ?
        var lineNb = stack_element[3];
        if (this.exclude_no_source && !lineNb) {
            return "no source info";
        }
        var classnameAndMethod = stack_element[1];
        // 2: Regex based inclusion
        if(this.inclusion_patterns.length > 0) {
            var includedBy = this.inclusion_patterns.find(function (pattern) {
                return classnameAndMethod.match(pattern);
            });
            if(!includedBy) {
                return "not matching any inclusion pattern"
            }
        }
        // 3: Regex based exclusion
        var excludedBy = this.exclusion_patterns.find(function (pattern) {
            return classnameAndMethod.match(pattern);
        });
        return excludedBy ? "excluded by "+excludedBy.toString() : null;
    }
}