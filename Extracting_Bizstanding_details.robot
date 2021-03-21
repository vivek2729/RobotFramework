*** Settings ***
Resource          resource.robot
Library           SeleniumLibrary
Library           DatabaseLibrary

*** Test Cases ***
Extracting_Details
    DatabaseLibrary.Connect To Database    pymysql    urs_aa    vivek    mail_1234    shashin-urs.csoaie2kvgsc.us-east-1.rds.amazonaws.com    3306
    Open Browser    https://www.google.com    chrome
    Maximize Browser Window
    Click Element    css=input[name='q']
    Input Text    css=input[name='q']    a
    Sleep    5s
    Click Element    //ul/li[1]/div/div[2]/div/span
    Sleep    5s
    : FOR    ${i}    IN RANGE    200
    \    Select Window    Main
    \    DatabaseLibrary.Query    SELECT GET_LOCK('lock1',60);
    \    ${list}=    DatabaseLibrary.Query    select id,company_name,city,status,state from urs_aa.bizstanding \ \ where status='INQueue' limit 1;
    \    Convert To List    ${list}
    \    ${ID_List}    Evaluate    [x[0] for x in ${list}]
    \    ${Name_List}    Evaluate    [x[1] for x in ${list}]
    \    ${City_List}    Evaluate    [x[2] for x in ${list}]
    \    ${Current_Status_List}    Evaluate    [x[3] for x in ${list}]
    \    ${State_List}    Evaluate    [x[4] for x in ${list}]
    \    ${City_Name}=    Get From List    ${City_List}    ${count}
    \    ${Name}=    Get From List    ${Name_List}    ${count}
    \    ${ID_Number}=    Get From List    ${ID_List}    ${count}
    \    ${Current_Status}=    Get From List    ${Current_Status_List}    ${count}
    \    ${State_name}    Get From List    ${State_List}    ${count}
    \    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ \ set status ='Processing' where id=${ID_Number};
    \    Comment    ${Current_Status}=    BuiltIn.Set Variable    Processing
    \    DatabaseLibrary.Query    SELECT RELEASE_LOCK('lock1');
    \    Input Text    css=input[name='q']    site:bizstanding.com ${Name} ${City_Name} ${State_name}
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
    \    ${bool}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Contain    ${href__Url}    bizstanding.com/p
    \    ${bool}    Get From List    ${bool}    0
    \    BuiltIn.Convert To String    ${bool}
    \    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword And Ignore Error    Bizstanding_Details_Extraction    ${href__Url}    ${ID_Number}
    \    BuiltIn.Return From Keyword If    '${bool}'=='PASS'    ${href__Url}
    \    BuiltIn.Exit For Loop If    '${bool}'=='PASS'

