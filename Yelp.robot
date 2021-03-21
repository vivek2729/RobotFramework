*** Settings ***
Library           DatabaseLibrary
Library           SeleniumLibrary
Resource          resource.robot

*** Test Cases ***
Extracting_Yelp_Data
    DatabaseLibrary.Connect To Database    pymysql    urs_aa    vivek    mail_1234    shashin-urs.csoaie2kvgsc.us-east-1.rds.amazonaws.com    3306
    Open Browser    https://www.google.com    chrome
    Maximize Browser Window
    Click Element    css=input[name='q']
    Input Text    css=input[name='q']    a
    Sleep    5s
    Click Element    //ul/li[1]/div/div[2]/div/span
    Sleep    5s
    : FOR    ${i}    IN RANGE    1000
    \    DatabaseLibrary.Query    SELECT GET_LOCK('lock_yelp',60);
    \    ${list}=    DatabaseLibrary.Query    select id,company_name,city,status,state from urs_aa.yelp where status='InQueue' limit 1;
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
    \    DatabaseLibrary.Execute Sql String    update urs_aa.yelp set status ='Processing' where id=${ID_Number};
    \    DatabaseLibrary.Query    SELECT RELEASE_LOCK('lock_yelp');
    \    Select Window    Main
    \    Sleep    20s
    \    Input Text    css=input[name='q']    site:yelp.com ${Name} ${City_Name} ${State_name}
    \    Sleep    20s
    \    Click Element    css=button[aria-label='Google Search']
    \    Sleep    20s
    \    @{Url_List}    SeleniumLibrary.Get WebElements    css=div.r>a
    \    ${Urls_Name_List}    SeleniumLibrary.Get WebElements    css=span.S3Uucc
    \    BuiltIn.Run Keyword And Ignore Error    URL_Extraction    ${ID_Number}    ${Name}    ${Urls_Name_List}    @{Url_List}
    DatabaseLibrary.Execute Sql String    update urs_aa.yelp set status ='Processed' where id=${ID_Number};
    Disconnect From Database
    Close All Browsers

*** Keywords ***
Data_Extraction
    [Arguments]    ${href__Url}    ${ID_Number}
    Execute Javascript    window.open()
    Select Window    NEW
    Go To    ${href__Url}
    Sleep    20s
    DatabaseLibrary.Execute Sql String    update urs_aa.yelp set yelp_url='${href__Url}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.yelp set status ='Processed' where id=${ID_Number};
    ${Company_Name_1}=    Run Keyword And Ignore Error    Get Text    css=div.biz-page-header.clearfix>div>div>h1
    ${bool}    Get From List    ${Company_Name_1}    0
    ${Extracted_Company_Name_1}=    Get From List    ${Company_Name_1}    1
    ${New_Company_Name_1}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Company_Name_1}
    ${Company_Name_2}=    Run Keyword And Ignore Error    Get Text    css=div.biz-page-header.clearfix>div>div>div>h1
    ${bool}    Get From List    ${Company_Name_2}    0
    ${Extracted_Company_Name_2}=    Get From List    ${Company_Name_2}    1
    ${New_Company_Name_2}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Company_Name_2}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.yelp set yelp_company_name= '${New_Company_Name1} ${New_Company_Name_2}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.yelp set status ='Processed' where id=${ID_Number};
    ${Phone_Number}=    Run Keyword And Ignore Error    Get Text    css=span.biz-phone
    ${bool}    Get From List    ${Phone_Number}    0
    ${Extracted_Phn_Number}=    Get From List    ${Phone_Number}    1
    ${New_Phone_Number}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Phn_Number}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.yelp set yelp_phone='${New_Phone_Number}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.yelp set status ='Processed' where id=${ID_Number};
    ${Website_Link}=    Run Keyword And Ignore Error    Get Text    //span[@class='offscreen'][contains(text(),'Business website')]/following-sibling::a
    ${bool}    Get From List    ${Website_Link}    0
    ${Extracted_Website_Link}=    Get From List    ${Website_Link}    1
    ${New_Website_Link}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Website_Link}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.yelp set yelp_website_url='${New_Website_Link}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.yelp set status ='Processed' where id=${ID_Number};
    ${SIC4}=    Run Keyword And Ignore Error    Get Text    css=div.biz-main-info.embossed-text-white>div>span>a
    ${bool}    Get From List    ${SIC4}    0
    ${Extracted_SIC4}=    Get From List    ${SIC4}    1
    ${New_SIC4_O}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_SIC4}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.yelp set yelp_sic_desc='${New_SIC4_O}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.yelp set status ='Processed' where id=${ID_Number};
    ${Status}=    BuiltIn.Run Keyword And Return Status    Extracting_Address_1    ${ID_Number}
    Run Keyword If    '${Status}'=='False'    BuiltIn.Run Keyword And Ignore Error    Extracting_Address_2    ${ID_Number}
    Close Window

