*** Settings ***
Library           SeleniumLibrary
Library           DatabaseLibrary
Library           OperatingSystem
Library           DateTime
Library           ExcelLibrary
Resource          resource.robot

*** Test Cases ***
Extracting_Duration
    DatabaseLibrary.Connect To Database    pymysql    nbcu_pilot    vivekkumar.pandey    MMaXm83dZD18A4AA    dev-scraper.csoaie2kvgsc.us-east-1.rds.amazonaws.com    3306
    SeleniumLibrary.Open Browser    https://www.youtube.com/user/SaturdayNightLive/videos?view=0&sort=dd&flow=grid    chrome
    Maximize Browser Window
    Sleep    5s
    @{List}=    Get WebElements    css=div#items>ytd-grid-video-renderer
    : FOR    ${j}    IN    @{List}
    \    BuiltIn.Exit For Loop If    ${Count2}==51
    \    BuiltIn.Run Keyword And Ignore Error    Extracting_Duration    ${Count2}
    \    ${Count2}    BuiltIn.Evaluate    ${Count2}+1
    Close Browser

*** Keywords ***
Extracting_Duration
    [Arguments]    ${Count2}
    Sleep    5s
    ${bool}=    BuiltIn.Run Keyword And Ignore Error    SeleniumLibrary.Element Should Be Visible    css=div#items>ytd-grid-video-renderer:nth-child(${Count2})>div>ytd-thumbnail>a>div>ytd-thumbnail-overlay-time-status-renderer>span
    ${bool}=    Get From List    ${bool}    0
    Run Keyword If    '${bool}'=='PASS'    Duration_Extraction    ${Count2}
    ...    ELSE    Scrolling    ${Count2}

Duration_Extraction
    [Arguments]    ${Count2}
    ${Duration}=    Get Text    css=div#items>ytd-grid-video-renderer:nth-child(${Count2})>div>ytd-thumbnail>a>div>ytd-thumbnail-overlay-time-status-renderer>span

Scrolling
    [Arguments]    ${Count2}
    BuiltIn.Run Keyword And Ignore Error    Scroll page to location    0    100000
    Sleep    10s
    BuiltIn.Run Keyword And Ignore Error    Extracting_Duration    ${Count2}

Scroll page to location
    [Arguments]    ${x_location}    ${y_location}
    Execute Javascript    window.scrollTo(${x_location},${y_location})
