local M = {}

function File_exists(name)
	local f = io.open(name, "r")
	return f ~= nil and io.close(f)
end

function M.cmake_context(build_dir, callback)
	if not File_exists(build_dir) then
		vim.cmd("!mkdir " .. build_dir)
	end
	vim.cmd("cd " .. build_dir)
	callback()
	vim.cmd("cd ..")
end

function M.cmake_run_target(build_dir, target)
	M.cmake_context(build_dir, function()
		local target_arg = ""

		if string.len(target) ~= 0 then
			target_arg = string.format("--target %s", target)
		else
			target_arg = ""
		end

		local cmake_cmd = string.format("bel 10split term://cmake --build . %s", target_arg)
		vim.cmd(cmake_cmd)
		vim.cmd("startinsert")
	end)
end

function M.setup(opts)
	local build_dir = opts.build_dir or "build"
	if File_exists("CMakeLists.txt") then
		vim.api.nvim_create_user_command("CMakeGenerate", function(args)
			M.cmake_context(build_dir, function()
				local vim_cmd = string.format("bel 10split term://cmake %s ..", args.args)
				vim.cmd(vim_cmd)
				vim.cmd("startinsert")
			end)
		end, { nargs = "?", desc = "Generates build dir, enters it and run cmake" })

		vim.api.nvim_create_user_command("CMakeBuild", function(args)
			M.cmake_run_target(build_dir, args.args)
		end, { nargs = "?", desc = "Builds the target" })
	end
end

return M
-- vim: ts=2 sts=2 sw=2 et