URL_Extraction
    [Arguments]    ${ID_Number}    ${Name}    ${Urls_Name_List}    @{Url_List}
    : FOR    ${j}    IN    @{Url_List}
    \    ${words}=    String.Split String    ${Name}    ${SPACE}
    \    ${word}=    Get From List    ${words}    0
    \    ${word}=    String.Convert To Lowercase    ${word}
    \    ${word2}=    Get From List    ${Urls_Name_List}    ${count1}
    \    ${word1}=    Get Text    ${word2}
    \    ${word1}=    String.Convert To Lowercase    ${word1}
    \    ${bool1}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Contain    ${word1}    ${word}
    \    ${bool1}    Get From List    ${bool1}    0
    \    BuiltIn.Convert To String    ${bool1}
    \    ${href__Url}=    SeleniumLibrary.Get Element Attribute    ${j}    href
    \    ${bool}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Contain    ${href__Url}    yelp.com
    \    ${bool}    Get From List    ${bool}    0
    \    BuiltIn.Convert To String    ${bool}
    \    BuiltIn.Run Keyword If    '${bool}'=='PASS' and '${bool1}'=='PASS'    BuiltIn.Run Keyword And Ignore Error    Data_Extraction    ${href__Url}    ${ID_Number}
    \    BuiltIn.Return From Keyword If    '${bool}'=='PASS' and '${bool1}'=='PASS'    ${href__Url}
    \    BuiltIn.Exit For Loop If    '${bool}'=='PASS' and '${bool1}'=='PASS'
    \    ${count1}=    BuiltIn.Evaluate    ${count}+1

Extracting_Address_1
    [Arguments]    ${ID_Number}
    ${Address_1}=    Run Keyword And Ignore Error    Get Text    css=strong.street-address>address
    ${bool}    Get From List    ${Address_1}    0
    ${Extracted_Address_1}    Get From List    ${Address_1}    1
    ${New_Address_1}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Address_1}
    ${New_Address_2}=    String.Fetch From Left    ${New_Address_1}    ,
    ${City_Name}=    String.Fetch From Right    ${New_Address_2}    \n
    ${Address_Line}=    String.Fetch From Left    ${New_Address_2}    \n
    DatabaseLibrary.Execute Sql String    update urs_aa.yelp set yelp_city='${City_Name}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.yelp set yelp_address_line='${Address_Line}' where id=${ID_Number};
    ${list}=    String.Fetch From Right    ${New_Address_1}    ,
    ${list}=    Split String    ${list}    ${SPACE}
    Convert To List    ${list}
    ${Zip_Code_1}=    Get From List    ${list}    2
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.yelp set yelp_zip='${Zip_Code_1}' where id=${ID_Number};
    ${State_Name_1}=    Get From List    ${list}    1
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.yelp set yelp_state='${State_Name_1}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.yelp set status ='Processed' where id=${ID_Number};

Extracting_Address_2
    [Arguments]    ${ID_Number}
    ${Address_1}=    Run Keyword And Ignore Error    Get Text    css=div.map-box-address>address
    ${bool}    Get From List    ${Address_1}    0
    ${Extracted_Address_1}    Get From List    ${Address_1}    1
    ${New_Address_1}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Address_1}
    ${New_Address_2}=    String.Fetch From Left    ${New_Address_1}    ,
    ${City_Name}=    String.Fetch From Right    ${New_Address_2}    \n
    ${New_Address_Line}=    String.Fetch From Left    ${New_Address_1}    ${City_Name}
    DatabaseLibrary.Execute Sql String    update urs_aa.yelp set yelp_city='${City_Name}' where id=${ID_Number};
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.yelp set yelp_address_line='${New_Address_Line}' where id=${ID_Number};
    ${list}=    String.Fetch From Right    ${New_Address_1}    ,
    ${list}=    Split String    ${list}    ${SPACE}
    Convert To List    ${list}
    ${Zip_Code_1}=    Get From List    ${list}    2
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.yelp set yelp_zip='${Zip_Code_1}' where id=${ID_Number};
    ${State_Name_1}=    Get From List    ${list}    1
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.yelp set yelp_state='${State_Name_1}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.yelp set status ='Processed' where id=${ID_Number};