Bizstanding_Details_Extraction
    [Arguments]    ${href__Url}    ${ID_Number}
    Execute Javascript    window.open()
    Select Window    NEW
    Go To    ${href__Url}
    Sleep    10s
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_url='${href__Url}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    ${Company_Name}=    Run Keyword And Ignore Error    Get Text    css=font[itemprop='name']
    ${bool}    Get From List    ${Company_Name}    0
    ${Extracted_Company_Name}=    Get From List    ${Company_Name}    1
    ${New_Company_Name}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Company_Name}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ \ set biz_company_name= '${New_Company_Name}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ \ set status ='Processed' where id=${ID_Number};
    ${City_Name}=    Run Keyword And Ignore Error    Get Text    css=span[itemprop='addressLocality']
    ${bool}    Get From List    ${City_Name}    0
    ${Extracted_City_Name}=    Get From List    ${City_Name}    1
    ${New_City_Name}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_City_Name}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_city='${New_City_Name}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    ${State_Nme}=    Run Keyword And Ignore Error    Get Text    css=span[itemprop='addressRegion']
    ${bool}    Get From List    ${State_Nme}    0
    ${Extracted_State_Name}=    Get From List    ${State_Nme}    1
    ${New_State_Name}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_State_Name}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_state='${New_State_Name}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    ${Phone_Number}=    Run Keyword And Ignore Error    Get Text    css=span.ph
    ${bool}    Get From List    ${Phone_Number}    0
    ${Extracted_Phn_Number}=    Get From List    ${Phone_Number}    1
    ${New_Phone_Number}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Phn_Number}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_phone='${New_Phone_Number}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    ${Authorised_Person}    Run Keyword And Ignore Error    Get Text    //span[@class='b-business-item_title'][contains(text(),'Member')]/following-sibling::span
    ${bool}    Get From List    ${Authorised_Person}    0
    ${Extracted_Authorized_Person}=    Get From List    ${Authorised_Person}    1
    ${New_Authorized_Person}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Authorized_Person}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_authorized_person='${New_Authorized_Person}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    ${Website_Link}=    Run Keyword And Ignore Error    Get Text    //span[@class='b-business-item_title'][contains(text(),'Site')]/following-sibling::span/a
    ${bool}    Get From List    ${Website_Link}    0
    ${Extracted_Website_Link}=    Get From List    ${Website_Link}    1
    ${New_Website_Link}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Website_Link}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_website_url='${New_Website_Link}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    ${SIC4}=    Run Keyword And Ignore Error    Get Text    //span[@class='b-business-item_title'][contains(text(),'SIC:')]/following-sibling::span
    ${bool}    Get From List    ${SIC4}    0
    ${Extracted_SIC4}=    Get From List    ${SIC4}    1
    ${New_SIC4}    Set Variable If    '${bool}'=='PASS'    ${Extracted_SIC4}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_sic4='${New_SIC4}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    Comment    ${SCI4}=    String.Fetch From Left    ${New_SIC4}    -
    Comment    ${SCI4_Description}=    String.Fetch From Right    ${New_SIC4}    -
    ${SIC6}=    Run Keyword And Ignore Error    Get Text    //span[@class='b-business-item_title'][contains(text(),'SIC6:')]/following-sibling::span
    ${bool}    Get From List    ${SIC6}    0
    ${Extracted_SIC6}=    Get From List    ${SIC6}    1
    ${New_SIC6}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_SIC6}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_sic6='${New_SIC6}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    Comment    ${SCI6}=    String.Fetch From Left    ${New_SIC6}    -
    Comment    ${SCI6_Description}=    String.Fetch From Right    ${New_SIC6}    -
    ${Year}=    Run Keyword And Ignore Error    Get Text    //span[@class='b-business-item_title'][contains(text(),'In business since:')]/following-sibling::span
    ${bool}    Get From List    ${Year}    0
    ${Extracted_year}=    Get From List    ${Year}    1
    ${New_year}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_year}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_year='${New_year}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    ${Number_Of_Employees}=    Run Keyword And Ignore Error    Get Text    //span[@class='b-business-item_title'][contains(text(),'Company size:')]/following-sibling::span
    ${bool}    Get From List    ${Number_Of_Employees}    0
    ${Ext_Number_Of_Employees}=    Get From List    ${Number_Of_Employees}    1
    ${New_Number_Of_Employees}=    Set Variable If    '${bool}'=='PASS'    ${Ext_Number_Of_Employees}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_employees='${New_Number_Of_Employees}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    ${Address}=    Run Keyword And Ignore Error    Get Text    //span[@class='b-business-item_title'][contains(text(),'Addresses:')]/following-sibling::span
    ${bool}    Get From List    ${Address}    0
    ${Extracted_Address}    Get From List    ${Address}    1
    ${New_Address}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Address}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_address_line='${New_Address}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    ${Zip_Code}=    Run Keyword And Ignore Error    Get Text    css=span[itemprop='postalCode']
    ${bool}    Get From List    ${Zip_Code}    0
    ${Extracted_Zip_Code}=    Get From List    ${Zip_Code}    1
    ${New_Zip_Code}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Zip_Code}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_zip='${New_Zip_Code}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    Close Window
