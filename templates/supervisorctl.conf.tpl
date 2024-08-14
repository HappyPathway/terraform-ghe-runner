[program:${runner}]
command=${command}
;numprocs=1                    ; number of processes copies to start (def 1)
directory=${directory}              ; directory to cwd to before exec (def no cwd)
;autostart=true                ; start at supervisord start (default: true)
;startsecs=1                   ; # of secs prog must stay up to be running (def. 1)
startretries=3                ; max # of serial start failures when starting (default 3)
autorestart=true
stdout_logfile=${directory}/runner.log        ; stdout log path, NONE for none; default AUTO
stdout_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
stdout_logfile_backups=10     ; # of stdout logfile backups (0 means none, default 10)
stdout_capture_maxbytes=1MB   ; number of bytes in 'capturemode' (default 0)
stderr_logfile=${directory}/runner_error.log       ; stderr log path, NONE for none; default AUTO
stderr_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
stderr_logfile_backups=10     ; # of stderr logfile backups (0 means none, default 10)
stderr_capture_maxbytes=1MB   ; number of bytes in 'capturemode' (default 0)