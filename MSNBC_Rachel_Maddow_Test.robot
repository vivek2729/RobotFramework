*** Settings ***
Library           SeleniumLibrary
Library           DatabaseLibrary
Library           OperatingSystem
Library           DateTime
Resource          resource.robot
Library           ExcelLibrary

*** Test Cases ***
MSNBC_Rachel_Maddow
    DatabaseLibrary.Connect To Database    pymysql    nbcu_pilot    vivekkumar.pandey    MMaXm83dZD18A4AA    dev-scraper.csoaie2kvgsc.us-east-1.rds.amazonaws.com    3306
    SeleniumLibrary.Open Browser    http://www.msnbc.com/search/rachel%20maddow?f%5B0%5D=bundle%3Atheplatform_video    chrome
    Maximize Browser Window
    Sleep    5s
    @{List}=    Get WebElements    css=div.view-content>div.views-row.views-row
    : FOR    ${i}    IN    @{List}
    \    BuiltIn.Run Keyword And Ignore Error    Extracting_Details_From_Main_Page    ${Count2}
    \    Close Window
    \    Select Window    Main
    \    Sleep    2s
    \    ${Count2}    BuiltIn.Evaluate    ${Count2}+1
    \    BuiltIn.Exit For Loop
    Close Browser
    Disconnect From Database

*** Keywords ***
Extracting_Details_From_URL
    [Arguments]    ${URL}    ${Count3}
    Execute Javascript    window.open()
    Select Window    NEW
    Sleep    10s
    Go To    ${URL}
    Sleep    10s
    BuiltIn.Run Keyword And Ignore Error    Extracting_Duration    ${Count3}
    ${Title1}=    Get Text    //h1[contains(@class,'title')]
    ${Title}=    String.Replace String    ${Title1}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.MSNBC_Rachel_Maddow_Test set Title= '${Title}' where id=${Count3}
    ${Date}=    Get Text    //span[contains(@class,'byline')]
    ${Date}    String.Replace String    ${Date}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.MSNBC_Rachel_Maddow_Test set Date= '${Date}' where id=${Count3}
    ${Description}=    Get Text    //p[contains(@class,'dekText')]
    ${Description}=    String.Replace String    ${Description}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.MSNBC_Rachel_Maddow_Test set Description= '${Description}' where id=${Count3}
    ${Category}=    Get Text    //h2[contains(@class,'articleTitleSection category')]/a/span
    ${Category}=    String.Replace String    ${Category}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.MSNBC_Rachel_Maddow_Test set Category= '${Category}' where id=${Count3}

Extracting_Details_From_Main_Page
    [Arguments]    ${Count2}
    ${Explore_Links}=    Get Text    css=div.view-content>div.views-row.views-row-${Count2}>div>div>div.search-result__teaser__explore
    ${Explore_Links}=    String.Replace String    ${Explore_Links}    '    ''
    DatabaseLibrary.Execute Sql String    INSERT INTO nbcu_pilot.MSNBC_Rachel_Maddow_Test (`Explored_Texts`) VALUES ('${Explore_Links}')
    Sleep    5s
    ${list}=    DatabaseLibrary.Query    select max(id) from nbcu_pilot.MSNBC_Rachel_Maddow_Test;
    Convert To List    ${list}
    ${list}=    Evaluate    [x[0] for x in ${list}]
    ${Count3}=    Get From List    ${list}    ${count}
    Sleep    5s
    ${Video_Rendered_Before}=    Get Text    css=div.view-content>div.views-row.views-row-${Count2}>div>div>div.search-result__teaser__pubinfo
    ${Video_Rendered_Before}=    String.Replace String    ${Video_Rendered_Before}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.MSNBC_Rachel_Maddow_Test set Video_Rendered_Before= '${Video_Rendered_Before}' where id=${Count3}
    Sleep    5s
    Sleep    5s
    ${URL}=    Get Element Attribute    css=div.view-content>div.views-row.views-row-${Count2}>div>div>h3>a    href
    ${URL}=    String.Replace String    ${URL}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.MSNBC_Rachel_Maddow_Test set URL= '${URL}' where id=${Count3}
    BuiltIn.Run Keyword And Ignore Error    Extracting_Details_From_URL    ${URL}    ${Count3}

Extracting_Duration
    [Arguments]    ${Count3}
    Click Element    //div[contains(@class,'videoPlayer')]
    Sleep    45s
    ${Duration}=    SeleniumLibrary.Add Cookie    //div[contains(@class,'videoPlayer')]/div/div/span[contains(@class,'time')]/text()
    Comment    ${Duration}=    Get From List    @{Duration}    4
    Comment    ${Duration}=    String.Replace String    ${Duration}=    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.MSNBC_Rachel_Maddow_Test set Duration= '${Duration}' where id=${Count3}
