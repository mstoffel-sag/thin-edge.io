#Command to execute:    robot -d \results --timestampoutputs --log health_tedge_mapper.html --report NONE --variable HOST:192.168.1.120 /thin-edge.io-fork/tests/RobotFramework/MQTT_health_check/health_tedge_mapper.robot

*** Settings ***
Library    SSHLibrary
Library    MQTTLibrary
Library    CryptoLibrary    variable_decryption=True
Suite Setup            Open Connection And Log In
Suite Teardown         SSHLibrary.Close All Connections

*** Variables ***
${HOST}           192.168.1.130
${USERNAME}       pi
${PASSWORD}       @crypt:LO3wCxZPltyviM8gEyBkRylToqtWm+hvq9mMVEPxtn0BXB65v/5wxUu7EqicpOgGhgNZVgFjY0o=



*** Tasks ***

Stop tedge-mapper
    ${rc}=    Execute Command    sudo systemctl stop tedge-mapper-c8y.service    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Update the service file
    ${rc}=    Execute Command    sudo sed -i '10iWatchdogSec=30' /lib/systemd/system/tedge-mapper-c8y.service    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Reload systemd files
    ${rc}=    Execute Command    sudo systemctl daemon-reload    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Start tedge-mapper
    ${rc}=    Execute Command    sudo systemctl start tedge-mapper-c8y.service    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Start watchdog service
    ${rc}=    Execute Command    sudo systemctl start tedge-watchdog.service    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
    Sleep    10s
Check PID of tedge_mapper
    ${pid}=    Execute Command    pgrep 'tedge_mapper c8y'
    Set Suite Variable    ${pid}
Kill the PID
    ${rc}=    Execute Command    sudo kill -9 ${pid}    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Recheck PID of tedge_mapper
    ${pid1}=    Execute Command    pgrep 'tedge_mapper c8y'
    Set Suite Variable    ${pid1}
Compare PID change
    Should Not Be Equal    ${pid}    ${pid1}
Stop watchdog service
    ${rc}=    Execute Command    sudo systemctl stop tedge-watchdog.service    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}
Remove entry from service file
    ${rc}=    Execute Command    sudo sed -i '10d' /lib/systemd/system/tedge-mapper-c8y.service    return_stdout=False    return_rc=True
    Should Be Equal    ${rc}    ${0}

*** Keywords ***
Open Connection And Log In
   Open Connection     ${HOST}
   Login               ${USERNAME}        ${PASSWORD}
