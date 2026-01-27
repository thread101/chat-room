@echo off

setlocal enabledelayedexpansion

goto :main

:main
setlocal
	if not exist ".\.App-env\Scripts\python.exe" (
		call .\configure.bat
		if !ERRORLEVEL! neq 0 (
			exit /b 1
		)
	)
	
	set CLOUFLARED_PATH=cloudflared
	cloudflared --version >nul 2>&1
	if !ERRORLEVEL! neq 0 (
		if not exist ".cloudflared_path.txt" (
			call .\configure.bat
			if !ERRORLEVEL! neq 0 (
				exit /b 1
			)
		)
		set /p CLOUFLARED_PATH=<".cloudflared_path.txt"
	)
	
	del cloudflared.log >nul 2>&1
	call .\.App-env\Scripts\activate.bat
	echo ^[*^] Starting flask backend...
	start "flask backend" cmd /c "flask run -h localhost -p 8099"

	ping -n 4 127.0.0.1 >nul
	echo ^[*^] Starting clouflared tunnel...
	start "cloudflared tunnel" cmd /c "!CLOUFLARED_PATH! tunnel --url http://localhost:8099/ --logfile cloudflared.log"
	
	set PUBLIC_URL=nothing
	ping -n 4 127.0.0.1 >nul
	for /l %%g in (0,1,20) do (
		for /f "tokens=*" %%A in ('findstr /i /R "https://.*\.trycloudflare\.com" cloudflared.log') do (
			for /f "tokens=1-3 delims=^|" %%B in ("%%A") do (
				if %%C neq "" (
					set PUBLIC_URL=%%C
					goto :open_link
				)
			)
		)
		ping -n 2 127.0.0.1 >nul
	)
	echo E: Unable to find cloudflared tunnel url^!^!^!
	goto :clean_up
	
	:open_link
	start !PUBLIC_URL!
	
	:loop
		choice /c q /m "^[*^] Press 'q' to close the connection "
		if !ERRORLEVEL! == 1 (
			goto :clean_up
		)
	goto :loop
	
	:clean_up
	echo ^[*^] Clossing connection...
	taskkill /f /im flask.exe
	taskkill /f /im cloudflared.exe
endlocal
goto :EOF