-- Docker-based Ruby development configuration
-- Enhances existing LSP with Docker container execution for Ruby projects

local M = {}

-- Project configurations (can be overridden by .nvim-docker.lua in project root)
local DEFAULT_CONFIGS = {
  ['train'] = { service = 'train-web', path = '/src' },
  ['account'] = { service = 'account-web', path = '/src' },
  ['assessor-rails'] = { service = 'assessor-web', path = '/src' },
}

-- Function to load project-specific config
local function load_project_config()
  local current_dir = vim.fn.getcwd()

  -- Search up the directory tree for .nvim-docker.lua
  while current_dir ~= '/' do
    local config_file = current_dir .. '/.nvim-docker.lua'
    if vim.fn.filereadable(config_file) == 1 then
      local chunk = loadfile(config_file)
      if chunk then
        local ok, config = pcall(chunk)
        if ok and type(config) == 'table' then
          return config
        end
      end
    end
    current_dir = vim.fn.fnamemodify(current_dir, ':h')
  end

  return {}
end

-- Function to check if we're in a Docker Compose project (handles meta repo structure)
local function is_docker_project()
  local current_dir = vim.fn.getcwd()

  -- Search up the directory tree for docker-compose.yml
  while current_dir ~= '/' do
    if vim.fn.filereadable(current_dir .. '/docker-compose.yml') == 1 or
       vim.fn.filereadable(current_dir .. '/docker-compose.yaml') == 1 then
      return true, current_dir
    end
    current_dir = vim.fn.fnamemodify(current_dir, ':h')
  end

  return false, nil
end

-- Function to determine Docker service based on file path
local function get_docker_config()
  local current_dir = vim.fn.getcwd()
  local project_config = load_project_config()

  -- Check project config first
  if project_config.service then
    return {
      service = project_config.service,
      path = project_config.path or '/src',
      compose_file = project_config.compose_file,
      compose_dir = project_config.compose_dir
    }
  end

  -- Extract app name from current working directory
  -- Handle both direct app directories and meta repo structure (e.g., /path/to/meta/app/train)
  local app_name = vim.fn.fnamemodify(current_dir, ':t') -- Get the basename of current directory

  -- Check if we're in a meta repo structure (current dir ends with known app name)
  if DEFAULT_CONFIGS[app_name] then
    local config = vim.deepcopy(DEFAULT_CONFIGS[app_name])
    -- For meta repo, docker-compose is usually in the parent directory
    local is_docker, docker_root = is_docker_project()
    if is_docker and docker_root ~= current_dir then
      config.compose_dir = docker_root
    end
    return config
  end

  -- Fall back to detecting from file path
  local current_file = vim.fn.expand('%:p')
  for name, config in pairs(DEFAULT_CONFIGS) do
    if string.match(current_file, '/' .. name .. '/') or string.match(current_dir, '/' .. name .. '$') then
      local result_config = vim.deepcopy(config)
      local is_docker, docker_root = is_docker_project()
      if is_docker and docker_root ~= current_dir then
        result_config.compose_dir = docker_root
      end
      return result_config
    end
  end

  -- Default fallback
  local is_docker, docker_root = is_docker_project()
  local config = { service = app_name .. '-web', path = '/src' }
  if is_docker and docker_root ~= current_dir then
    config.compose_dir = docker_root
  end
  return config
end

-- Function to execute Ruby commands in Docker
local function docker_ruby_cmd(cmd)
  local config = get_docker_config()
  local base_cmd = {}

  -- If we have a compose_dir, we need to run the command from there
  if config.compose_dir then
    base_cmd = { 'sh', '-c', 'cd ' .. vim.fn.shellescape(config.compose_dir) .. ' && docker-compose' }
  else
    base_cmd = { 'docker-compose' }
  end

  -- Add compose file if specified
  if config.compose_file then
    if config.compose_dir then
      -- Already in shell command, append to the command string
      base_cmd[3] = base_cmd[3] .. ' -f ' .. vim.fn.shellescape(config.compose_file)
    else
      table.insert(base_cmd, '-f')
      table.insert(base_cmd, config.compose_file)
    end
  end

  -- Add the exec command
  local exec_cmd = 'exec -T ' .. config.service .. ' sh -c ' .. vim.fn.shellescape('cd ' .. config.path .. ' && ' .. cmd)

  if config.compose_dir then
    -- Append to the existing shell command
    base_cmd[3] = base_cmd[3] .. ' ' .. exec_cmd
    return base_cmd
  else
    vim.list_extend(base_cmd, vim.split(exec_cmd, ' '))
    return base_cmd
  end
end

