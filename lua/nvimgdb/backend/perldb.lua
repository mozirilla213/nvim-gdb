-- Perl5DB specifics
-- vim: set et ts=2 sw=2:

local log = require'nvimgdb.log'
local Common = require'nvimgdb.backend.common'
local ParserImpl = require'nvimgdb.parser_impl'

-- @class BackendPerldb:Backend @specifics of PerlDB
local C = {}
C.__index = C
setmetatable(C, {__index = Common})

-- @return BackendPerldb @new instance
function C.new()
  local self = setmetatable({}, C)
  return self
end

-- Create a parser to recognize state changes and code jumps
-- @param actions ParserActions @callbacks for the parser
-- @return ParserImpl @new parser instance
function C.create_parser(actions)
  local P = {}
  P.__index = P
  setmetatable(P, {__index = ParserImpl})

  local self = setmetatable({}, P)
  self:_init(actions)

  local re_prompt = '[\r\n]  DB<%(?%d+%)?> $'
  local re_term = '[\r\n]Debugged program terminated.'

  function P:_handle_terminated(_)
    self.actions:continue_program()
    return self.paused
  end

  self.add_trans(self.paused, re_term, self._handle_terminated)
  -- Make sure the prompt is matched in the last turn to exhaust
  -- every other possibility while parsing delayed.
  self.add_trans(self.paused, re_prompt, self._query_b)

  -- Let's start the backend in the running state for the tests
  -- to be able to determine when the launch finished.
  -- It'll transition to the paused state once and will remain there.

  function P:_running_jump(fname, line)
    log.info("_running_jump " .. fname .. ":" .. line)
    self.actions:jump_to_source(fname, tonumber(line))
    return self.running
  end

  self.add_trans(self.running, re_prompt, self._query_b)
  self.state = self.running

  return self
end

-- @param fname string @full path to the source
-- @param proxy Proxy @connection to the side channel
-- @return FileBreakpoints @collection of actual breakpoints
function C.query_breakpoints(fname, proxy)
  log.info("Query breakpoints for " .. fname)

  --local response = proxy:query('handle-command L')

  --main.pl:
  --8:		subroutine1();
  --break if (1)

  if response == nil or response == "" then
    return {}
  end

  return breaks

end

-- @type CommandMap
C.command_map = {
  delete_breakpoints = 'B',
  breakpoint = 'b',
  ['info breakpoints'] = 'L',
}

-- @return string[]
function C.get_error_formats()
  return {[[%f:[\r\n]%l:\t\t%m]], [[%m = %m \'%f\' line %l]]}

  -- . = DB::END() called from file 'main.pl' line 0
end

return C
