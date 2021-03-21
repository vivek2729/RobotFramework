*** Settings ***
Library           SeleniumLibrary
Library           DatabaseLibrary
Library           OperatingSystem
Library           DateTime
Resource          resource.robot

*** Test Cases ***
Extracting_ZoomInfo_Details
    DatabaseLibrary.Connect To Database    pymysql    urs_aa    vivek    mail_1234    shashin-urs.csoaie2kvgsc.us-east-1.rds.amazonaws.com    3306
    Open Browser    https://www.google.com    chrome
    Maximize Browser Window
    Click Element    css=input[name='q']
    Input Text    css=input[name='q']    a
    Sleep    5s
    Click Element    //ul/li[1]/div/div[2]/div/span
    Sleep    5s
    : FOR    ${i}    IN RANGE    1
    \    Select Window    Main
    \    DatabaseLibrary.Query    SELECT GET_LOCK('lock1',60);
    \    ${list}=    DatabaseLibrary.Query    select id,company_name,city,state,zip from urs_aa.zoominfo where id=1
    \    Convert To List    ${list}
    \    ${ID_List}    Evaluate    [x[0] for x in ${list}]
    \    ${Name_List}    Evaluate    [x[1] for x in ${list}]
    \    ${City_List}    Evaluate    [x[2] for x in ${list}]
    \    ${State_List}    Evaluate    [x[3] for x in ${list}]
    \    ${Zip_List}    Evaluate    [x[4] for x in ${list}]
    \    ${Name}=    Get From List    ${Name_List}    ${count}
    \    ${ID_Number}=    Get From List    ${ID_List}    ${count}
    \    ${City_Name}=    Get From List    ${City_List}    ${count}
    \    ${State_Name}=    Get From List    ${State_List}    ${count}
    \    ${Zip_Name}=    Get From List    ${Zip_List}    ${count}
    \    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set status ='Processing' where id=${ID_Number};
    \    ${Current_Status}=    BuiltIn.Set Variable    Processing
    \    DatabaseLibrary.Query    SELECT RELEASE_LOCK('lock1');
    \    Input Text    css=input[name='q']    site zoominfo.com ${Name} ${City_Name}
    \    Sleep    35s
    \    Click Element    css=button[aria-label='Google Search']
    \    Sleep    35s
    \    @{Url_List}    SeleniumLibrary.Get WebElements    css=div.r>a
    \    BuiltIn.Run Keyword And Ignore Error    Inner_Loop    ${ID_Number}    ${Name}    @{Url_List}
    DatabaseLibrary.Disconnect From Database
    Close All Browsers

*** Keywords ***
Inner_Loop
    [Arguments]    ${ID_Number}    ${Name}    @{Url_List}
    : FOR    ${j}    IN    @{Url_List}
    \    ${href__Url}=    SeleniumLibrary.Get Element Attribute    ${j}    href
    \    ${bool}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Contain    ${href__Url}    www.zoominfo.com
    \    ${Href_Url_One}=    String.Fetch From left    ${href__Url}    /c
    \    ${Href_Url_Two}=    String.Fetch From Right    ${href__Url}    /c
    \    ${Final_Href}=    BuiltIn.Catenate    SEPARATOR=    ${Href_Url_One}    /pic    ${Href_Url_Two}
    \    ${bool}    Get From List    ${bool}    0
    \    BuiltIn.Convert To String    ${bool}
    \    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword And Ignore Error    Paginations    ${Final_Href}
    \    Comment    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword And Ignore Error    ZoomInfo_Details_Extraction    ${href__Url}
    \    ...    ${ID_Number}
    \    BuiltIn.Return From Keyword If    '${bool}'=='PASS'    ${href__Url}
    \    BuiltIn.Exit For Loop If    '${bool}'=='PASS'

