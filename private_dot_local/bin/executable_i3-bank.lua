#!/usr/bin/env lk
-- i3-bank.lua — workspace bank switcher for i3
--
-- A "bank" is a named set of 10 workspaces. Each workspace is named
-- "<bank>:<n>" (e.g. "koala:1", "chimera:7"). State lives at
-- ~/.local/state/i3/banks.json: { current, previous, last = {bank=n, ...} }.
--
-- Subcommands:
--   go <N>          switch to workspace N in current bank (records as last)
--   move <N>        move focused container to workspace N in current bank
--   bank <NAME>     switch to bank NAME, restoring its last-visited workspace
--   bank previous   swap to the bank we were on before the current one

local json = require("lk.json")
local fs   = require("lk.fs")
local proc = require("lk.proc")
local path = require("lk.path")

local STATE = path.join(os.getenv("HOME"), ".local/state/i3/banks.json")

-- Bank order determines the numeric prefix on workspace names so that i3
-- sorts them as koala:1..10, chimera:1..10, axolotl:1..10 in the bar.
-- Adding a bank? Append it here and add a binding in i3 mode "bank".
local BANKS = { "koala", "chimera", "axolotl" }

local function load_state()
  local raw = fs.read_file(STATE)
  if not raw then return { current = BANKS[1], previous = BANKS[1], last = {} } end
  return json.decode(raw)
end

local function save_state(s)
  fs.mkdir_p(path.dirname(STATE))
  fs.write_file(STATE, json.encode(s))
end

-- Workspace name format: "<sort_idx>:<bank>:<n>". The leading integer drives
-- i3's workspace sort order; `strip_workspace_numbers yes` hides it in the bar.
local function ws(bank, n)
  local bi = 0
  for i, b in ipairs(BANKS) do if b == bank then bi = i - 1 break end end
  return (bi * 10 + tonumber(n)) .. ":" .. bank .. ":" .. n
end

local cmd, val = arg[1], arg[2]
local s = load_state()

if cmd == "go" then
  local n = tonumber(val)
  s.last[s.current] = n
  save_state(s)
  proc.run("i3-msg", "workspace", ws(s.current, n))

elseif cmd == "move" then
  proc.run("i3-msg", "move", "container", "to", "workspace", ws(s.current, val))

elseif cmd == "bank" then
  local target = (val == "previous") and s.previous or val
  if target ~= s.current then
    s.previous = s.current
    s.current  = target
  end
  save_state(s)
  proc.run("i3-msg", "workspace", ws(target, s.last[target] or 1))

else
  io.stderr:write("usage: i3-bank.lua {go N | move N | bank NAME|previous}\n")
  os.exit(2)
end
