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
    : FOR    ${i}    IN RANGE    1000
    \    DatabaseLibrary.Query    SELECT GET_LOCK('lock_cortera',60);
    \    ${list}=    DatabaseLibrary.Query    Select id,company_name,city,status,state,address_line from urs_aa.cortera where status='InQueue' limit 1;
    \    Convert To List    ${list}
    \    ${ID_List}    Evaluate    [x[0] for x in ${list}]
    \    ${Name_List}    Evaluate    [x[1] for x in ${list}]
    \    ${City_List}    Evaluate    [x[2] for x in ${list}]
    \    ${Current_Status_List}    Evaluate    [x[3] for x in ${list}]
    \    ${State_List}    Evaluate    [x[4] for x in ${list}]
    \    ${Address_List}    Evaluate    [x[5] for x in ${list}]
    \    ${City_Name}=    Get From List    ${City_List}    ${count}
    \    ${Name}=    Get From List    ${Name_List}    ${count}
    \    ${ID_Number}=    Get From List    ${ID_List}    ${count}
    \    Comment    ${Current_Status}=    Get From List    ${Current_Status_List}    ${count}
    \    ${State_name}    Get From List    ${State_List}    ${count}
    \    ${Address_name}    Get From List    ${Address_List}    ${count}
    \    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processing' where id=${ID_Number};
    \    DatabaseLibrary.Query    SELECT RELEASE_LOCK('lock_cortera');
    \    Sleep    20s
    \    Go to    https://start.cortera.com/company/dispatcher/searchResults?searchcompany=${Name}&searchCity=${City_Name}&searchState=${State_name}
    \    Sleep    20s
    \    BuiltIn.Run Keyword And Ignore Error    Cortera_Details_Extraction    ${ID_Number}
    \    ${Status_list}=    DatabaseLibrary.Query    select status from urs_aa.cortera where id=${ID_Number};
    \    ${Current_Status_List}    Evaluate    [x[0] for x in ${Status_list}]
    \    ${Updated_Status}=    Get From List    ${Current_Status_List}    ${count}
    \    BuiltIn.Run Keyword If    '${Updated_Status}'!='Processed'    Run Keyword And Ignore Error    Iteration_2    ${Name}    ${State_name}
    \    ...    ${ID_Number}
    \    ${Status_list}=    DatabaseLibrary.Query    select status from urs_aa.cortera where id=${ID_Number};
    \    ${Current_Status_List}    Evaluate    [x[0] for x in ${Status_list}]
    \    ${Updated_Status}=    Get From List    ${Current_Status_List}    ${count}
    \    BuiltIn.Run Keyword If    '${Updated_Status}'!='Processed'    Run Keyword And Ignore Error    Iteration_3    ${Name}    ${City_Name}
    \    ...    ${State_name}    ${Address_name}    ${ID_Number}
    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};
    Disconnect From Database
    Close All Browsers