ZoomInfo_Details_Extraction
    [Arguments]    ${href__Url}    ${ID_Number}
    Execute Javascript    window.open()
    Select Window    NEW
    Go To    ${href__Url}
    Sleep    35s
    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set zoominfo_url='${href__Url}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set status ='Processed' where id=${ID_Number};
    ${Company_Name}=    Run Keyword And Ignore Error    Get Text    css=h1.company-name
    ${bool}    Get From List    ${Company_Name}    0
    ${Extracted_Company_Name}=    Get From List    ${Company_Name}    1
    ${New_Company_Name}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Company_Name}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set zoom_company_name= '${New_Company_Name}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set status ='Processed' where id=${ID_Number};
    ${WebSite_Name}=    Run Keyword And Ignore Error    Get Text    css=a.content.link
    ${bool}    Get From List    ${WebSite_Name}    0
    ${Extracted_WebSite_Name}=    Get From List    ${WebSite_Name}    1
    ${New_WebSite_Name}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_WebSite_Name}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set zoom_website='${New_WebSite_Name}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set status ='Processed' where id=${ID_Number};
    ${HeadQuarter_Name}=    Run Keyword And Ignore Error    Get Text    //img[@alt='Headquarters']/../div/span
    ${bool}    Get From List    ${HeadQuarter_Name}    0
    ${Extracted_HQ_Name}=    Get From List    ${HeadQuarter_Name}    1
    ${New_HQ_Name}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_HQ_Name}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set zoom_address='${New_HQ_Name}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set status ='Processed' where id=${ID_Number};
    Run Keyword And Ignore Error    Extracting_State_City_Zip    ${New_HQ_Name}    ${ID_Number}
    ${Size}=    Run Keyword And Ignore Error    Get Text    //img[@alt='Employees']/../div/span
    ${bool}    Get From List    ${Size}    0
    ${Extracted_Size}=    Get From List    ${Size}    1
    ${New_Size}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Size}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set zoom_employees='${New_Size}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set status ='Processed' where id=${ID_Number};
    ${Phone_Number}=    Run Keyword And Ignore Error    Get Text    //app-icon-text[@class='vertical-gap']/div/img[@alt='Phone']/../div/span
    ${bool}    Get From List    ${Phone_Number}    0
    ${Extracted_Phone_Number}=    Get From List    ${Phone_Number}    1
    ${New_Phone_Number}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Phone_Number}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set zoom_phone_number='${New_Phone_Number}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set status ='Processed' where id=${ID_Number};
    ${SIC_Code}=    Run Keyword And Ignore Error    Get Text    //span[contains(text(),'SIC Code ')]/following-sibling::span
    ${bool}    Get From List    ${SIC_Code}    0
    ${Extracted_SIC_Code}=    Get From List    ${SIC_Code}    1
    ${New_SIC_Code}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_SIC_Code}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set zoom_sic_code='${New_SIC_Code}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set status ='Processed' where id=${ID_Number};
    ${NAICS_Code}=    Run Keyword And Ignore Error    Get Text    //span[contains(text(),'NAICS Code ')]/following-sibling::span
    ${bool}    Get From List    ${NAICS_Code}    0
    ${Extracted_NAICS_Code}=    Get From List    ${NAICS_Code}    1
    ${New_NAICS_Code}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_NAICS_Code}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set zoom_naics_code='${New_NAICS_Code}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set status ='Processed' where id=${ID_Number};
    ${Revenue}=    Run Keyword And Ignore Error    Get Text    //img[@alt='Revenue']/../div/span
    ${bool}    Get From List    ${Revenue}    0
    ${Extracted_Revenue}=    Get From List    ${Revenue}    1
    ${New_Revenue}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Revenue}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set zoom_revenue='${New_Revenue}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set status ='Processed' where id=${ID_Number};
    ${Description}=    Run Keyword And Ignore Error    Get Text    css=p.company-description-text-content
    ${bool}    Get From List    ${Description}    0
    ${Extracted_Description}=    Get From List    ${Description}    1
    ${New_Description}=    Set Variable If    '${bool}'=='PASS'    ${Extracted_Description}
    Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set zoom_description='${New_Description}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set status ='Processed' where id=${ID_Number};

Extracting_State_City_Zip
    [Arguments]    ${New_HQ_Name}    ${ID_Number}
    ${Address}=    String.Split String    ${New_HQ_Name}    ,
    ${City_Name}=    Get From List    ${Address}    1
    ${State_Name}=    Get From List    ${Address}    2
    ${Zip_Code}=    Get From List    ${Address}    3
    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set zoom_city= '${City_Name}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set zoom_state= '${State_Name}' where id=${ID_Number};
    DatabaseLibrary.Execute Sql String    update urs_aa.zoominfo set zoom_zip= '${Zip_Code}' where id=${ID_Number};

