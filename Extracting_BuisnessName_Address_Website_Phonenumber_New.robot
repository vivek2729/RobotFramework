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
    \    DatabaseLibrary.Query    SELECT GET_LOCK('lock1',60);
    \    ${list}=    DatabaseLibrary.Query    select id,company_name, city, complete_state ,status,address,zip from urs_aa.google where status='InQueue' limit 1;
    \    Convert To List    ${list}
    \    ${ID_List}    Evaluate    [x[0] for x in ${list}]
    \    ${Name_List}    Evaluate    [x[1] for x in ${list}]
    \    ${City_List}    Evaluate    [x[2] for x in ${list}]
    \    ${State_List}    Evaluate    [x[3] for x in ${list}]
    \    ${Current_Status_List}    Evaluate    [x[4] for x in ${list}]
    \    ${Address_List}    Evaluate    [x[5] for x in ${list}]
    \    ${zip_List}    Evaluate    [x[6] for x in ${list}]
    \    ${City_Name}=    Get From List    ${City_List}    ${count}
    \    ${Name}=    Get From List    ${Name_List}    ${count}
    \    ${State_Name}=    Get From List    ${State_List}    ${count}
    \    ${ID_Number}=    Get From List    ${ID_List}    ${count}
    \    ${Current_Status}=    Get From List    ${Current_Status_List}    ${count}
    \    ${Address}=    Get From List    ${Address_List}    ${count}
    \    ${zip}=    Get From List    ${zip_List}    ${count}
    \    DatabaseLibrary.Execute Sql String    update urs_aa.google set status ='Processing' where id=${ID_Number};
    \    ${Current_Status}=    BuiltIn.Set Variable    Processing
    \    DatabaseLibrary.Query    SELECT RELEASE_LOCK('lock1');
    \    Run Keyword And Ignore Error    Extracting__Details_With_Name_Address_City_And_State    ${ID_Number}    ${Name}    ${Address}    ${City_Name}
    \    ...    ${State_Name}
    \    Run Keyword And Ignore Error    Extracting__Details_With_Name_City_And_State    ${ID_Number}    ${Name}    ${City_Name}    ${State_Name}
    \    Run Keyword And Ignore Error    Extracting__Details_With_Name_And_ZipCode    ${ID_Number}    ${Name}    ${zip}
    \    Run Keyword And Ignore Error    Extracting__Details_With_Name_Address_City    ${ID_Number}    ${Name}    ${Address}    ${City_Name}
    \    Run Keyword And Ignore Error    Extracting__Details_With_Name    ${ID_Number}    ${Name}
    DatabaseLibrary.Disconnect From Database
    Close All Browsers

*** Keywords ***
Extracting__Details_With_Name_Address_City_And_State
    [Arguments]    ${ID_Number}    ${Name}    ${Address}    ${City_Name}    ${State_Name}
    Input Text    css=input[name='q']    ${Name} ${Address} ${City_Name} ${State_Name}
    Sleep    30s
    Click Element    css=button[aria-label='Google Search']
    Sleep    30s
    ${Buisness_Name}=    BuiltIn.Run Keyword And Ignore Error    Get Text    css=div[data-attrid='title']>span
    ${bool}    Get From List    ${Buisness_Name}    0
    ${Extracted_Buisness_Name}=    Get From List    ${Buisness_Name}    1
    ${New_Buisness_Name}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Buisness_Name}
    ${New_Buisness_Name}=    String.Replace String    ${New_Buisness_Name}    '    ''
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.google set google_company_name_1= '${New_Buisness_Name}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.google set status ='Processed' where id=${ID_Number};
    ${Phone_Number}=    BuiltIn.Run Keyword And Ignore Error    Get Text    css=div[data-attrid='kc:/collection/knowledge_panels/has_phone:phone']>div>div>span:nth-child(2)>span>span
    ${bool}    Get From List    ${Phone_Number}    0
    ${Extracted_Phone_Number}=    Get From List    ${Phone_Number}    1
    ${New_Phone_Number}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Phone_Number}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.google set google_phone_1= '${New_Phone_Number}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.google set status ='Processed' where id=${ID_Number};
    ${Website_Link}=    BuiltIn.Run Keyword And Ignore Error    Get Element Attribute    //a[contains(text(),'Website')]    href
    ${bool}    Get From List    ${Website_Link}    0
    ${Extracted_Website_Link}=    Get From List    ${Website_Link}    1
    ${New_Website_Link}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Website_Link}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.google set google_website_1= '${New_Website_Link}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.google set status ='Processed' where id=${ID_Number};
    ${Address}=    BuiltIn.Run Keyword And Ignore Error    Get Text    css=div[data-attrid='kc:/location/location:address']>div>div>span:nth-child(2)
    ${bool}    Get From List    ${Address}    0
    ${Extracted_Address}=    Get From List    ${Address}    1
    ${New_Address}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Address}
    ${New_Address}=    String.Replace String    ${New_Address}    '    ''
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.google set google_address_1= '${New_Address}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.google set status ='Processed' where id=${ID_Number};

