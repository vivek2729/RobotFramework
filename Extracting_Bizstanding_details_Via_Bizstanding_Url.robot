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
    : FOR    ${i}    IN RANGE    100
    \    DatabaseLibrary.Query    SELECT GET_LOCK('lock_bizstanding',60);
    \    ${list}=    DatabaseLibrary.Query    select id,company_name,city,status,state from urs_aa.bizstanding where status='InQueue' limit 1;
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
    \    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processing' where id=${ID_Number};
    \    DatabaseLibrary.Query    SELECT RELEASE_LOCK('lock_bizstanding');
    \    Go To    https://bizstanding.com/search?bname=${Name}&location=${City_Name}+${State_name}
    \    log    Server three
    \    log Server Ten
    \    Sleep    60s
    \    ${Company_Name}=    Run Keyword And Ignore Error    Get Text    //section[@class='org'][1]/div/div/div/h2/a/font
    \    ${bool}    Get From List    ${Company_Name}    0
    \    ${Extracted_Company_Name}=    Get From List    ${Company_Name}    1
    \    ${New_Company_Name}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Company_Name}
    \    ${New_Company_Name}=    String.Replace String    ${New_Company_Name}    '    ''
    \    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_company_name= '${New_Company_Name}' where id=${ID_Number};
    \    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    \    ${Phone_Number}=    Run Keyword And Ignore Error    Get Text    //section[@class='org'][1]/div/p/span//span[@class='ph']
    \    ${bool}    Get From List    ${Phone_Number}    0
    \    ${Extracted_Phn_Number}=    Get From List    ${Phone_Number}    1
    \    ${New_Phone_Number}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Phn_Number}
    \    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_phone='${New_Phone_Number}' where id=${ID_Number};
    \    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    \    ${Website_Link_1}=    Run Keyword And Ignore Error    Get Element Attribute    //section[@class='org'][1]/div/p/span[@class='b-business-item_title'][contains(text(),'Site')]/following-sibling::span/a[1]    href
    \    ${bool}    Get From List    ${Website_Link_1}    0
    \    ${Extracted_Website_Link_1}=    Get From List    ${Website_Link_1}    1
    \    ${New_Website_Link_1}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Website_Link_1}
    \    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_website_url='${New_Website_Link_1}' where id=${ID_Number};
    \    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    \    ${SIC4}=    Run Keyword And Ignore Error    Get Text    //section[@class='org'][1]/div/p/span[@class='b-business-item_title'][contains(text(),'SIC:')]/following-sibling::span
    \    ${bool}    Get From List    ${SIC4}    0
    \    ${Extracted_SIC4}=    Get From List    ${SIC4}    1
    \    ${Old_SIC4}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_SIC4}
    \    ${O_SCI4}=    Run Keyword And Ignore Error    String.Fetch From Left    ${Old_SIC4}    -
    \    ${bool}    Get From List    ${O_SCI4}    0
    \    ${Extracted_SIC4_O}=    Get From List    ${O_SCI4}    1
    \    ${Extracted_SIC4_O}=    String.Strip String    ${SPACE}${Extracted_SIC4_O}${SPACE}
    \    ${New_SIC4_O}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_SIC4_O}
    \    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_sic4='${New_SIC4_O}' where id=${ID_Number};
    \    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    \    ${SCI4_Description}=    Run Keyword And Ignore Error    String.Fetch From Right    ${Old_SIC4}    -
    \    ${bool}    Get From List    ${SCI4_Description}    0
    \    ${Extracted_SIC4_D}=    Get From List    ${SCI4_Description}    1
    \    ${Extracted_SIC4_D}=    String.Strip String    ${SPACE}${Extracted_SIC4_D}${SPACE}
    \    ${New_SIC4_D}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_SIC4_D}
    \    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_sic4_desc='${New_SIC4_D}' where id=${ID_Number};
    \    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    \    ${SIC6}=    Run Keyword And Ignore Error    Get Text    //section[@class='org'][1]/div/p/span[@class='b-business-item_title'][contains(text(),'SIC6:')]/following-sibling::span
    \    ${bool}    Get From List    ${SIC6}    0
    \    ${Extracted_SIC6}=    Get From List    ${SIC6}    1
    \    ${Old_SIC6}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_SIC6}
    \    ${SCI6_O}=    Run Keyword And Ignore Error    String.Fetch From Left    ${Old_SIC6}    -
    \    ${bool}    Get From List    ${SCI6_O}    0
    \    ${Extracted_SIC6_O}=    Get From List    ${SCI6_O}    1
    \    ${Extracted_SIC6_O}=    String.Strip String    ${SPACE}${Extracted_SIC6_O}${SPACE}
    \    ${New_SIC6_O}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_SIC6_O}
    \    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_sic6='${New_SIC6_O}' where id=${ID_Number};
    \    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    \    ${SCI6_Description}=    Run Keyword And Ignore Error    String.Fetch From Right    ${Old_SIC6}    -
    \    ${bool}    Get From List    ${SCI6_Description}    0
    \    ${Extracted_SIC6_D}=    Get From List    ${SCI6_Description}    1
    \    ${Extracted_SIC6_D}=    String.Strip String    ${SPACE}${Extracted_SIC6_D}${SPACE}
    \    ${New_SIC6_D}    Set Variable If    '${bool}'=='PASS'    ${Extracted_SIC6_D}
    \    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_sic6_desc='${New_SIC6_D}' where id=${ID_Number};
    \    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    \    ${Year}=    Run Keyword And Ignore Error    Get Text    //section[@class='org'][1]/div/p/span[@class='b-business-item_title'][contains(text(),'In business since:')]/following-sibling::span
    \    ${bool}    Get From List    ${Year}    0
    \    ${Extracted_year}=    Get From List    ${Year}    1
    \    ${New_year}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_year}
    \    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_year='${New_year}' where id=${ID_Number};
    \    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    \    BuiltIn.Run Keyword If    '${bool}'=='FAIL'    Registration_details    ${ID_Number}
    \    ${Number_Of_Employees}=    Run Keyword And Ignore Error    Get Text    //section[@class='org'][1]/div/p/span[@class='b-business-item_title'][contains(text(),'Company size:')]/following-sibling::span
    \    ${bool}    Get From List    ${Number_Of_Employees}    0
    \    ${Ext_Number_Of_Employees}=    Get From List    ${Number_Of_Employees}    1
    \    ${New_Number_Of_Employees}=    Set Variable If    '${bool}'=='PASS'    ${Ext_Number_Of_Employees}
    \    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_employees='${New_Number_Of_Employees}' where id=${ID_Number};
    \    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    \    ${href_Url}=    Run Keyword And Ignore Error    Get Location
    \    ${bool}    Get From List    ${href_Url}    0
    \    ${Extracted_Href_Url}=    Get From List    ${href_Url}    1
    \    ${New_href_Url}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Href_Url}
    \    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_url='${New_href_Url}' where id=${ID_Number};
    \    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    \    BuiltIn.Run Keyword And Ignore Error    Extracting_Address    ${ID_Number}
    \    BuiltIn.Run Keyword And Ignore Error    Extracting_Authorized_Persons    ${ID_Number}
    \    ${Website_Link_2}=    Run Keyword And Ignore Error    Get Element Attribute    //section[@class='org'][1]/div/p/span[@class='b-business-item_title'][contains(text(),'Site')]/following-sibling::span/a[2]    href
    \    ${bool}    Get From List    ${Website_Link_2}    0
    \    ${Extracted_Website_Link_2}=    Get From List    ${Website_Link_2}    1
    \    ${New_Website_Link_2}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Website_Link_2}
    \    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_website_url_2='${New_Website_Link_2}' where id=${ID_Number};
    \    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    \    ${Website_Link_3}=    Run Keyword And Ignore Error    Get Element Attribute    //section[@class='org'][1]/div/p/span[@class='b-business-item_title'][contains(text(),'Site')]/following-sibling::span/a[3]    href
    \    ${bool}    Get From List    ${Website_Link_3}    0
    \    ${Extracted_Website_Link_3}=    Get From List    ${Website_Link_3}    1
    \    ${New_Website_Link_3}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Website_Link_3}
    \    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_website_url_3='${New_Website_Link_3}' where id=${ID_Number};
    \    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    \    BuiltIn.Run Keyword And Ignore Error    Extracting_Website    ${ID_Number}
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    Disconnect From Database
    Close All Browsers

