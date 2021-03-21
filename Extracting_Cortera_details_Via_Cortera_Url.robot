*** Settings ***
Resource          resource.robot
Library           SeleniumLibrary
Library           DatabaseLibrary

*** Test Cases ***
Extracting_Details
    DatabaseLibrary.Connect To Database    pymysql    urs_aa    vivek    mail_1234    shashin-urs.csoaie2kvgsc.us-east-1.rds.amazonaws.com    3306
    Open Browser    https://www.google.com    chrome
    Maximize Browser Window
    Sleep    5s
    Click Element    css=input[name='q']
    Input Text    css=input[name='q']    a
    Sleep    5s
    Click Element    //ul/li[1]/div/div[2]/div/span
    Sleep    5s
    : FOR    ${i}    IN RANGE    5
    \    Select Window    Main
    \    DatabaseLibrary.Query    SELECT GET_LOCK('lock1',60);
    \    ${list}=    DatabaseLibrary.Query    select id,company_name,city,status,state from urs_aa.cortera where status='InQueue' limit 1;
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
    \    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processing' where id=${ID_Number};
    \    DatabaseLibrary.Query    SELECT RELEASE_LOCK('lock1');
    \    Input Text    css=input[name='q']    site:start.cortera.com ${Name} ${City_Name} ${State_name}
    \    Sleep    10s
    \    Click Element    css=button[aria-label='Google Search']
    \    Sleep    10s
    \    @{Url_List}    SeleniumLibrary.Get WebElements    css=div.r>a
    \    BuiltIn.Run Keyword And Ignore Error    Inner_Loop    ${ID_Number}    @{Url_List}
    Disconnect From Database
    Close All Browsers

*** Keywords ***
Inner_Loop
    [Arguments]    ${ID_Number}    @{Url_List}
    : FOR    ${j}    IN    @{Url_List}
    \    ${href__Url}=    SeleniumLibrary.Get Element Attribute    ${j}    href
    \    ${bool}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Contain    ${href__Url}    start.cortera.com/company/research
    \    ${bool}    Get From List    ${bool}    0
    \    BuiltIn.Convert To String    ${bool}
    \    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword And Ignore Error    Cortera_Details_Extraction    ${href__Url}    ${ID_Number}
    \    BuiltIn.Return From Keyword If    '${bool}'=='PASS'    ${href__Url}
    \    BuiltIn.Exit For Loop If    '${bool}'=='PASS'

Cortera_Details_Extraction
    [Arguments]    ${href__Url}    ${ID_Number}
    Execute Javascript    window.open()
    Select Window    NEW
    Go To    ${href__Url}
    Sleep    10s
    DatabaseLibrary.Execute Sql String    update urs_aa.cortera \ set cor_url='${href__Url}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};
    ${Company_Name}=    Run Keyword And Ignore Error    Get Text    css=span[itemprop='name']
    ${bool}    Get From List    ${Company_Name}    0
    ${Extracted_Company_Name}=    Get From List    ${Company_Name}    1
    ${New_Company_Name}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Company_Name}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera \ set cor_company_name= '${New_Company_Name}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};
    ${Phone_Number}=    Run Keyword And Ignore Error    Get Text    css=div[itemprop='telephone']
    ${bool}    Get From List    ${Phone_Number}    0
    ${Extracted_Phn_Number}=    Get From List    ${Phone_Number}    1
    ${New_Phone_Number}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Phn_Number}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set cor_phone='${New_Phone_Number}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};
    ${Website_Link}=    Run Keyword And Ignore Error    Get Element Attribute    css=a[itemprop='url']    href
    ${bool}    Get From List    ${Website_Link}    0
    ${Extracted_Website_Link}=    Get From List    ${Website_Link}    1
    ${New_Website_Link}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Website_Link}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set cor_website_url='${New_Website_Link}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};
    ${SIC4}=    Run Keyword And Ignore Error    Get Text    //div/strong[contains(text(),'Industry:')]
    ${bool}    Get From List    ${SIC4}    0
    ${Extracted_SIC4}=    Get From List    ${SIC4}    1
    ${New_SIC4_O}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_SIC4}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set cor_sic_desc='${New_SIC4_O}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};
    ${Year}=    Run Keyword And Ignore Error    Get Text    //div/strong[contains(text(),'Year Founded:')]
    ${bool}    Get From List    ${Year}    0
    ${Extracted_year}=    Get From List    ${Year}    1
    ${New_year}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_year}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set cor_year='${New_year}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};
    ${Number_Of_Employees}=    Run Keyword And Ignore Error    Get Text    //div/strong[contains(text(),'Employees:')]
    ${bool}    Get From List    ${Number_Of_Employees}    0
    ${Ext_Number_Of_Employees}=    Get From List    ${Number_Of_Employees}    1
    ${New_Number_Of_Employees}=    Set Variable If    '${bool}'=='PASS'    ${Ext_Number_Of_Employees}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set cor_employees='${New_Number_Of_Employees}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};
    ${Nature_Type}=    Run Keyword And Ignore Error    Get Text    //div/strong[contains(text(),'Location Type:')]
    ${bool}    Get From List    ${Nature_Type}    0
    ${Extracted_Nature_Type}=    Get From List    ${Nature_Type}    1
    ${New_Nature_Type}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Nature_Type}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set cor_nature='${New_Nature_Type}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};
    ${Turn_Over}=    Run Keyword And Ignore Error    Get Text    //div/strong[contains(text(),'Sales Range:')]
    ${bool}    Get From List    ${Turn_Over}    0
    ${Extracted_Turn_Over}=    Get From List    ${Turn_Over}    1
    ${New_Turn_Over}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Turn_Over}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set cor_turnover='${New_Turn_Over}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};
    ${Address_1}=    Run Keyword And Ignore Error    Get Text    css=div[itemprop='streetAddress']
    ${bool}    Get From List    ${Address_1}    0
    ${Extracted_Address_1}    Get From List    ${Address_1}    1
    ${New_Address_1}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Address_1}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera \ set cor_address_line='${New_Address_1}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};
    ${Zip_Code_1}=    Run Keyword And Ignore Error    Get Text    span[itemprop='postalCode']
    ${bool}    Get From List    ${Zip_Code_1}    0
    ${Extracted_Zip_Code_1}=    Get From List    ${Zip_Code_1}    1
    ${New_Zip_Code_1}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Zip_Code_1}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set cor_zip='${New_Zip_Code_1}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};
    ${City_Name_1}=    Run Keyword And Ignore Error    Get Text    css=span[itemprop='addressLocality']
    ${bool}    Get From List    ${City_Name_1}    0
    ${Extracted_City_Name_1}=    Get From List    ${City_Name_1}    1
    ${New_City_Name_1}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_City_Name_1}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set cor_city='${New_City_Name_1}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};
    ${State_Name_1}=    Run Keyword And Ignore Error    Get Text    css=span[itemprop='addressRegion']
    ${bool}    Get From List    ${State_Name_1}    0
    ${Extracted_State_Name_1}=    Get From List    ${State_Name_1}    1
    ${New_State_Name_1}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_State_Name_1}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set cor_state='${New_State_Name_1}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};
    ${Ownership}=    Run Keyword And Ignore Error    Get Text    //div/strong[contains(text(),'Ownership:')]
    ${bool}    Get From List    ${Ownership}    0
    ${Extracted_Ownership}=    Get From List    ${Ownership}    1
    ${New_Ownership}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Ownership}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set cor_ownership='${New_Ownership}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};
    Close Window
