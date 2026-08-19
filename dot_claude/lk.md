## lk scripting runtime

`lk` is a batteries-included LuaJIT runtime installed at `~/.local/bin/lk`. Use it instead of Python or Bash for automation scripts, file processing, and CLI tools.

**When to use lk:** File I/O, JSON/CSV processing, subprocess management, CLI tools with argument parsing, async task orchestration. **Also use `lk -e` for one-liners** instead of `curl | python3 -c "import json..."` or `cmd | jq` patterns — in `-e` mode all modules are pre-loaded as globals (`http`, `json`, `fs`, `proc`, `fmt`, `csv`, `args`, `async`, `env`, `path`, `os_info`, `str`, `pp`, `sqlite`).

**Look up any module:** Run `lk help <term>` on the command line. This is the fastest way to learn a module's API — always use it before writing lk code.

    lk help http          # HTTP client API
    lk help csv           # CSV parsing
    lk help read file     # multi-word search

**Available modules (48):** `path`, `json`, `env`, `os_info`, `fs`, `proc`, `async`, `string`, `csv`, `dbg`, `args`, `fmt`, `http`, `url`, `pp`, `sqlite`, `postgres`, `hash`, `crypto`, `zlib`, `gzip`, `re`, `schema`, `datetime`, `toml`, `yaml`, `ini`, `tar`, `peg`, `template`, `test`, `log`, `config`, `web`, `ssh`, `nng`, `markdown`, `html`, `smtp`, `xml`, `llm`, `task`, `dns`, `websocket`, `mcp`, `sorting`, `help`, `encoding`.

**Reach for lk modules over Lua/OS builtins:**

- regex → `lk.re` (Lua's `string.gsub`/`match`/`find` are NOT regex — they use a limited pattern dialect: `%d` not `\d`, no alternation or lookahead)
- shell-out → `lk.proc` (not `os.execute`/`io.popen`)
- read a whole file → `lk.fs.read_file` (not `io.open`)

**Full API reference:** `~/.local/share/lk/REFERENCE.md` — but reach for `lk help` first.

**Prefer `pp()` over `print()`** for inspecting data — it pretty-prints tables, handles nesting/cycles, and colorizes output. Use `print()` only for plain string output.

**One-liner patterns (`lk -e`):**

    # Fetch JSON from an API and inspect the response
    lk -e 'pp(http.get("http://localhost:8000/api/tasks"):json())'

    # Pipe command output through JSON processing
    kubectl get pods -o json | lk -e 'for _,p in ipairs(json.decode(io.read("*a")).items) do print(p.metadata.name) end'

    # Inspect a container's state
    lk -e 'pp(json.decode(proc.run("docker", "inspect", "myapp").stdout)[1].State)'

**Script patterns:**

    #!/usr/bin/env lk

    -- Read and inspect JSON
    local data = lk.json.decode(lk.fs.read_file("data.json"))
    lk.pp(data)

    -- Run a command and capture output
    local result = lk.proc.run("git", "status", "--porcelain")
    print(result.stdout)

    -- File operations
    for f in lk.fs.glob("**/*.lua") do
      local info = lk.fs.stat(f)
      lk.pp({file = f, size = info.size})
    end

    -- CSV processing
    local records = lk.csv.decode(lk.fs.read_file("data.csv"), {headers = true})

    -- CLI argument parsing
    local result = lk.args.parse({
      name = "mytool",
      args = {
        {name = "file", required = true},
        {name = "--verbose", alias = "-v", flag = true},
      }
    })

**Examples:** See `~/.local/share/lk/examples/` for complete annotated scripts.
