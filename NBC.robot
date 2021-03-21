*** Settings ***
Library           SeleniumLibrary
Library           DatabaseLibrary
Library           OperatingSystem
Library           DateTime
Resource          resource.robot
Library           ExcelLibrary

*** Test Cases ***
NBC_Saturady_Live
    DatabaseLibrary.Connect To Database    pymysql    nbcu_pilot    vivekkumar.pandey    MMaXm83dZD18A4AA    dev-scraper.csoaie2kvgsc.us-east-1.rds.amazonaws.com    3306
    SeleniumLibrary.Open Browser    https://www.nbc.com/saturday-night-live    chrome
    Maximize Browser Window
    Sleep    5s
    @{List}=    Get WebElements    css=div.shelf__tiles__inner>a.tile.tile--clip.tile--zoomable
    : FOR    ${i}    IN    @{List}
    \    ${URL}=    Get Element Attribute    ${i}    href
    \    BuiltIn.Exit For Loop If    ${Count2}==51
    \    ${Count2}    BuiltIn.Evaluate    ${Count2}+1
    \    BuiltIn.Run Keyword And Ignore Error    Inner_Loop_NBC_Saturday_Night_Live    ${URL}
    \    Close Window
    \    Select Window    Main
    \    Sleep    2s
    Close Browser

*** Keywords ***
Inner_Loop_NBC_Saturday_Night_Live
    [Arguments]    ${URL}
    Execute Javascript    window.open()
    Select Window    NEW
    Sleep    10s
    Go To    ${URL}
    Sleep    10s
    ${Episode_Name}=    Get Text    css=h1.video-meta__title>span
    ${Episode_Name}=    String.Replace String    ${Episode_Name}    '    ''
    DatabaseLibrary.Execute Sql String    INSERT INTO nbcu_pilot.NBC_Saturday_Night_Live (`Episode_Name`) VALUES ('${Episode_Name}');
    Sleep    3s
    ${list}=    DatabaseLibrary.Query    select max(id) from nbcu_pilot.NBC_Saturday_Night_Live;
    Convert To List    ${list}
    ${list}=    Evaluate    [x[0] for x in ${list}]
    ${Count3}=    Get From List    ${list}    ${count}
    Sleep    5s
    ${Episode_Date}=    Get Text    css=div.video-meta__secondary-title>span:nth-child(2)
    ${Episode_Date}=    String.Replace String    ${Episode_Date}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.NBC_Saturday_Night_Live set Episode_Date= '${Episode_Date}' where id=${Count3}
    ${Video_Type}=    Get Text    css=div.video-meta__secondary-title>span:nth-child(1)
    ${Video_Type}=    String.Replace String    ${Video_Type}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.NBC_Saturday_Night_Live set Video_Type= '${Video_Type}' where id=${Count3}
    ${URL}=    String.Replace String    ${URL}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.NBC_Saturday_Night_Live set URL= '${URL}' where id=${Count3}
    Sleep    10s
    Click Element    css=span.video-meta__expand__text
    Sleep    10s
    ${Description}=    Get Text    css=p.video-meta__description
    ${Description}=    String.Replace String    ${Description}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.NBC_Saturday_Night_Live set Description= '${Description}' where id=${Count3}
    ${Appearing}=    Get Text    css=div.video-meta__tags
    ${Appearing}=    String.Replace String    ${Appearing}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.NBC_Saturday_Night_Live set Appearing= '${Appearing}' where id=${Count3}
    ${Series_Name}=    Get Text    css=span.video-meta__episode
    ${Series_Name}=    String.Replace String    ${Series_Name}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.NBC_Saturday_Night_Live set Series_Name= '${Series_Name}' where id=${Count3}
    ${New_Duration}=    Get Text    css=span.video-meta__length
    ${New_Duration}=    String.Replace String    ${New_Duration}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.NBC_Saturday_Night_Live set Duration= '${New_Duration}' where id=${Count3}
    ${Video_Meta_Type}=    Get Text    css=span.video-meta__type
    ${Video_Meta_Type}=    String.Replace String    ${Video_Meta_Type}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.NBC_Saturday_Night_Live set Video_Meta_Type= '${Video_Meta_Type}' where id=${Count3}
    ${Genre}=    Get Text    css=span.video-meta__show-type
    ${Genre}=    String.Replace String    ${Genre}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.NBC_Saturday_Night_Live set Genre= '${Genre}' where id=${Count3}
    ${Video_meta__show-air-type}=    Get Text    css=span.video-meta__show-air-type
    ${Video_meta__show-air-type}=    String.Replace String    ${Video_meta__show-air-type}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.NBC_Saturday_Night_Live set Video_meta_show_air_type= '${Video_meta__show-air-type}' where id=${Count3}
    ${Releae_Year}=    Get Text    css=div.video-meta__copyright
    ${Releae_Year}=    String.Replace String    ${Releae_Year}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.NBC_Saturday_Night_Live set Release_Year= '${Releae_Year}' where id=${Count3}
