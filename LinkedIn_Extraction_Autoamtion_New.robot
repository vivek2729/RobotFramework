*** Settings ***
Library           SeleniumLibrary
Library           DatabaseLibrary
Resource          resource.robot

*** Test Cases ***
Extracting_Number_Of_Employees_Followers
    DatabaseLibrary.Connect To Database    pymysql    urs_aa    vivek    mail_1234    shashin-urs.csoaie2kvgsc.us-east-1.rds.amazonaws.com    3306
    Open Browser    https://www.google.com    chrome
    Maximize Browser Window
    Click Element    css=input[name='q']
    Input Text    css=input[name='q']    a
    Sleep    5s
    Click Element    //ul/li[1]/div/div[2]/div/span
    Sleep    5s
    Execute Javascript    window.open()
    Select Window    NEW
    Go To    https://www.google.com
    Click Element    css=input[name='q']
    Input Text    css=input[name='q']    a
    Sleep    5s
    Click Element    //ul/li[1]/div/div[2]/div/span
    Sleep    5s
    : FOR    ${i}    IN RANGE    999999
    \    DatabaseLibrary.Query    SELECT GET_LOCK('lock1',10);
    \    ${list}=    DatabaseLibrary.Query    select id,company_name, city, state ,status from urs_aa.linkedin_robot where status='INQueue' limit 1 ;
    \    Convert To List    ${list}
    \    ${ID_List}    Evaluate    [x[0] for x in ${list}]
    \    ${Name_List}    Evaluate    [x[1] for x in ${list}]
    \    ${City_List}    Evaluate    [x[2] for x in ${list}]
    \    ${State_List}    Evaluate    [x[3] for x in ${list}]
    \    ${Current_Status}    Evaluate    [x[4] for x in ${list}]
    \    ${City_Name}=    Get From List    ${City_List}    ${count}
    \    ${Name}=    Get From List    ${Name_List}    ${count}
    \    ${State_Name}=    Get From List    ${State_List}    ${count}
    \    ${ID_Number}=    Get From List    ${ID_List}    ${count}
    \    ${Current_Statuss}=    Get From List    ${Current_Status}    ${count}
    \    DatabaseLibrary.Execute Sql String    update urs_aa.linkedin_robot set status ='Processing' where id=${ID_Number};
    \    ${Current_Statuss}=    BuiltIn.Set Variable    Processing
    \    DatabaseLibrary.Query    SELECT RELEASE_LOCK('lock1');
    \    Select Window    MAIN
    \    Input Text    css=input[name='q']    site:linkedin.com ${Name} ${City_Name} employees
    \    Sleep    60s
    \    Click Element    css=button[aria-label='Google Search']
    \    Sleep    60s
    \    @{Url_List}    SeleniumLibrary.Get WebElements    css=div.r>a
    \    ${href}=    BuiltIn.Run Keyword And Ignore Error    Inner_For_Loop_Extracting_Employees_Via_City    ${ID_Number}    ${Name}    @{Url_List}
    \    ...    BuiltIn.Return From Keyword
    \    ${IsEmployeeContainsHref}=    Get From List    ${href}    0
    \    ${HREF_EMPLOYEE}=    Get From List    ${href}    1
    \    BuiltIn.Run Keyword If    '${IsEmployeeContainsHref}'=='PASS'    BuiltIn.Run Keyword And Ignore Error    Inner_For_Loop_Extracting_Followers_Via_City    ${ID_Number}    ${HREF_EMPLOYEE}
    \    ...    ${Name}    ${City_Name}
    \    BuiltIn.Run Keyword If    '${Current_Statuss}'=='Processing'    Status_Verification    ${ID_Number}    ${Name}    ${State_Name}
    \    ${count1}=    BuiltIn.Evaluate    ${count1}+1
    DatabaseLibrary.Disconnect From Database
    Close All Browsers

