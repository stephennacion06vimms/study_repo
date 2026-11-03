@echo off
rem Wrapper so docs.ps1 runs without changing the PowerShell execution policy.
rem Usage: scripts\docs.cmd [serve|build|open|setup] [-Port 8001] [-NoBrowser]
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0docs.ps1" %*
