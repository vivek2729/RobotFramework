*** Settings ***
Library           SeleniumLibrary
Resource          resource.robot
Library           OperatingSystem
Library           DatabaseLibrary
Library           DateTime

*** Test Cases ***
Extracting_Employees_LinkedIN_URL
    DatabaseLibrary.Connect To Database    pymysql    urs_aa    vivek    mail_1234    shashin-urs.csoaie2kvgsc.us-east-1.rds.amazonaws.com    3306
    ${list}    DatabaseLibrary.Query    select id,company_name from urs_aa.linkedin_robot Limit 20001, 40000;
    Convert To List    ${list}
    Open Browser    https://www.google.com    chrome
    Maximize Browser Window
    Click Element    css=input[name='q']
    Input Text    css=input[name='q']    a
    Sleep    5s
    Click Element    //ul/li[1]/div/div[2]/div/span
    Sleep    5s
    ${ID_List}    Evaluate    [x[0] for x in ${list}]
    @{Name_List}    Evaluate    [x[1] for x in ${list}]
    FOR    ${i}    IN    @{Name_List}
    Input Text    css=input[name='q']    site:linkedin.com ${i} employees
    Sleep    30s
    Click Element    css=button[aria-label='Google Search']
    Sleep    30s
    ${ID_Number}=    Get From List    ${ID_List}    ${count1}
    @{Url_List}    SeleniumLibrary.Get WebElements    css=div.r>a
    BuiltIn.Run Keyword And Ignore Error    Inner_For_Loop_Extracting_Employees    ${ID_Number}    @{Url_List}
    ${count1}    BuiltIn.Evaluate    ${count1}+1
    Disconnect From Database
    String.Convert To Lower Case
    Process.Get Process Id
    FOR    1    IN RANGE    100

Extracting_Followers
    DatabaseLibrary.Connect To Database    pymysql    urs_aa    vivek    mail_1234    shashin-urs.csoaie2kvgsc.us-east-1.rds.amazonaws.com    3306
    ${list}    DatabaseLibrary.Query    select id,company_name from urs_aa.linkedin_robot Limit 20001, 40000;
    Convert To List    ${list}
    Open Browser    https://www.google.com    chrome
    Maximize Browser Window
    Click Element    css=input[name='q']
    Input Text    css=input[name='q']    a
    Sleep    5s
    Click Element    //ul/li[1]/div/div[2]/div/span
    Sleep    5s
    ${ID_List}    Evaluate    [x[0] for x in ${list}]
    @{Name_List}    Evaluate    [x[1] for x in ${list}]
    FOR    ${i}    IN    @{Name_List}
    Input Text    css=input[name='q']    site:linkedin.com ${i} followers
    Sleep    30s
    Click Element    css=button[aria-label='Google Search']
    Sleep    30s
    ${ID_Number}=    Get From List    ${ID_List}    ${count1}
    @{Url_List}    SeleniumLibrary.Get WebElements    css=div.r>a
    BuiltIn.Run Keyword And Ignore Error    Inner_For_Loop_Extracting_Followers    ${ID_Number}    @{Url_List}
    ${count1}    BuiltIn.Evaluate    ${count1}+1
    Disconnect From Database

Logs
    log    Server_ID- ${Server_ID}
    log    Starting_Limit-${Start}
    log    Limit_Ends_At-${End}
    log    Server_IP-${Server-IP}

Infinite_For_Loop
    ${list}=    BuiltIn.Create List    a    b
    FOR    ${count}    IN RANGE    ${Count2}
    Comment    Insert Into List    ${list}    ${Count2}    1
    ${Count2}=    BuiltIn.Evaluate    ${Count2}+1

While
    FOR    True    IN
        ${Count2}=    BuiltIn.Evaluate    ${Count2}+1
    END

Scrape_PutoTV
    Open Browser    https://pluto.tv/on-demand    chrome
    Maximize Browser Window
    Sleep    10s
    Click Element    //div[contains(text(),'Most Popular Movies')]/../div[contains(@class,'Category')]/div[1]/div[contains(@class,'right')]
    Sleep    10s
    Click Element    //div[contains(text(),'Most Popular Movies')]/../div[contains(@class,'Category__contr')]/div[2]/div/div[8]/div/div[contains(text(),'View All')]
    sleep    10s
    Click Element    //*[@id="root"]/div[5]/div[2]/div/div/div/div[1]/div[2]/div/div[1]/div/div
    Sleep    10s
    ${Desc}=    Get Text    css=p.description