*** Keywords ***
Extracting_Address
    [Arguments]    ${ID_Number}
    ${Address_1}=    Run Keyword And Ignore Error    Get Text    //section[@class='org'][1]/div/p/span[@class='b-business-item_title'][contains(text(),'Addresses:')]/following-sibling::span/span[1]/span[@itemprop='streetAddress']
    ${bool}    Get From List    ${Address_1}    0
    ${Extracted_Address_1}    Get From List    ${Address_1}    1
    ${New_Address_1}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Address_1}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_address_line='${New_Address_1}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    ${Zip_Code_1}=    Run Keyword And Ignore Error    Get Text    //section[@class='org'][1]/div/p/span[@class='b-business-item_title'][contains(text(),'Addresses:')]/following-sibling::span/span[1]/span/span[@itemprop='postalCode']
    ${bool}    Get From List    ${Zip_Code_1}    0
    ${Extracted_Zip_Code_1}=    Get From List    ${Zip_Code_1}    1
    ${New_Zip_Code_1}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Zip_Code_1}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_zip='${New_Zip_Code_1}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    ${City_Name_1}=    Run Keyword And Ignore Error    Get Text    //section[@class='org'][1]/div/p/span[@class='b-business-item_title'][contains(text(),'Addresses:')]/following-sibling::span/span[1]/span/span[@itemprop='addressLocality']
    ${bool}    Get From List    ${City_Name_1}    0
    ${Extracted_City_Name_1}=    Get From List    ${City_Name_1}    1
    ${New_City_Name_1}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_City_Name_1}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_city='${New_City_Name_1}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    ${State_Name_1}=    Run Keyword And Ignore Error    Get Text    //section[@class='org'][1]/div/p/span[@class='b-business-item_title'][contains(text(),'Addresses:')]/following-sibling::span/span[1]/span/span[@itemprop='addressRegion']
    ${bool}    Get From List    ${State_Name_1}    0
    ${Extracted_State_Name_1}=    Get From List    ${State_Name_1}    1
    ${New_State_Name_1}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_State_Name_1}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_state='${New_State_Name_1}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    ${Address_2}=    Run Keyword And Ignore Error    Get Text    //section[@class='org'][1]/div/p/span[@class='b-business-item_title'][contains(text(),'Addresses:')]/following-sibling::span/span[2]/span[@itemprop='streetAddress']
    ${bool}    Get From List    ${Address_2}    0
    ${Extracted_Address_2}    Get From List    ${Address_2}    1
    ${New_Address_2}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Address_2}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_address_line_2='${New_Address_2}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    ${Zip_Code_2}=    Run Keyword And Ignore Error    Get Text    //section[@class='org'][1]/div/p/span[@class='b-business-item_title'][contains(text(),'Addresses:')]/following-sibling::span/span[2]/span/span[@itemprop='postalCode']
    ${bool}    Get From List    ${Zip_Code_2}    0
    ${Extracted_Zip_Code_2}=    Get From List    ${Zip_Code_2}    1
    ${New_Zip_Code_2}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Zip_Code_2}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_zip_2='${New_Zip_Code_2}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    ${City_Name_2}=    Run Keyword And Ignore Error    Get Text    //section[@class='org'][1]/div/p/span[@class='b-business-item_title'][contains(text(),'Addresses:')]/following-sibling::span/span[2]/span/span[@itemprop='addressLocality']
    ${bool}    Get From List    ${City_Name_2}    0
    ${Extracted_City_Name_2}=    Get From List    ${City_Name_2}    1
    ${New_City_Name_2}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_City_Name_2}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_city_2='${New_City_Name_2}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    ${State_Name_2}=    Run Keyword And Ignore Error    Get Text    //section[@class='org'][1]/div/p/span[@class='b-business-item_title'][contains(text(),'Addresses:')]/following-sibling::span/span[2]/span/span[@itemprop='addressRegion']
    ${bool}    Get From List    ${State_Name_2}    0
    ${Extracted_State_Name_2}=    Get From List    ${State_Name_2}    1
    ${New_State_Name_2}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_State_Name_2}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_state_2='${New_State_Name_2}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    ${Address_3}=    Run Keyword And Ignore Error    Get Text    //section[@class='org'][1]/div/div/div[@class='b-business-item_title-wrap']/p/span[@itemprop='address']/span[@itemprop='streetAddress']
    ${bool}    Get From List    ${Address_3}    0
    ${Extracted_Address_3}    Get From List    ${Address_3}    1
    ${New_Address_3}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Address_3}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_address_line_3='${New_Address_3}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    ${Zip_Code_3}=    Run Keyword And Ignore Error    Get Text    //section[@class='org'][1]/div/div/div[@class='b-business-item_title-wrap']/p/span[@itemprop='address']/span/span[@itemprop='postalCode']
    ${bool}    Get From List    ${Zip_Code_3}    0
    ${Extracted_Zip_Code_3}=    Get From List    ${Zip_Code_3}    1
    ${New_Zip_Code_3}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Zip_Code_3}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_zip_3='${New_Zip_Code_3}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    ${City_Name_3}=    Run Keyword And Ignore Error    Get Text    //section[@class='org'][1]/div/div/div[@class='b-business-item_title-wrap']/p/span[@itemprop='address']/span/span[@itemprop='addressLocality']
    ${bool}    Get From List    ${City_Name_3}    0
    ${Extracted_City_Name_3}=    Get From List    ${City_Name_3}    1
    ${New_City_Name_3}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_City_Name_3}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_city_3='${New_City_Name_3}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    ${State_Name_3}=    Run Keyword And Ignore Error    Get Text    //section[@class='org'][1]/div/div/div[@class='b-business-item_title-wrap']/p/span[@itemprop='address']/span/span[@itemprop='addressRegion']
    ${bool}    Get From List    ${State_Name_3}    0
    ${Extracted_State_Name_3}=    Get From List    ${State_Name_3}    1
    ${New_State_Name_3}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_State_Name_3}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_state_3='${New_State_Name_3}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};