*** Keywords ***
Cortera_Details_Extraction
    [Arguments]    ${ID_Number}
    ${Company_Name}=    Run Keyword And Ignore Error    Get Text    css=span[itemprop='name']
    ${bool}    Get From List    ${Company_Name}    0
    ${Extracted_Company_Name}=    Get From List    ${Company_Name}    1
    ${New_Company_Name}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Company_Name}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera \ set cor_company_name= '${New_Company_Name}' where id=${ID_Number};
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};
    ${Phone_Number}=    Run Keyword And Ignore Error    Get Text    css=div[itemprop='telephone']
    ${bool}    Get From List    ${Phone_Number}    0
    ${Extracted_Phn_Number}=    Get From List    ${Phone_Number}    1
    ${New_Phone_Number}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Phn_Number}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set cor_phone='${New_Phone_Number}' where id=${ID_Number};
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};
    ${Website_Link}=    Run Keyword And Ignore Error    Get Element Attribute    css=a[itemprop='url']    href
    ${bool}    Get From List    ${Website_Link}    0
    ${Extracted_Website_Link}=    Get From List    ${Website_Link}    1
    ${New_Website_Link}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Website_Link}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set cor_website_url='${New_Website_Link}' where id=${ID_Number};
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};
    BuiltIn.Run Keyword And Ignore Error    SIC4_Description    ${ID_Number}
    BuiltIn.Run Keyword And Ignore Error    Year_Extraction    ${ID_Number}
    BuiltIn.Run Keyword And Ignore Error    Number_Of_Employess_Extraction    ${ID_Number}
    BuiltIn.Run Keyword And Ignore Error    Nature_Type_Extraction    ${ID_Number}
    BuiltIn.Run Keyword And Ignore Error    Turn_Over_Extraction    ${ID_Number}
    BuiltIn.Run Keyword And Ignore Error    Ownership_Extraction    ${ID_Number}
    ${Address_1}=    Run Keyword And Ignore Error    Get Text    css=div[itemprop='streetAddress']
    ${bool}    Get From List    ${Address_1}    0
    ${Extracted_Address_1}    Get From List    ${Address_1}    1
    ${New_Address_1}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Address_1}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera \ set cor_address_line='${New_Address_1}' where id=${ID_Number};
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};
    ${Zip_Code_1}=    Run Keyword And Ignore Error    Get Text    span[itemprop='postalCode']
    ${bool}    Get From List    ${Zip_Code_1}    0
    ${Extracted_Zip_Code_1}=    Get From List    ${Zip_Code_1}    1
    ${New_Zip_Code_1}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Zip_Code_1}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set cor_zip='${New_Zip_Code_1}' where id=${ID_Number};
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};
    ${City_Name_1}=    Run Keyword And Ignore Error    Get Text    css=span[itemprop='addressLocality']
    ${bool}    Get From List    ${City_Name_1}    0
    ${Extracted_City_Name_1}=    Get From List    ${City_Name_1}    1
    ${New_City_Name_1}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_City_Name_1}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set cor_city='${New_City_Name_1}' where id=${ID_Number};
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};
    ${State_Name_1}=    Run Keyword And Ignore Error    Get Text    css=span[itemprop='addressRegion']
    ${bool}    Get From List    ${State_Name_1}    0
    ${Extracted_State_Name_1}=    Get From List    ${State_Name_1}    1
    ${New_State_Name_1}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_State_Name_1}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set cor_state='${New_State_Name_1}' where id=${ID_Number};
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};
    ${Url}=    Run Keyword And Ignore Error    SeleniumLibrary.Log Location
    ${bool}    Get From List    ${Url}    0
    ${Extracted_Url}=    Get From List    ${Url}    1
    ${New_Url}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Url}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set cor_url='${New_Url}' where id=${ID_Number};

SIC4_Description
    [Arguments]    ${ID_Number}
    ${SIC4}=    Run Keyword And Ignore Error    Get Text    //div/strong[contains(text(),'Industry:')]/..
    ${bool}    Get From List    ${SIC4}    0
    ${Extracted_SIC4}=    Get From List    ${SIC4}    1
    ${New_SIC4_O}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_SIC4}
    ${New_SIC4_O}=    String.Fetch From Right    ${New_SIC4_O}    :
    ${New_SIC4_O}=    String.Strip String    ${SPACE}${New_SIC4_O}${SPACE}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set cor_sic_desc='${New_SIC4_O}' where id=${ID_Number};
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};

Year_Extraction
    [Arguments]    ${ID_Number}
    ${Year}=    Run Keyword And Ignore Error    Get Text    //div/strong[contains(text(),'Year Founded:')]/..
    ${bool}    Get From List    ${Year}    0
    ${Extracted_year}=    Get From List    ${Year}    1
    ${New_year}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_year}
    ${New_year}=    String.Fetch From Right    ${New_year}    :
    ${New_year}=    String.Strip String    ${SPACE}${New_year}${SPACE}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set cor_year='${New_year}' where id=${ID_Number};
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};

Number_Of_Employess_Extraction
    [Arguments]    ${ID_Number}
    ${Number_Of_Employees}=    Run Keyword And Ignore Error    Get Text    //div/strong[contains(text(),'Employees:')]/..
    ${bool}    Get From List    ${Number_Of_Employees}    0
    ${Ext_Number_Of_Employees}=    Get From List    ${Number_Of_Employees}    1
    ${New_Number_Of_Employees}=    Set Variable If    '${bool}'=='PASS'    ${Ext_Number_Of_Employees}
    ${New_Number_Of_Employees}=    String.Fetch From Right    ${New_Number_Of_Employees}    :
    ${New_Number_Of_Employees}=    String.Strip String    ${SPACE}${New_Number_Of_Employees}${SPACE}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set cor_employees='${New_Number_Of_Employees}' where id=${ID_Number};
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};

