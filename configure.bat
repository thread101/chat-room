@echo off
setlocal enabledelayedexpansion

goto :main

:install_python
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
		)
	)
	
	if !url!=="" (
		set url=https://www.python.org/ftp/python/3.!PYTHON_VERSION!.0/
		pause
		echo Openning !url!
		start !url!
	) else (
		echo Getting python...
		echo Downloading !url!
		start !url!
	)
	
	set projectPath=!cd!
	cd !USERPROFILE!\Downloads
	
	for /l %%i in (0, 1, 15) do (
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
					for /f "delims=" %%a in ('dir /b ^| findstr /R /C:"python-3\.!PYTHON_VERSION!\.0.*\.exe"') do (
						set "binary=%%a"
						goto :install
					)
					:install
					if exist !binary! (
						echo Download completed
						ping -n 2 127.0.0.1 > nul
						start /wait !binary!
						ping -n 4 127.0.0.1 > nul
						
						if exist "C:\Users\user\AppData\Local\Programs\Python\Python3!PYTHON_VERSION!\python.exe" (
							set PYTHON_PATH=C:\Users\user\AppData\Local\Programs\Python\Python3!PYTHON_VERSION!\python.exe
						) else (
							if exist "C:\Program Files\Python3!PYTHON_VERSION!\python.exe" (
								set PYTHON_PATH="C:\Program Files\Python3!PYTHON_VERSION!\python.exe"
							) else (
								echo Python3!PYTHON_VERSION! not installed. 1>&2
								goto :endLoop
							)
						)
						
						cd !projectPath! >nul
						:configure_env
							if not exist .App-env\Scripts\activate.bat (
								echo Creating virtual environment
								!PYTHON_PATH! -m venv .App-env
							) else (
								echo Virtual environment detected
							)
							call .App-env\Scripts\activate.bat
							echo Activated
							if not exist requirements.txt (
								echo Missing dependencies, please get 'requirements.txt' file 1>&2
							) else (
								pip install -r requirements.txt
							)
						goto :endLoop
					) else (
						echo Download cancelled or not a windows executable 1>&2
					)
					goto :endLoop
				)
			goto :loop
		) else (
			echo Waiting for download to start.
		)
		timeout /t 1 /nobreak
	)
	:endLoop
endlocal
goto :EOF

:main
setlocal
	call :install_python
endlocal
goto :EOF