Extracting_Employee_Details
    [Arguments]    @{Title_Employee_List}
    : FOR    ${j}    IN    @{Title_Employee_List}
    \    ${Person_Name}=    Get Text    css=tr:nth-child(${Count2})>td>div>div.tableRow_personName>a
    \    ${New_Href}    Get Element Attribute    css=tr:nth-child(${Count2})>td>div>div.tableRow_personName>a    href
    \    BuiltIn.Run Keyword And Ignore Error    Extracting_Buisness_Profile_Of_Employees    ${New_Href}
    \    ${Job_Title}=    Get Text    css=tr:nth-child(${Count2})>td.job-title>div>div
    \    ${Last_Update}=    Get Text    css=tr:nth-child(${Count2})>td.tableRow_companyDetails>div>span
    \    @{Location_List}    Get WebElements    css=tr:nth-child(${Count2})>td.tableRow_locationInfo>div>a
    \    BuiltIn.Run Keyword And Ignore Error    Extracting_Locations_From_Employee_List    @{Location_List}
    \    ${Count2}=    BuiltIn.Evaluate    ${Count2}+1

Paginations
    [Arguments]    ${Final_Href}
    Execute Javascript    window.open()
    Select Window    NEW
    Go To    ${Final_Href}
    Sleep    35s
    ${text}    Get Text    css=h2.page_searchResults_numberOfResults
    ${count}    Get Substring    ${text}    8    12
    ${pagination}    BuiltIn.Evaluate    ${count}/25
    ${pagination}    BuiltIn.Evaluate    ${pagination}+0.49
    ${No_of_Pages}    BuiltIn.Convert To Number    ${pagination}    0
    ${No_of_Pages}    BuiltIn.Convert To Integer    ${No_of_Pages}
    @{Title_Employee_List}    Get WebElements    css=tbody.tableBody>tr
    BuiltIn.Run Keyword And Ignore Error    Extracting_Employee_Details    @{Title_Employee_List}
    : FOR    ${count}    IN RANGE    1    ${No_of_Pages}
    \    Log    Page loop
    \    Element Should Be Enabled    //div/a[@class='paginationLink arrowContainer'][2]/img
    \    Click Element    //div/a[@class='paginationLink arrowContainer'][2]/img
    \    Sleep    35s
    \    Click Element    css=.username
    \    @{Title_Employee_List}    Get WebElements    css=tbody.tableBody>tr
    \    BuiltIn.Run Keyword And Ignore Error    Extracting_Employee_Details    @{Title_Employee_List}

Extracting_Locations_From_Employee_List
    [Arguments]    @{Location_List}
    : FOR    ${j}    IN    @{Location_List}
    \    ${location1}    Get text    ${j}
    \    ${Final_Location}=    BuiltIn.Catenate    SEPARATOR=,    ${location1}
    \    ${Final_Location}=    BuiltIn.Set Variable    ${Final_Location}

Extracting_Buisness_Profile_Of_Employees
    [Arguments]    ${New_Href}
    Execute Javascript    window.open()
    Select Window    NEW
    Go To    ${New_Href}
    Sleep    35s
    @{Location_List}=    Get WebElements    css=div.primeSection_details>div.primeSection_details-row:nth-child(1)>div.primeSection_details-right>span>span
    ${Company_name}=    Get Text    css=div.primeSection_details>div.primeSection_details-row:nth-child(2)>div.primeSection_details-right>a
    ${HQ_Phone}=    Get Text    css=div.primeSection_details>div.primeSection_details-row:nth-child(3)>div.primeSection_details-right>span
    ${Email_Address}=    Get Text    css=div.primeSection_details>div.primeSection_details-row:nth-child(4)>div.primeSection_details-right>a:nth-child(1)
    ${Direct_Phone}=    Get Text    css=div.primeSection_details>div.primeSection_details-row:nth-child(5)>div.primeSection_details-right>a:nth-child(1)
    ${Last_Updated}=    Get Text    css=div.primeSection_details>div.primeSection_details-row:nth-child(6)>div.primeSection_details-right>span
