TESTS_DIR = tests
INIT_LUA = init.lua

test:
	nvim --headless -c "PlenaryBustedDirectory $(TESTS_DIR)"
