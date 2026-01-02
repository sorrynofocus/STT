Tool Name: powerprof
Description:
  A C++ DLL and console app that manages Windows sleep and RTC wake events.
  It supports S3 (Sleep) and S4 (Hibernate), wake timers, Wi-Fi reconnect, sign-on control, and light user activity simulation.

Main Executable:
  powerprof-test-app.exe

Command Format:
  powerprof-test-app.exe <args>
  or use the DLL via C++ or C# (P/Invoke)

Supported CLI Flags:
- --mode=<auto|modern|s3|s4> <start> <end>  : Schedule a sleep-wake cycle
- --test                                    : Sleep now, wake in 60s
- --dump                                    : Dump current power state support
- --hibernateon / --hibernateoff           : Enable or disable hibernate
- --showsignon / --enablesignon / --disablesignon : Configure sign-on after wake
- --acwaketimerson / --acimportantwaketimersonly : Wake timer policy

Examples:

# Sleep now, wake in 60 seconds
CMD: powerprof-test-app.exe --mode=auto --test

# Schedule sleep/wake between 00:15 and 00:20 on 2025-05-24
CMD: powerprof-test-app.exe --mode=s3 2025-05-24_00:15 2025-05-24_00:20

# Enable hibernate support
CMD: powerprof-test-app.exe --hibernateon

# Disable password prompt after wake (AC only)
CMD: powerprof-test-app.exe --disablesignon

---

LLM Prompting Hints:
- "Put my system to sleep for 10 minutes using hibernate" : Use mode=s4
- "Disable wake sign-in on AC power" : Use --disablesignon
- "Enable wake timers for AC and DC" : Use SetWakeTimerStatus(1, 2)
- "Test if my machine supports S4 sleep" : Use --dump

DLL Capabilities:
- ScheduleSleepThenWake(sleepTime, wakeTime)
- EnsureHibernateEnabled(true)
- SetWakeTimerStatus()
- ReconnectWiFi()
- JiggleMouse() / UserActivitySimulation()
- Logging: InitLogging(), LogInfo(), LogError()

Note:
- Modern Standby (S0ix) not implemented, fallback used
- Wake timers must be enabled in Windows power policy
- Wi-Fi reconnect requires saved SSID profiles
