*** Settings ***
Library           SeleniumLibrary
Library           DatabaseLibrary
Library           ExcelLibrary
Library           OperatingSystem
Library           DateTime
Resource          resource.robot

*** Test Cases ***
ReelGood_Automation
    Open Browser    https://www.google.com    chrome
    Maximize Browser Window
    Sleep    10s
    Go to    https://reelgood.com/tv/source/netflix
    Sleep    20s
    ${List}=    SeleniumLibrary.Get WebElements    //tbody/tr/td[2]/a
    ${Length_Before_Scroll}=    BuiltIn.Get Length    ${List}
    FOR    ${i}    IN RANGE    999999
        BuiltIn.Run Keyword And Ignore Error    Scroll page to location    0    ${Vertical_Scroll}
        Sleep    5s
        BuiltIn.Run Keyword And Ignore Error    Click Button    //button[contains(text(),'Load More')]
        Sleep    10s
        ${List}=    SeleniumLibrary.Get WebElements    //tbody/tr/td[2]/a
        ${Length_After_Scroll}=    BuiltIn.Get Length    ${List}
        ${bool}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Be Equal As Integers    ${Length_After_Scroll}    ${Length_Before_Scroll}
        ${bool}    Get From List    ${bool}    0
        BuiltIn.Convert To String    ${bool}
        ${Vertical_Scroll}    BuiltIn.Evaluate    ${Vertical_Scroll}+50000
        BuiltIn.Exit For Loop If    '${bool}'=='PASS'
        ${Length_Before_Scroll}    BuiltIn.Set Variable    ${Length_After_Scroll}
    ${List}=    Get WebElements    //tbody/tr/td[2]/a
    BuiltIn.Get Length    ${List}
    @{List}    Get WebElements    //tbody/tr/td[2]/a
    DatabaseLibrary.Connect To Database    pymysql    nbcu_pilot    vivekkumar.pandey    MMaXm83dZD18A4AA    dev-scraper.csoaie2kvgsc.us-east-1.rds.amazonaws.com    3306
    FOR    ${j}    IN    @{List}
        ${URL}=    Get Element Attribute    ${j}    href
        BuiltIn.Run Keyword And Ignore Error    Extracting_Details_From_URL    ${URL}
        close window
        Select Window    Main
        Sleep    1s
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
    Go to    ${URL}
    Sleep    10s
    ${Web}=    Get Source
    ${ID}=    String.Fetch From Right    ${Web}    "show_id":"
    ${ID}=    String.Fetch From Left    ${ID}    "}}
    DatabaseLibrary.Execute Sql String    INSERT INTO nbcu_pilot.ReelGood_TV (`UniqueID`) VALUES ('${ID}')
    ${list}=    DatabaseLibrary.Query    select max(id) from nbcu_pilot.ReelGood_TV;
    Convert To List    ${list}
    ${list}=    Evaluate    [x[0] for x in ${list}]
    ${Count3}=    Get From List    ${list}    ${count}
    ${URL}=    String.Replace String    ${URL}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.ReelGood_TV set URL= '${URL}' where id=${Count3}

Netlix_Login
    Execute Javascript    window.open()
    Select Window    NEW
    Sleep    1s
    Go to    https://www.netflix.com
    Sleep    10s
    Click Element    css=a.authLinks.redButton
    Sleep    10s
    Input Text    css=#id_userLoginId    it@spherex.com
    Input Text    css=#id_password    abc@123
    Click Button    css=button.btn.login-button
    sleep    5s
    Click Element    //span[@class='profile-name'][contains(text(),'Spherex')]/..
    sleep    10s
    Close Window
    Select Window    Main
    Sleep    1s

Extracting_Data
    [Arguments]    ${Text}
    ${Href}=    Get Element Attribute    css=#title-card-0-0>div>a    href
    ${Href}=    String.Fetch From Right    ${Href}    watch/
    ${Href}=    String.Fetch From Left    ${Href}    ?tctx
    DatabaseLibrary.Execute Sql String    INSERT INTO nbcu_pilot.ReelGood_TV (`UniqueID`) VALUES ('${Href}')
    ${list}=    DatabaseLibrary.Query    select max(id) from nbcu_pilot.ReelGood_TV;
    Convert To List    ${list}
    ${list}=    Evaluate    [x[0] for x in ${list}]
    ${Count3}=    Get From List    ${list}    ${count}
    ${Text}=    String.Replace String    ${Text}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.ReelGood_TV set Title= '${Text}' where id=${Count3}
