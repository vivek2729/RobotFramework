*** Settings ***
Library           SeleniumLibrary
Library           DatabaseLibrary
Library           ExcelLibrary
Library           OperatingSystem
Library           DateTime
Resource          resource.robot

*** Test Cases ***
JustWatch_Automation
    Open Browser    https://www.google.com    chrome
    Maximize Browser Window
    Sleep    10s
    Go to    https://www.justwatch.com/in/provider/netflix/tv-shows
    Sleep    20s
    ${List}=    SeleniumLibrary.Get WebElements    css=div.title-list-grid>div.title-list-grid__item>a
    ${Length_Before_Scroll}=    BuiltIn.Get Length    ${List}
    : FOR    ${i}    IN RANGE    999999
    \    BuiltIn.Run Keyword And Ignore Error    Scroll_Page_To_Location    0    ${Vertical_Scroll}
    \    Sleep    5s
    \    ${List}=    SeleniumLibrary.Get WebElements    css=div.title-list-grid>div.title-list-grid__item>a
    \    ${Length_After_Scroll}=    BuiltIn.Get Length    ${List}
    \    ${bool}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Be Equal As Integers    ${Length_After_Scroll}    ${Length_Before_Scroll}
    \    ${bool}    Get From List    ${bool}    0
    \    BuiltIn.Convert To String    ${bool}
    \    ${Vertical_Scroll}    BuiltIn.Evaluate    ${Vertical_Scroll}+50000
    \    BuiltIn.Exit For Loop If    '${bool}'=='PASS'
    \    ${Length_Before_Scroll}    BuiltIn.Set Variable    ${Length_After_Scroll}
    ${List}=    Get WebElements    css=div.title-list-grid>div.title-list-grid__item>a
    BuiltIn.Get Length    ${List}
    @{List}    Get WebElements    css=div.title-list-grid>div.title-list-grid__item>a
    DatabaseLibrary.Connect To Database    pymysql    nbcu_pilot    vivekkumar.pandey    MMaXm83dZD18A4AA    dev-scraper.csoaie2kvgsc.us-east-1.rds.amazonaws.com    3306
    : FOR    ${j}    IN    @{List}
    \    ${URL}=    Get Element Attribute    ${j}    href
    \    BuiltIn.Run Keyword And Ignore Error    Extracting_Details_From_URL    ${URL}
    \    close window
    \    Select Window    Main
    \    Sleep    1s
    Close All Browsers
    Disconnect From Database

*** Keywords ***
Scroll_Page_To_Location
    [Arguments]    ${x_location}    ${y_location}
    Execute Javascript    window.scrollTo(${x_location},${y_location})

Extracting_Details_From_URl
    [Arguments]    ${URL}
    Execute Javascript    window.open()
    Select Window    NEW
    Sleep    1s
    Go To    ${URL}
    Sleep    10s
    ${Href}=    Get Element Attribute    //img[@title='Netflix']/..    href
    ${Href}=    String.Fetch From Right    ${Href}    title%2F
    ${Href}=    String.Fetch From Left    ${Href}    &
    DatabaseLibrary.Execute Sql String    INSERT INTO nbcu_pilot.JustWatch_TV (`UniqueID`) VALUES ('${Href}')
    ${list}=    DatabaseLibrary.Query    select max(id) from nbcu_pilot.JustWatch_TV;
    Convert To List    ${list}
    ${list}=    Evaluate    [x[0] for x in ${list}]
    ${Count3}=    Get From List    ${list}    ${count}
    ${URL}=    String.Replace String    ${URL}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.JustWatch_TV set URL= '${URL}' where id=${Count3}