Extracting_Authorized_Persons
    [Arguments]    ${ID_Number}
    ${Authorised_Person}    Run Keyword And Ignore Error    Get Text    //section[@class='org'][1]/div/p/span[@class='b-business-item_title'][contains(text(),'Member')]/following-sibling::span
    ${bool}    Get From List    ${Authorised_Person}    0
    ${Extracted_Authorized_Person}=    Get From List    ${Authorised_Person}    1
    ${New_Authorized_Person}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Authorized_Person}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_authorized_person='${New_Authorized_Person}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    ${Authorised_P1}    Run Keyword And Ignore Error    Get Text    //section[@class='org'][1]/div/p/span[@class='b-business-item_title'][contains(text(),'Member')]/following-sibling::span
    ${bool}    Get From List    ${Authorised_P1}    0
    ${Extracted_Authorized_P1}=    Get From List    ${Authorised_P1}    1
    ${list}=    Split String    ${Extracted_Authorized_P1}    )
    Convert To List    ${list}
    ${New_Authorized_P1}=    Get From List    ${list}    0
    ${New_P1}=    String.Fetch From Left    ${New_Authorized_P1}    (
    ${New_P1_Title}=    String.Fetch From Right    ${New_Authorized_P1}    (
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_authorized_p1='${New_P1}' where id=${ID_Number};
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_authorized_p1_t='${New_P1_Title}' where id=${ID_Number};
    ${New_Authorized_P2}=    Get From List    ${list}    1
    ${bool1}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Not Contain Any    ${New_Authorized_P2}    0    1    2
    ...    3    4    5    6    7    8
    ...    9
    Convert To List    ${bool1}
    ${bool1}=    Get From List    ${bool1}    0
    ${New_P2}=    String.Fetch From Left    ${New_Authorized_P2}    (
    ${New_P2_Title}=    String.Fetch From Right    ${New_Authorized_P2}    (
    Run Keyword If    '${bool1}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_authorized_p2='${New_P2}' where id=${ID_Number};
    Run Keyword If    '${bool1}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_authorized_p2_t='${New_P2_Title}' where id=${ID_Number};
    ${New_Authorized_P3}=    Get From List    ${list}    2
    ${bool1}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Not Contain Any    ${New_Authorized_P3}    0    1    2
    ...    3    4    5    6    7    8
    ...    9
    Convert To List    ${bool1}
    ${bool1}=    Get From List    ${bool1}    0
    ${New_P3}=    String.Fetch From Left    ${New_Authorized_P3}    (
    ${New_P3_Title}=    String.Fetch From Right    ${New_Authorized_P3}    (
    Run Keyword If    '${bool1}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_authorized_p3='${New_P3}' where id=${ID_Number};
    Run Keyword If    '${bool1}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_authorized_p3_t='${New_P3_Title}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};

Registration_details
    [Arguments]    ${ID_Number}
    ${Registration_Date}=    Run Keyword And Ignore Error    Get Text    //section[@class='org'][1]/div/p/span[@class='b-business-item_title'][contains(text(),'Registration:')]/following-sibling::span
    ${bool}    Get From List    ${Registration_Date}    0
    ${Extracted_year_reg}=    Get From List    ${Registration_Date}    1
    ${Extracted_year_reg}=    String.Fetch From Right    ${Extracted_year_reg}    ,
    ${Extracted_year_reg}=    String.Strip String    ${SPACE}${Extracted_year_reg}${SPACE}
    ${New_year_reg}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_year_reg}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_year='${New_year_reg}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};

Extracting_Website
    [Arguments]    ${ID_Number}
    ${Websites}=    Run Keyword And Ignore Error    Get Text    //section[@class='org'][1]/div/p/span[@class='b-business-item_title'][contains(text(),'Site')]/following-sibling::span
    ${bool}    Get From List    ${Websites}    0
    ${Extracted_Websites}=    Get From List    ${Websites}    1
    ${New_Websites}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Websites}
    ${list}=    Split String    ${New_Websites}    ,
    ${Website_Link_1}=    Get From List    ${list}    0
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_website_url='${Website_Link_1}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    ${Website_Link_2}=    Get From List    ${list}    1
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_website_url_2='${Website_Link_2}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
    ${Website_Link_3}=    Get From List    ${list}    2
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding \ set biz_website_url_3='${Website_Link_3}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.bizstanding set status ='Processed' where id=${ID_Number};