-- Setup function
function M.setup()
  -- Only configure if we're in a Docker project
  local is_docker, docker_root = is_docker_project()
  if not is_docker then
    return
  end

  -- Override Ruby LSPs with Docker execution (only if in Docker project)
  local lspconfig = require('lspconfig')

  -- Store original setup functions if they exist
  local original_solargraph_setup = lspconfig.solargraph.setup
  local original_ruby_lsp_setup = lspconfig.ruby_lsp.setup

  lspconfig.solargraph.setup = function(opts)
    -- In Docker projects, override the cmd to use Docker
    local config = get_docker_config()

    -- Create a simple wrapper script for solargraph
    local wrapper_script = '/tmp/solargraph-docker-wrapper.sh'
    local script_content = string.format([[#!/bin/bash
cd %s
exec docker-compose exec -T %s bundle exec solargraph stdio
]], config.compose_dir or vim.fn.getcwd(), config.service)

    -- Write the wrapper script
    local file = io.open(wrapper_script, 'w')
    if file then
      file:write(script_content)
      file:close()
      os.execute('chmod +x ' .. wrapper_script)
    end

    local docker_opts = vim.tbl_deep_extend('force', opts or {}, {
      cmd = { wrapper_script },
      root_dir = function(fname)
        return lspconfig.util.root_pattern('docker-compose.yml', 'Gemfile', '.git')(fname)
      end,
    })

    -- Call original setup with Docker-modified options
    original_solargraph_setup(docker_opts)
  end

  lspconfig.ruby_lsp.setup = function(opts)
    -- In Docker projects, override the cmd to use Docker
    local config = get_docker_config()

    -- Create a simple wrapper script for ruby-lsp
    local wrapper_script = '/tmp/ruby-lsp-docker-wrapper.sh'
    local script_content = string.format([[#!/bin/bash
cd %s
exec docker-compose exec -T %s bundle exec ruby-lsp
]], config.compose_dir or vim.fn.getcwd(), config.service)

    -- Write the wrapper script
    local file = io.open(wrapper_script, 'w')
    if file then
      file:write(script_content)
      file:close()
      os.execute('chmod +x ' .. wrapper_script)
    end

    local docker_opts = vim.tbl_deep_extend('force', opts or {}, {
      cmd = { wrapper_script },
      root_dir = function(fname)
        return lspconfig.util.root_pattern('docker-compose.yml', 'Gemfile', '.git')(fname)
      end,
    })

    -- Call original setup with Docker-modified options
    original_ruby_lsp_setup(docker_opts)
  end

  -- Create enhanced RuboCop commands
  vim.api.nvim_create_user_command('Rubocop', function(opts)
    local file = opts.args ~= '' and opts.args or vim.fn.expand('%')
    local relative_file = string.gsub(file, vim.fn.getcwd() .. '/', '')

    if string.match(file, '%.rb$') then
      local cmd = table.concat(docker_ruby_cmd('bundle exec rubocop ' .. relative_file), ' ')
      local result = vim.fn.system(cmd)

      -- Show results in quickfix list for better navigation
      local lines = vim.split(result, '\n')
      local qf_items = {}

      for _, line in ipairs(lines) do
        local filename, lnum, col, text = string.match(line, '([^:]+):(%d+):(%d+): (.+)')
        if filename then
          table.insert(qf_items, {
            filename = filename,
            lnum = tonumber(lnum),
            col = tonumber(col),
            text = text,
          })
        end
      end

      if #qf_items > 0 then
        vim.fn.setqflist(qf_items)
        vim.cmd('copen')
      else
        print('RuboCop: No issues found!')
      end
    else
      print('RuboCop: Not a Ruby file')
    end
  end, {
    desc = 'Run RuboCop on current file',
    nargs = '?',
    complete = 'file'
  })

  vim.api.nvim_create_user_command('RubocopFix', function(opts)
    local file = opts.args ~= '' and opts.args or vim.fn.expand('%')
    local relative_file = string.gsub(file, vim.fn.getcwd() .. '/', '')

    if string.match(file, '%.rb$') then
      local cmd = table.concat(docker_ruby_cmd('bundle exec rubocop -A ' .. relative_file), ' ')
      vim.fn.system(cmd)
      vim.cmd('edit!')  -- Reload the buffer
      vim.cmd('cclose') -- Close quickfix if open
      print('RuboCop: Auto-corrections applied')
    else
      print('RuboCop: Not a Ruby file')
    end
  end, {
    desc = 'Auto-fix RuboCop issues in current file',
    nargs = '?',
    complete = 'file'
  })

  -- Reek code smell detection
  vim.api.nvim_create_user_command('Reek', function(opts)
    local file = opts.args ~= '' and opts.args or vim.fn.expand('%')
    local relative_file = string.gsub(file, vim.fn.getcwd() .. '/', '')

    if string.match(file, '%.rb$') then
      local cmd = table.concat(docker_ruby_cmd('bundle exec reek ' .. relative_file), ' ')
      local result = vim.fn.system(cmd)

      -- Show results in a split window
      vim.cmd('split')
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result, '\n'))
      vim.api.nvim_win_set_buf(0, buf)
      vim.bo[buf].filetype = 'text'

      if string.match(result, 'no code smells') then
        print('Reek: No code smells detected!')
      else
        print('Reek: Code smells detected - see split window')
      end
    else
      print('Reek: Not a Ruby file')
    end
  end, {
    desc = 'Run Reek code smell detection on current file',
    nargs = '?',
    complete = 'file'
  })

  -- Auto-format Ruby files on save (optional - uncomment to enable)
  -- vim.api.nvim_create_autocmd("BufWritePre", {
  --   pattern = "*.rb",
  --   callback = function()
  --     vim.cmd('RubocopFix')
  --   end,
  -- })

  local config = get_docker_config()
  print(string.format("Docker Ruby configured for service: %s", config.service))
end

return M