Launching browser
    Open Browser    https://reelgood.com/show/the-walking-dead-2010    chrome
    ${Web}=    Get Source
    ${ID}=    String.Fetch From Right    ${Web}    "show_id":"
    ${ID}=    String.Fetch From Left    ${ID}    "}}

*** Keywords ***
Extracting_Text_Employees_New
    [Arguments]    ${count}    ${href__Url}    ${ID_Number}
    ${Text}=    Get Text    //div[${count}]/div/div/div[2]/div/span
    ${SubStrin2}    String.Fetch From Left    ${Text}    employees
    ${SubStrin2}=    String.Strip String    ${SubStrin2}${SPACE}
    ${words}=    String.Split String    ${SubStrin2}    ${SPACE}
    ${word}=    Get From List    ${words}    -1
    ${bool}    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Contain    ${word}    ,
    ${bool}    Get From List    ${bool}    0
    ${Regex_String}=    BuiltIn.Run Keyword If    '${bool}'=='PASS'    String.Get Regexp Matches    ${word}    [0-9]+,[0-9]+
    ...    ELSE    String.Get Regexp Matches    ${word}    [0-9]+
    DatabaseLibrary.Execute Sql String    update urs_aa.linkedin_robot set no_of_employees ='${Regex_String}[0]' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.linkedin_robot set linkedin_url='${href_Url}' where id=${ID_Number};

Inner_For_Loop_Extracting_Employees
    [Arguments]    ${ID_Number}    @{Url_List}
    FOR    ${i}    IN    @{Url_List}
    ${href__Url}=    SeleniumLibrary.Get Element Attribute    ${i}    href
    ${bool}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Contain    ${href__Url}    /company/
    ${bool}    Get From List    ${bool}    0
    BuiltIn.Convert To String    ${bool}
    ${count}=    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Evaluate    ${count}+1
    ...    ELSE    BuiltIn.Evaluate    ${count}+0
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    Extracting_Text_Employees_New    ${count}    ${href__Url}    ${ID_Number}
    BuiltIn.Exit For Loop If    '${bool}'=='PASS'

Inner_For_Loop_Extracting_Followers
    [Arguments]    ${ID_Number}    @{Url_List}
    FOR    ${i}    IN    @{Url_List}
    ${href__Url}=    SeleniumLibrary.Get Element Attribute    ${i}    href
    ${bool}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Contain    ${href__Url}    /company/
    ${bool}    Get From List    ${bool}    0
    BuiltIn.Convert To String    ${bool}
    ${count}=    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Evaluate    ${count}+1
    ...    ELSE    BuiltIn.Evaluate    ${count}+0
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    Extracting_Text_Followers_New    ${count}    ${ID_Number}    ${href__Url}
    BuiltIn.Exit For Loop If    '${bool}'=='PASS'

Extracting_Text_Followers_New
    [Arguments]    ${count}    ${ID_Number}    ${href__Url}
    ${Text}=    Get Text    //div[${count}]/div/div/div[2]/div/span
    ${SubStrin2}    String.Fetch From Left    ${Text}    followers
    ${SubStrin2}=    String.Strip String    ${SubStrin2}${SPACE}
    ${words}=    String.Split String    ${SubStrin2}    ${SPACE}
    ${word}=    Get From List    ${words}    -1
    ${bool}    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Contain    ${word}    ,
    ${bool}    Get From List    ${bool}    0
    ${Regex_String}=    BuiltIn.Run Keyword If    '${bool}'=='PASS'    String.Get Regexp Matches    ${word}    [0-9]+,[0-9]+
    ...    ELSE    String.Get Regexp Matches    ${word}    [0-9]+
    DatabaseLibrary.Execute Sql String    update urs_aa.linkedin_robot set followers= '${Regex_String}[0]' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.linkedin_robot set linkedin_url='${href_Url}' where id=${ID_Number};