Extracting__Details_With_Name_City_And_State
    [Arguments]    ${ID_Number}    ${Name}    ${City_Name}    ${State_Name}
    Input Text    css=input[name='q']    ${Name} ${City_Name} ${State_Name}
    Sleep    30s
    Click Element    css=button[aria-label='Google Search']
    Sleep    30s
    ${Buisness_Name}=    BuiltIn.Run Keyword And Ignore Error    Get Text    css=div[data-attrid='title']>span
    ${bool}    Get From List    ${Buisness_Name}    0
    ${Extracted_Buisness_Name}=    Get From List    ${Buisness_Name}    1
    ${New_Buisness_Name}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Buisness_Name}
    ${New_Buisness_Name}=    String.Replace String    ${New_Buisness_Name}    '    ''
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.google set google_company_name_2= '${New_Buisness_Name}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.google set status ='Processed' where id=${ID_Number};
    ${Phone_Number}=    BuiltIn.Run Keyword And Ignore Error    Get Text    css=div[data-attrid='kc:/collection/knowledge_panels/has_phone:phone']>div>div>span:nth-child(2)>span>span
    ${bool}    Get From List    ${Phone_Number}    0
    ${Extracted_Phone_Number}=    Get From List    ${Phone_Number}    1
    ${New_Phone_Number}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Phone_Number}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.google set google_phone_2= '${New_Phone_Number}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.google set status ='Processed' where id=${ID_Number};
    ${Website_Link}=    BuiltIn.Run Keyword And Ignore Error    Get Element Attribute    //a[contains(text(),'Website')]    href
    ${bool}    Get From List    ${Website_Link}    0
    ${Extracted_Website_Link}=    Get From List    ${Website_Link}    1
    ${New_Website_Link}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Website_Link}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.google set google_website_2= '${New_Website_Link}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.google set status ='Processed' where id=${ID_Number};
    ${Address}=    BuiltIn.Run Keyword And Ignore Error    Get Text    css=div[data-attrid='kc:/location/location:address']>div>div>span:nth-child(2)
    ${bool}    Get From List    ${Address}    0
    ${Extracted_Address}=    Get From List    ${Address}    1
    ${New_Address}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Address}
    ${New_Address}=    String.Replace String    ${New_Address}    '    ''
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.google set google_address_2= '${New_Address}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.google set status ='Processed' where id=${ID_Number};

Extracting__Details_With_Name_And_ZipCode
    [Arguments]    ${ID_Number}    ${Name}    ${zip}
    Input Text    css=input[name='q']    ${Name} ${zip}
    Sleep    30s
    Click Element    css=button[aria-label='Google Search']
    Sleep    30s
    ${Buisness_Name}=    BuiltIn.Run Keyword And Ignore Error    Get Text    css=div[data-attrid='title']>span
    ${bool}    Get From List    ${Buisness_Name}    0
    ${Extracted_Buisness_Name}=    Get From List    ${Buisness_Name}    1
    ${New_Buisness_Name}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Buisness_Name}
    ${New_Buisness_Name}=    String.Replace String    ${New_Buisness_Name}    '    ''
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.google set google_company_name_3= '${New_Buisness_Name}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.google set status ='Processed' where id=${ID_Number};
    ${Phone_Number}=    BuiltIn.Run Keyword And Ignore Error    Get Text    css=div[data-attrid='kc:/collection/knowledge_panels/has_phone:phone']>div>div>span:nth-child(2)>span>span
    ${bool}    Get From List    ${Phone_Number}    0
    ${Extracted_Phone_Number}=    Get From List    ${Phone_Number}    1
    ${New_Phone_Number}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Phone_Number}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.google set google_phone_3= '${New_Phone_Number}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.google set status ='Processed' where id=${ID_Number};
    ${Website_Link}=    BuiltIn.Run Keyword And Ignore Error    Get Element Attribute    //a[contains(text(),'Website')]    href
    ${bool}    Get From List    ${Website_Link}    0
    ${Extracted_Website_Link}=    Get From List    ${Website_Link}    1
    ${New_Website_Link}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Website_Link}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.google set google_website_3= '${New_Website_Link}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.google set status ='Processed' where id=${ID_Number};
    ${Address}=    BuiltIn.Run Keyword And Ignore Error    Get Text    css=div[data-attrid='kc:/location/location:address']>div>div>span:nth-child(2)
    ${bool}    Get From List    ${Address}    0
    ${Extracted_Address}=    Get From List    ${Address}    1
    ${New_Address}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Address}
    ${New_Address}=    String.Replace String    ${New_Address}    '    ''
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.google set google_address_3= '${New_Address}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.google set status ='Processed' where id=${ID_Number};