Nature_Type_Extraction
    [Arguments]    ${ID_Number}
    ${Nature_Type}=    Run Keyword And Ignore Error    Get Text    //div/strong[contains(text(),'Location Type:')]/..
    ${bool}    Get From List    ${Nature_Type}    0
    ${Extracted_Nature_Type}=    Get From List    ${Nature_Type}    1
    ${New_Nature_Type}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Nature_Type}
    ${New_Nature_Type}=    String.Fetch From Right    ${New_Nature_Type}    :
    ${New_Nature_Type}=    String.Strip String    ${SPACE}${New_Nature_Type}${SPACE}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set cor_nature='${New_Nature_Type}' where id=${ID_Number};
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};

Turn_Over_Extraction
    [Arguments]    ${ID_Number}
    ${Turn_Over}=    Run Keyword And Ignore Error    Get Text    //div/strong[contains(text(),'Sales Range:')]/..
    ${bool}    Get From List    ${Turn_Over}    0
    ${Extracted_Turn_Over}=    Get From List    ${Turn_Over}    1
    ${New_Turn_Over}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Turn_Over}
    ${New_Turn_Over}=    String.Fetch From Right    ${New_Turn_Over}    :
    ${New_Turn_Over}=    String.Strip String    ${SPACE}${New_Turn_Over}${SPACE}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set cor_turnover='${New_Turn_Over}' where id=${ID_Number};
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};

Ownership_Extraction
    [Arguments]    ${ID_Number}
    ${Ownership}=    Run Keyword And Ignore Error    Get Text    //div/strong[contains(text(),'Ownership:')]/..
    ${bool}    Get From List    ${Ownership}    0
    ${Extracted_Ownership}=    Get From List    ${Ownership}    1
    ${New_Ownership}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Ownership}
    ${New_Ownership}=    String.Fetch From Right    ${New_Ownership}    :
    ${New_Ownership}=    String.Strip String    ${SPACE}${New_Ownership}${SPACE}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set cor_ownership='${New_Ownership}' where id=${ID_Number};
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.cortera set status ='Processed' where id=${ID_Number};

Iteration_2
    [Arguments]    ${Name}    ${State_name}    ${ID_Number}
    Sleep    20s
    Go to    https://start.cortera.com/company/dispatcher/searchResults?searchcompany=${Name}&searchCity=City&searchState=${State_name}
    Sleep    20s
    BuiltIn.Run Keyword And Ignore Error    Cortera_Details_Extraction    ${ID_Number}

Iteration_3
    [Arguments]    ${Name}    ${City_Name}    ${State_name}    ${Address_name}    ${ID_Number}
    Sleep    20s
    Go to    https://start.cortera.com/company/dispatcher/searchResults?searchcompany=${Name}&searchCity=${City_Name}&searchState=${State_name}
    Sleep    20s
    @{List}=    Get WebElements    css=#searchResults>tbody>tr>td>form>address
    BuiltIn.Run Keyword And Ignore Error    Iteration_3_Address_Extraction    ${ID_Number}    ${Address_name}    @{List}

Iteration_3_Address_Extraction
    [Arguments]    ${ID_Number}    ${Address_name}    @{List}
    : FOR    ${j}    IN    @{List}
    \    ${Address}=    Get Text    ${j}
    \    ${words}=    String.Split String    ${Address}    ${SPACE}
    \    ${word}=    Get From List    ${words}    0
    \    ${word}=    String.Convert To Lowercase    ${word}
    \    ${Address_name}=    String.Convert To Lowercase    ${Address_name}
    \    ${bool}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Contain    ${Address_name}    ${word}
    \    ${bool}    Get From List    ${bool}    0
    \    BuiltIn.Convert To String    ${bool}
    \    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword And Ignore Error    Iteration_3_URL_Extraction    ${ID_Number}    ${Count2}
    \    BuiltIn.Exit For Loop If    '${bool}'=='PASS'
    \    ${Count2}    BuiltIn.Evaluate    ${Count2}+1

Iteration_3_URL_Extraction
    [Arguments]    ${ID_Number}    ${Count2}
    Click Link    css=#searchResults>tbody>tr:nth-child(${Count2})>td>form>h4>a
    Sleep    20s
    BuiltIn.Run Keyword And Ignore Error    Cortera_Details_Extraction    ${ID_Number}
