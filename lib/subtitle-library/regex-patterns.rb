module Patterns
  SUB_RIP_TIMING = /\d{1,2}:\d{1,2}:\d{1,2},\d{1,3}/
  SUB_RIP_LINE = /\s*#{SUB_RIP_TIMING}[ \t\r\f\v]?\-\->[ \t\r\f\v]?#{SUB_RIP_TIMING}$/
  MICRO_DVD_LINE = /\s*\{\d+\}( |\t)?\{\d+\}( |\t)?(\{(y|Y):[ibus]{1,4}\})?(\{C:$[0-9a-fA-F]{6}\})?/
  SUBVIEWER_LINE = /\s*\d{1,2}:\d{1,2}:\d{1,2}\.\d{1,3},\d{1,2}:\d{1,2}:\d{1,2}\.\d{1,3}$/
  SUBVIEWER_METADATA = /(\[information\](\[title\][^\[]+)?(\[author\][^\[]+)?(\[source\][^\[]+)?(\[filepath\][^\[]+)?(\[delay\][ \t\r\f\v]*\d+[ \t\r\f\v]*)?(\[comment\][^\[]+)?\[end information\])?((\[subtitle\])?(\[colf\]&[0-9a-fA-F]{6,6})?(\[style\][^\[]+)?(\[size\][ \t\r\f\v]*\d+[ \t\r\f\v]*)?(\[font\][^\[]+)?)?$/i
end