Extracting__Details_With_Name_Address_City
    [Arguments]    ${ID_Number}    ${Name}    ${Address}    ${City_Name}
    Input Text    css=input[name='q']    ${Name} ${Address} ${City_Name}
    Sleep    30s
    Click Element    css=button[aria-label='Google Search']
    Sleep    30s
    ${Buisness_Name}=    BuiltIn.Run Keyword And Ignore Error    Get Text    css=div[data-attrid='title']>span
    ${bool}    Get From List    ${Buisness_Name}    0
    ${Extracted_Buisness_Name}=    Get From List    ${Buisness_Name}    1
    ${New_Buisness_Name}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Buisness_Name}
    ${New_Buisness_Name}=    String.Replace String    ${New_Buisness_Name}    '    ''
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.google set google_company_name_4= '${New_Buisness_Name}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.google set status ='Processed' where id=${ID_Number};
    ${Phone_Number}=    BuiltIn.Run Keyword And Ignore Error    Get Text    css=div[data-attrid='kc:/collection/knowledge_panels/has_phone:phone']>div>div>span:nth-child(2)>span>span
    ${bool}    Get From List    ${Phone_Number}    0
    ${Extracted_Phone_Number}=    Get From List    ${Phone_Number}    1
    ${New_Phone_Number}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Phone_Number}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.google set google_phone_4= '${New_Phone_Number}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.google set status ='Processed' where id=${ID_Number};
    ${Website_Link}=    BuiltIn.Run Keyword And Ignore Error    Get Element Attribute    //a[contains(text(),'Website')]    href
    ${bool}    Get From List    ${Website_Link}    0
    ${Extracted_Website_Link}=    Get From List    ${Website_Link}    1
    ${New_Website_Link}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Website_Link}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.google set google_website_4= '${New_Website_Link}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.google set status ='Processed' where id=${ID_Number};
    ${Address}=    BuiltIn.Run Keyword And Ignore Error    Get Text    css=div[data-attrid='kc:/location/location:address']>div>div>span:nth-child(2)
    ${bool}    Get From List    ${Address}    0
    ${Extracted_Address}=    Get From List    ${Address}    1
    ${New_Address}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Address}
    ${New_Address}=    String.Replace String    ${New_Address}    '    ''
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.google set google_address_4= '${New_Address}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.google set status ='Processed' where id=${ID_Number};

Extracting__Details_With_Name
    [Arguments]    ${ID_Number}    ${Name}
    Input Text    css=input[name='q']    ${Name}
    Sleep    30s
    Click Element    css=button[aria-label='Google Search']
    Sleep    30s
    ${Buisness_Name}=    BuiltIn.Run Keyword And Ignore Error    Get Text    css=div[data-attrid='title']>span
    ${bool}    Get From List    ${Buisness_Name}    0
    ${Extracted_Buisness_Name}=    Get From List    ${Buisness_Name}    1
    ${New_Buisness_Name}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Buisness_Name}
    ${New_Buisness_Name}=    String.Replace String    ${New_Buisness_Name}    '    ''
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.google set google_company_name_5= '${New_Buisness_Name}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.google set status ='Processed' where id=${ID_Number};
    ${Phone_Number}=    BuiltIn.Run Keyword And Ignore Error    Get Text    css=div[data-attrid='kc:/collection/knowledge_panels/has_phone:phone']>div>div>span:nth-child(2)>span>span
    ${bool}    Get From List    ${Phone_Number}    0
    ${Extracted_Phone_Number}=    Get From List    ${Phone_Number}    1
    ${New_Phone_Number}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Phone_Number}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.google set google_phone_5= '${New_Phone_Number}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.google set status ='Processed' where id=${ID_Number};
    ${Website_Link}=    BuiltIn.Run Keyword And Ignore Error    Get Element Attribute    //a[contains(text(),'Website')]    href
    ${bool}    Get From List    ${Website_Link}    0
    ${Extracted_Website_Link}=    Get From List    ${Website_Link}    1
    ${New_Website_Link}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Website_Link}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.google set google_website_5= '${New_Website_Link}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.google set status ='Processed' where id=${ID_Number};
    ${Address}=    BuiltIn.Run Keyword And Ignore Error    Get Text    css=div[data-attrid='kc:/location/location:address']>div>div>span:nth-child(2)
    ${bool}    Get From List    ${Address}    0
    ${Extracted_Address}=    Get From List    ${Address}    1
    ${New_Address}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Address}
    ${New_Address}=    String.Replace String    ${New_Address}    '    ''
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.google set google_address_5= '${New_Address}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.google set status ='Processed' where id=${ID_Number};