*** Keywords ***
Inner_For_Loop_Extracting_Employees_Via_City
    [Arguments]    ${ID_Number}    ${Name}    @{Url_List}
    : FOR    ${j}    IN    @{Url_List}
    \    ${words}=    String.Split String    ${Name}    ${SPACE}
    \    ${word}=    Get From List    ${words}    0
    \    ${word}=    String.Convert To Lowercase    ${word}
    \    ${href__Url}=    SeleniumLibrary.Get Element Attribute    ${j}    href
    \    ${bool}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Contain    ${href__Url}    linkedin.com/company/${word}
    \    ${bool}    Get From List    ${bool}    0
    \    BuiltIn.Convert To String    ${bool}
    \    ${count}=    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Evaluate    ${count}+1
    \    ...    ELSE    BuiltIn.Evaluate    ${count}+0
    \    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword And Ignore Error    Extracting_Text_Employees    ${href__Url}    ${count}
    \    ...    ${ID_Number}
    \    BuiltIn.Return From Keyword If    '${bool}'=='PASS'    ${href__Url}
    \    BuiltIn.Exit For Loop If    '${bool}'=='PASS'

Extracting_Text_Employees
    [Arguments]    ${href__Url}    ${count}    ${ID_Number}
    ${Text}=    Get Text    //div[${count}]/div/div/div[2]/div/span
    ${SubStrin2}    String.Fetch From Left    ${Text}    employees
    ${SubStrin2}=    String.Strip String    ${SubStrin2}${SPACE}
    ${words}=    String.Split String    ${SubStrin2}    ${SPACE}
    ${word}=    Get From List    ${words}    -1
    ${bool}    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Contain    ${word}    ,
    ${bool}    Get From List    ${bool}    0
    ${Number_OF_Employee}=    BuiltIn.Run Keyword If    '${bool}'=='PASS'    String.Get Regexp Matches    ${word}    [0-9]+,[0-9]+
    ...    ELSE    String.Get Regexp Matches    ${word}    [0-9]+
    ${SubStrin2}=    Get Text    //div[${count}]/div/div/div[@class='r']/a/h3
    ${SubStrin2}=    String.Fetch From Left    ${SubStrin2}    |
    ${linkedIN_CompanyName}=    String.Strip String    ${SubStrin2}${SPACE}
    DatabaseLibrary.Execute Sql String    update urs_aa.linkedin_robot set no_of_employees ='${Number_OF_Employee}[0]' \ where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.linkedin_robot set linkedin_url_employees ='${href_Url}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.linkedin_robot set linkedin_company_name ='${linkedIN_CompanyName}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.linkedin_robot set status ='Processed' where id=${ID_Number};
    ${Current_Statuss}=    BuiltIn.Set Variable    Processed

Inner_For_Loop_Extracting_Followers_Via_City
    [Arguments]    ${ID_Number}    ${HREF_EMPLOYEE}    ${Name}    ${City_Name}
    Select Window    NEW
    Input Text    css=input[name='q']    site:linkedin.com ${Name} ${City_Name} followers
    Sleep    60s
    Click Element    css=button[aria-label='Google Search']
    Sleep    60s
    @{Url_List}    SeleniumLibrary.Get WebElements    css=div.r>a
    : FOR    ${i}    IN    @{Url_List}
    \    ${href__Url}=    SeleniumLibrary.Get Element Attribute    ${i}    href
    \    ${bool}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Be Equal As Strings    ${href__Url}    ${HREF_EMPLOYEE}
    \    ${bool}    Get From List    ${bool}    0
    \    BuiltIn.Convert To String    ${bool}
    \    ${count}=    Evaluate    ${count}+1
    \    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword And Ignore Error    Extracting_Text_Followers    ${count}    ${ID_Number}
    \    ...    ${href__Url}
    \    BuiltIn.Exit For Loop If    '${bool}'=='PASS'

