--
-- Copyright (c) 2012-2023 Daniele Bartolini et al.
-- SPDX-License-Identifier: MIT
--

function crown_project(_name, _kind, _defines)

	project ("crown" .. _name)
		kind (_kind)

		includedirs {
			CROWN_DIR .. "src",
			CROWN_DIR .. "3rdparty/bgfx/include",
			CROWN_DIR .. "3rdparty/bgfx/src",
			CROWN_DIR .. "3rdparty/bx/include",
			CROWN_DIR .. "3rdparty/stb",
			CROWN_DIR .. "3rdparty/bullet3/src",
			CROWN_DIR .. "3rdparty/openal/include",
		}

		defines {
			_defines,
		}

		links {
			"bgfx",
			"bimg",
			"bx",
			"bullet",
			"openal",
		}

		if not _OPTIONS["no-lua"] then
			if not _OPTIONS["no-luajit"] then
				includedirs {
					CROWN_DIR .. "3rdparty/luajit/src",
				}

				configuration { "not vs*" }
					links {
						"luajit"
					}

				configuration { "vs*"}
					links {
						"lua51"
					}

				configuration {}
			else
				includedirs {
					CROWN_DIR .. "3rdparty/lua/src",
				}

				links { "lua" }

				defines {
					"CROWN_USE_LUAJIT=0",
				}
			end
		end

		configuration { "debug" }
			defines {
				"BX_CONFIG_DEBUG=1",
			}

		configuration { "debug or development" }
			defines {
				"CROWN_DEBUG=1"
			}

		configuration { "development" }
			defines {
				"CROWN_DEVELOPMENT=1"
			}

		configuration { "release or development" }
			defines {
				"BX_CONFIG_DEBUG=0",
			}

		configuration { "android*" }
			kind "ConsoleApp"
			targetextension ".so"
			linkoptions {
				"-shared"
			}
			links {
				"gcc",
				"EGL",
				"GLESv2",
				"OpenSLES",
			}

		configuration { "linux-*" }
			links {
				"X11",
				"Xrandr",
				"pthread",
				"GL",
			}

		configuration { "vs* or mingw*" }
			links {
				"dbghelp",
				"xinput",
				"psapi",
				"ws2_32",
				"ole32",
				"gdi32",
			}

		configuration {}

		files {
			CROWN_DIR .. "src/**.h",
			CROWN_DIR .. "src/**.cpp"
		}

		strip()

		configuration {} -- reset configuration
end
