*** Settings ***
Library           SeleniumLibrary
Library           OperatingSystem
Library           DatabaseLibrary
Resource          resource.robot
Library           DateTime

*** Test Cases ***
Extracting_Glassdoor_Details
    DatabaseLibrary.Connect To Database    pymysql    urs_aa    vivek    mail_1234    shashin-urs.csoaie2kvgsc.us-east-1.rds.amazonaws.com    3306
    Open Browser    https://www.google.com    chrome
    Maximize Browser Window
    Click Element    css=input[name='q']
    Input Text    css=input[name='q']    a
    Sleep    5s
    Click Element    //ul/li[1]/div/div[2]/div/span
    Sleep    5s
    Execute Javascript    window.open()
    Select Window    New
    GoTo    https://www.glassdoor.com/index.htm
    Sleep    5s
    Click Element    css=div.locked-home-sign-in>a
    sleep    5s
    Input Text    css=input#userEmail[title='Email Address']    vkpandeyamd@gmail.com
    Input Text    css=input#userPassword[name='password']    Vikki@2292258
    Click Button    //button[@type='submit'][contains(text(),'Sign In')]
    Sleep    5s
    Close Window
    : FOR    ${i}    IN RANGE    1
    \    Select Window    Main
    \    DatabaseLibrary.Query    SELECT GET_LOCK('lock1',60);
    \    ${list}=    DatabaseLibrary.Query    select id,company_name from urs_aa.glassdoor where id=2
    \    Convert To List    ${list}
    \    ${ID_List}    Evaluate    [x[0] for x in ${list}]
    \    ${Name_List}    Evaluate    [x[1] for x in ${list}]
    \    ${Name}=    Get From List    ${Name_List}    ${count}
    \    ${ID_Number}=    Get From List    ${ID_List}    ${count}
    \    DatabaseLibrary.Execute Sql String    update urs_aa.glassdoor set status ='Processing' where id=${ID_Number};
    \    ${Current_Status}=    BuiltIn.Set Variable    Processing
    \    DatabaseLibrary.Query    SELECT RELEASE_LOCK('lock1');
    \    Input Text    css=input[name='q']    site glassdoor.com ${Name} overview
    \    Sleep    10s
    \    Click Element    css=button[aria-label='Google Search']
    \    Sleep    10s
    \    @{Url_List}    SeleniumLibrary.Get WebElements    css=div.r>a
    \    BuiltIn.Run Keyword And Ignore Error    Inner_Loop    ${ID_Number}    @{Url_List}
    DatabaseLibrary.Disconnect From Database
    Close All Browsers

*** Keywords ***
Inner_Loop
    [Arguments]    ${ID_Number}    @{Url_List}
    : FOR    ${j}    IN    @{Url_List}
    \    ${href__Url}=    SeleniumLibrary.Get Element Attribute    ${j}    href
    \    ${bool}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Contain    ${href__Url}    www.glassdoor.com/Overview
    \    ${bool}    Get From List    ${bool}    0
    \    BuiltIn.Convert To String    ${bool}
    \    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword And Ignore Error    Glassdoor_Details_Extraction    ${href__Url}    ${ID_Number}
    \    BuiltIn.Return From Keyword If    '${bool}'=='PASS'    ${href__Url}
    \    BuiltIn.Exit For Loop If    '${bool}'=='PASS'

Glassdoor_Details_Extraction
    [Arguments]    ${href__Url}    ${ID_Number}
    Execute Javascript    window.open()
    Select Window    NEW
    Go To    ${href__Url}
    Sleep    10s
    DatabaseLibrary.Execute Sql String    update urs_aa.glassdoor set glassdoor_url='${href__Url}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.glassdoor set status ='Processed' where id=${ID_Number};
    ${Company_Name}=    Run Keyword And Ignore Error    Get Text    css=h1[data-company]>span
    ${bool}    Get From List    ${Company_Name}    0
    ${Extracted_Company_Name}=    Get From List    ${Company_Name}    1
    ${New_Company_Name}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Company_Name}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.glassdoor \ set company_scraped_name= '${New_Company_Name}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.glassdoor set status ='Processed' where id=${ID_Number};
    ${WebSite_Name}=    Run Keyword And Ignore Error    Get Text    css=span.value.website>a
    ${bool}    Get From List    ${WebSite_Name}    0
    ${Extracted_WebSite_Name}=    Get From List    ${WebSite_Name}    1
    ${New_WebSite_Name}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_WebSite_Name}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.glassdoor set website='${New_WebSite_Name}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.glassdoor set status ='Processed' where id=${ID_Number};
    ${HeadQuarter_Name}=    Run Keyword And Ignore Error    Get Text    //label[contains(text(),'Headquarters')]/following-sibling::span[@class='value']
    ${bool}    Get From List    ${HeadQuarter_Name}    0
    ${Extracted_HQ_Name}=    Get From List    ${HeadQuarter_Name}    1
    ${New_HQ_Name}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_HQ_Name}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.glassdoor set headquarters='${New_HQ_Name}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.glassdoor set status ='Processed' where id=${ID_Number};
    ${Size}=    Run Keyword And Ignore Error    Get Text    //label[contains(text(),'Size')]/following-sibling::span[@class='value']
    ${bool}    Get From List    ${Size}    0
    ${Extracted_Size}=    Get From List    ${Size}    1
    ${New_Size}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Size}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.glassdoor set size='${New_Size}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.glassdoor set status ='Processed' where id=${ID_Number};
    ${Type}=    Run Keyword And Ignore Error    Get Text    //label[contains(text(),'Type')]/following-sibling::span[@class='value']
    ${bool}    Get From List    ${Type}    0
    ${Extracted_Type}=    Get From List    ${Type}    1
    ${New_Type}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Type}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.glassdoor set type='${New_Type}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.glassdoor set status ='Processed' where id=${ID_Number};
    ${Founded}=    Run Keyword And Ignore Error    Get Text    //label[contains(text(),'Founded')]/following-sibling::span[@class='value']
    ${bool}    Get From List    ${Founded}    0
    ${Extracted_Founded}=    Get From List    ${Founded}    1
    ${New_Founded}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Founded}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.glassdoor set founded='${New_Founded}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.glassdoor set status ='Processed' where id=${ID_Number};
    ${Industry}=    Run Keyword And Ignore Error    Get Text    //label[contains(text(),'Industry')]/following-sibling::span[@class='value']
    ${bool}    Get From List    ${Industry}    0
    ${Extracted_Industry}=    Get From List    ${Industry}    1
    ${New_Industry}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Industry}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.glassdoor set industry='${New_Industry}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.glassdoor set status ='Processed' where id=${ID_Number};
    ${Revenue}=    Run Keyword And Ignore Error    Get Text    //label[contains(text(),'Revenue')]/following-sibling::span[@class='value']
    ${bool}    Get From List    ${Revenue}    0
    ${Extracted_Revenue}=    Get From List    ${Revenue}    1
    ${New_Revenue}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Revenue}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.glassdoor set revenue='${New_Revenue}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.glassdoor set status ='Processed' where id=${ID_Number};
    ${Competitor}=    Run Keyword And Ignore Error    Get Text    css=p.m-0
    ${bool}    Get From List    ${Competitor}    0
    ${Extracted_Competitor}=    Get From List    ${Competitor}    1
    ${New_Competitor}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Competitor}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.glassdoor set competitors='${New_Competitor}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.glassdoor set status ='Processed' where id=${ID_Number};