Extracting_Text_Followers
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
    ${SubStrin2}=    Get Text    //div[${count}]/div/div/div[@class='r']/a/h3
    ${SubStrin2}=    String.Fetch From Left    ${SubStrin2}    |
    ${linkedIN_CompanyName}=    String.Strip String    ${SubStrin2}${SPACE}
    DatabaseLibrary.Execute Sql String    update urs_aa.linkedin_robot set followers= '${Regex_String}[0]' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.linkedin_robot set linkedin_url_followers ='${href_Url}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.linkedin_robot set linkedin_company_name ='${linkedIN_CompanyName}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.linkedin_robot set status ='Processed' where id=${ID_Number};
    ${Current_Statuss}=    BuiltIn.Set Variable    Processed

Inner_For_Loop_Extracting_Emploees_Via_State_Name
    [Arguments]    ${ID_Number}    ${Name}    ${State_Name}    @{Url_New_List}
    : FOR    ${j}    IN    @{Url_New_List}
    \    ${words}=    String.Split String    ${Name}    ${SPACE}
    \    ${word}=    Get From List    ${words}    0
    \    ${word}=    String.Convert To Lowercase    ${word}
    \    ${href__Url}=    SeleniumLibrary.Get Element Attribute    ${j}    href
    \    ${bool}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Contain    ${href__Url}    linkedin.com/company/${word}
    \    ${bool}    Get From List    ${bool}    0
    \    BuiltIn.Convert To String    ${bool}
    \    ${count}=    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Evaluate    ${count}+1
    \    ...    ELSE    BuiltIn.Evaluate    ${count}+0
    \    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword And Ignore Error    Extracting_Text_Employees    ${href__Url}    ${count}
    \    ...    ${ID_Number}
    \    BuiltIn.Return From Keyword If    '${bool}'=='PASS'    ${href__Url}
    \    BuiltIn.Exit For Loop If    '${bool}'=='PASS'

Inner_For_Loop_Extracting_Followers_Via_State_Name
    [Arguments]    ${ID_Number}    ${HREF_EMPLOYEE}    ${Name}    ${State_Name}
    Select Window    NEW
    Input Text    css=input[name='q']    site:linkedin.com ${Name} ${State_Name} followers
    Sleep    60s
    Click Element    css=button[aria-label='Google Search']
    Sleep    60s
    @{Url_List}    SeleniumLibrary.Get WebElements    css=div.r>a
    : FOR    ${i}    IN    @{Url_List}
    \    ${href__Url}=    SeleniumLibrary.Get Element Attribute    ${i}    href
    \    ${bool}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Be Equal As Strings    ${href__Url}    ${HREF_EMPLOYEE}
    \    ${bool}    Get From List    ${bool}    0
    \    BuiltIn.Convert To String    ${bool}
    \    ${count}=    Evaluate    ${count}+1
    \    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword And Ignore Error    Extracting_Text_Followers    ${count}    ${ID_Number}
    \    ...    ${href__Url}
    \    BuiltIn.Exit For Loop If    '${bool}'=='PASS'

Status_Verification
    [Arguments]    ${ID_Number}    ${Name}    ${State_Name}
    Select Window    MAIN
    Input Text    css=input[name='q']    site:linkedin.com ${Name} ${State_Name} employees
    Sleep    60s
    Click Element    css=button[aria-label='Google Search']
    Sleep    60s
    @{Url_New_List}    SeleniumLibrary.Get WebElements    css=div.r>a
    ${href}=    BuiltIn.Run Keyword And Ignore Error    Inner_For_Loop_Extracting_Emploees_Via_State_Name    ${ID_Number}    ${Name}    ${State_Name}    @{Url_New_List}
    ...    BuiltIn.Return From Keyword
    ${IsEmployeeContainsHref}=    Get From List    ${href}    0
    ${HREF_EMPLOYEE}=    Get From List    ${href}    1
    BuiltIn.Run Keyword If    '${IsEmployeeContainsHref}'=='PASS'    BuiltIn.Run Keyword And Ignore Error    Inner_For_Loop_Extracting_Followers_Via_State_Name    ${ID_Number}    ${HREF_EMPLOYEE}    ${Name}
    ...    ${State_Name}
