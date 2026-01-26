@echo off
setlocal enabledelayedexpansion

goto :main

:download_and_install
setlocal
	::url and download-name-regex-search
	echo Openning !url!
	start %~1
	set regex=%~2
	set projectPath=!cd!
	cd !USERPROFILE!\Downloads
	set /a downloaded=0
	for /l %%i in (0, 1, 120) do (
		dir /b | findstr /R /I "Unconfirmed.*\.crdownload" >nul
		if !ERRORLEVEL!==0 (
			echo Download started
			echo Waiting for download to finish.
			:loop
				dir /b | findstr /R /I "Unconfirmed.*\.crdownload" >nul
				if !ERRORLEVEL!==0 (
					ping -n 4 127.0.0.1 > nul
				) else (
					set binary=nothing
					for /f "delims=" %%a in ('dir /b ^| findstr /R /C:"!regex!"') do (
						set "binary=%%a"
						goto :install
					)
					:install
					if exist !binary! (
						echo Download completed
						set /a downloaded=1
						ping -n 2 127.0.0.1 > nul
						call !binary!
					) else (
						echo Download cancelled or not a windows executable 1>&2
					)
					goto :finished
				)
			goto :loop
		) else (
			echo Waiting for download to start.
		)
		ping -n 2 127.0.0.1 > nul
	)
	:finished
	cd !projectPath! >nul
	if !downloaded! == 0 (
		echo Item not downloaded^!^!^! 1>&2
		exit /b 1
	)
endlocal
goto :EOF

:configure_python
setlocal
	set PYTHON_PATH=python.exe
	python -c "print('hello')" | findstr hello >nul
	if !ERRORLEVEL! == 0 (
		python -c "import sys; print(f'Python {sys.version} detected')"
		goto :configure_env
	)
	
	echo Detected !PROCESSOR_ARCHITECTURE! processor architecture
	set /a PYTHON_VERSION=10
	set url=""
	if !PROCESSOR_ARCHITECTURE! == AMD64 (
		set url=https://www.python.org/ftp/python/3.!PYTHON_VERSION!.0/python-3.!PYTHON_VERSION!.0-amd64.exe
	) else (
		if !PROCESSOR_ARCHITECTURE! == ARM64 (
			set url=https://www.python.org/ftp/python/3.!PYTHON_VERSION!.0/python-3.!PYTHON_VERSION!.0-arm64.exe
		) else (
			echo Unsupported architecture ^(!PROCESSOR_ARCHITECTURE!^), please select your system python binary^^!^^!^^! 1>&2
			set url=https://www.python.org/ftp/python/3.!PYTHON_VERSION!.0/
			pause
		)
	)

	call :download_and_install !url! "python-3\.!PYTHON_VERSION!\.0.*\.exe"
	if !ERRORLEVEL! == 1 (
		echo Python not installed nor configured^!^!^! 1>&2
		exit /b 1
	)
	:configure_env
	if not exist .App-env\Scripts\activate.bat (
		echo Creating virtual environment
		!PYTHON_PATH! -m venv .App-env
	) else (
		echo Virtual environment detected
	)
	call .App-env\Scripts\activate.bat
	if not exist requirements.txt (
		echo Missing dependencies, please get 'requirements.txt' file 1>&2
	) else (
		pip install -r requirements.txt
	)
endlocal
goto :EOF

:install_cloudflared
setlocal
	echo !PROCESSOR_ARCHITECTURE! | findstr ARM >nul
	if !ERRORLEVEL! == 0 (
		echo Cloudflared binary not available for system architecture 1>&2
		exit /b 1
	)
	echo Getting cloudflared...
	echo !PROCESSOR_ARCHITECTURE! | findstr 64 >nul
	set url=nothing
	if !ERRORLEVEL! == 0 (
		set url=https://github.com/cloudflare/cloudflared/releases/download/2026.1.1/cloudflared-windows-amd64.exe
	) else (
		set url=https://github.com/cloudflare/cloudflared/releases/download/2026.1.1/cloudflared-windows-386.exe
	)
	call :download_and_install !url! "cloudflared-windows-.*\.exe"
	if !ERRORLEVEL! == 1 (
		echo Cloudflared not downloaded nor configured^!^!^! 1>&2
		exit /b 1
	)
endlocal
goto :EOF

:main
setlocal
    call :configure_python
    if !ERRORLEVEL! == 1 (
        exit /b 1
    )
	call :install_cloudflared
    if !ERRORLEVEL! == 1 (
        exit /b 1
    )
    echo Configuration successful
endlocal
goto :EOF
