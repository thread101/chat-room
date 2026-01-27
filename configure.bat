@echo off
setlocal enabledelayedexpansion

goto :main

:is_online
	ping -n 2 8.8.8.8 | findstr /I "host unreachable" >nul
	if !ERRORLEVEL! == 0 (
		echo E: Please connect to the internet^!^!^! 1>&2
		exit /b 1
	)
	exit /b 0
goto :EOF

:download_and_install
setlocal
	call :is_online
	if !ERRORLEVEL! == 1 (
		exit /b 1
	)
	winget --version >nul 2>&1
	if !ERRORLEVEL! neq 0 (
		echo E: Please install winget to continue^!^!^! 1>&2
		echo.
		echo ^[*^] Open powershell as admin and run the following then reboot
		echo   $progressPreference = ^'silentlyContinue^'
		echo   Write-Host ^"Installing WinGet PowerShell module from PSGallery...^"
		echo   Install-PackageProvider -Name NuGet -Force ^| Out-Null
		echo   Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery ^| Out-Null
		echo   Write-Host ^"Using Repair-WinGetPackageManager cmdlet to bootstrap WinGet...^"
		echo   Repair-WinGetPackageManager -AllUsers
		echo   Write-Host "Done."
		echo.
		echo else ^<https://learn.microsoft.com/en-us/windows/package-manager/winget/^> to get instructions.
		exit /b 1
	)
	echo  ^[*^] Installing %~1...
	winget install --id %~1
	if !ERRORLEVEL! == 1 (
		exit /b 1
	)
	echo ^[*^] %~1 installed successfully
	exit /b 0
endlocal
goto :EOF

:configure_python
setlocal
	set PYTHON_PATH=python.exe
	python -c "print('hello')" | findstr hello >nul
	if !ERRORLEVEL! == 0 (
		python -c "import sys; print(f'[*] Python {sys.version} detected')"
		goto :configure_env
	)
	
	call :download_and_install "Python.Python.3.13"
	if !ERRORLEVEL! == 1 (
		echo E: Python not installed nor configured^!^!^! 1>&2
		exit /b 1
	)
	:configure_env
	if not exist .App-env\Scripts\activate.bat (
		echo ^[*^] Creating virtual environment
		!PYTHON_PATH! -m venv .App-env
	) else (
		echo ^[*^] Virtual environment detected
	)
	call .App-env\Scripts\activate.bat
	if not exist requirements.txt (
		echo E: Missing dependencies, please get 'requirements.txt' file 1>&2
		exit /b 1
	) else (
		for /f "delims=/" %%g in (requirements.txt) do (
			pip list --disable-pip-version-check | findstr /I "%%g" >nul
			if !ERRORLEVEL! == 1 (
				goto :install_packages
			)
			echo ^[*^] %%g already installed
		)
		exit /b 0
		:install_packages
		echo ^[*^] Installing packages
		call :is_online
		if !ERRORLEVEL! == 1 (
			exit /b 1
		)
		pip install -r requirements.txt
	)
	exit /b 0
endlocal
goto :EOF

:configure_cloudflared
setlocal
	call :is_online
	if !ERRORLEVEL! == 1 (
		exit /b 1
	)
	set CLOUDFLARED_PATH=cloudflared
	cloudflared --version >nul 2>&1
	if !ERRORLEVEL! == 0 (
		goto :cloudflared_available
	)
	if not exist "C:\Program Files (x86)\cloudflared\cloudflared.exe" (
		if not exist "C:\Program Files\cloudflared\cloudflared.exe" (
			set CLOUDFLARED_PATH="C:\Program Files\cloudflared\cloudflared.exe"
			goto :cloudflared_available
		) else (
			goto :download_cloudflared
		)
	) else (
		set CLOUDFLARED_PATH="C:\Program Files (x86)\cloudflared\cloudflared.exe"
		goto :cloudflared_available
	)
	:download_cloudflared
	call :download_and_install "Cloudflare.cloudflared"
	if !ERRORLEVEL! == 1 (
		echo E: Cloudflared not downloaded nor configured^!^!^! 1>&2
		exit /b 1
	)
	exit /b 0
	:cloudflared_available
	echo ^[*^] Cloudflared already installed
	echo !CLOUDFLARED_PATH! >.cloudflared_path.txt
endlocal
goto :EOF

:main
setlocal
    call :configure_python
    if !ERRORLEVEL! == 1 (
        exit /b 1
    )
	call :configure_cloudflared
    if !ERRORLEVEL! == 1 (
        exit /b 1
    )
    echo ^[*^] Configuration successful
endlocal
goto :EOF
