*** Settings ***
Resource          resource.robot
Library           SeleniumLibrary
Library           DatabaseLibrary
Library           OperatingSystem
Library           DateTime

*** Test Cases ***
Extracting_Details
    DatabaseLibrary.Connect To Database    pymysql    clean_movies    vivekkumar.pandey    MMaXm83dZD18A4AA    dev-scraper.csoaie2kvgsc.us-east-1.rds.amazonaws.com    3306
    Open Browser    https://www.google.com    chrome
    Maximize Browser Window
    Sleep    10s
    Go to    https://pro.imdb.com
    Sleep    20s
    Click Element    css=a#imdb_pro_login_popover
    Click Element    //span[contains(text(),'Log in with IMDb')]
    Sleep    20s
    Input Text    css=input[name='email']    vkpandeyamd@gmail.com
    Input Text    css=input[name='password']    Vikki@2292258
    Click Element    css=#signInSubmit
    sleep    20s
    : FOR    ${i}    IN RANGE    1
    \    Comment    DatabaseLibrary.Query    SELECT GET_LOCK('lock_cortera',60);
    \    ${list}=    DatabaseLibrary.Query    Select imdbId,companyName,country,uniqueTitleCount,id from clean_movies.bd_distributor_company_output where companyID=' ' and isProcessed='0' limit 1;
    \    Convert To List    ${list}
    \    ${IMDB_ID_List}    Evaluate    [x[0] for x in ${list}]
    \    ${Company_Name_List}    Evaluate    [x[1] for x in ${list}]
    \    ${Country_List}    Evaluate    [x[2] for x in ${list}]
    \    ${Unique_Title_List}    Evaluate    [x[3] for x in ${list}]
    \    ${ID_List}    Evaluate    [x[4] for x in ${list}]
    \    ${Imdb_ID}=    Get From List    ${IMDB_ID_List}    ${count}
    \    ${Company_Name}=    Get From List    ${Company_Name_List}    ${count}
    \    ${Country}=    Get From List    ${Country_List}    ${count}
    \    ${Unique_Title}=    Get From List    ${Unique_Title_List}    ${count}
    \    ${ID}=    Get From List    ${ID_List}    ${count}
    \    ${Imdb_ID}=    String.Strip String    ${Imdb_ID}${SPACE}
    \    Go to    https://www.imdb.com/title/${Imdb_ID}/
    \    Sleep    20s
    \    ${bool}=    BuiltIn.Run Keyword And Ignore Error    Page Should Contain Element    //h3[contains(text(),'Company Credits')]/following-sibling::div/span[@class='see-more inline']/a
    \    ${bool}=    Get from list    ${bool}    0
    \    BuiltIn.Run Keyword If    '${bool}'=='PASS'    Click Element    //h3[contains(text(),'Company Credits')]/following-sibling::div/span[@class='see-more inline']/a
    \    Sleep    10s
    \    @{List}    Get WebElements    //div[@id='company_credits_content']/ul[2]/li/a/..
    \    BuiltIn.Run Keyword And Ignore Error    First_Inner_Loop    ${ID}    ${Imdb_ID}    ${Company_Name}    ${Country}
    \    ...    ${Unique_Title}    @{List}
    \    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set \ isProcessed=1 where id=${ID}
    Disconnect From Database
    Close Browser

*** Keywords ***
Extracting_Company_Complete_Address
    [Arguments]    ${ID}    @{List}
    : FOR    ${j}    IN    @{List}
    \    ${Address}=    Get Text    ${j}
    \    ${Complete_Address}=    BuiltIn.Set Variable    ${Complete_Address}
    \    ${Complete_Address}=    BuiltIn.Catenate    ${Complete_Address}    ${Address}
    ${Complete_Address}=    String.Fetch From Left    ${Complete_Address}    See map (bing.com)
    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set companyCompleteAddress='${Complete_Address}' where id=${ID};

Fetching_Staff_Details
    [Arguments]    ${ID}    ${New_Phone_Number}    ${New_Fax_Number}    ${New_Email_ID}    @{List}
    : FOR    ${j}    IN    @{List}
    \    ${Employee_Name}    Get Text    ${j}
    \    BuiltIn.Run Keyword If    ${Count2}==1    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set staffOneEmployeeName='${Employee_Name}' where id=${ID};
    \    BuiltIn.Run Keyword If    ${Count2}==2    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set staffTwoEmployeeName='${Employee_Name}' where id=${ID};
    \    BuiltIn.Run Keyword If    ${Count2}==3    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set StaffThreeEmployeeName='${Employee_Name}' where id=${ID};
    \    ${href}    Get Element Attribute    ${j}    href
    \    ${Employee_id}=    String.Fetch From Right    ${href}    name/
    \    ${Employee_id}=    String.Fetch From Left    ${Employee_id}    /?
    \    ${Employee_id}=    String.Fetch From Left    ${Employee_id}    ?
    \    BuiltIn.Run Keyword If    ${Count2}==1    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set staffOneEmployeeID='${Employee_id}' where id=${ID};
    \    BuiltIn.Run Keyword If    ${Count2}==2    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set staffTwoEmployeeID='${Employee_id}' where id=${ID};
    \    BuiltIn.Run Keyword If    ${Count2}==3    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set staffThreeEmployeeID='${Employee_id}' where id=${ID};
    \    ${Employee_Designation}=    BuiltIn.Run Keyword And Ignore Error    Get Text    //tbody/tr[@class='staff_sortable_row'][${Count2}]/td[3]
    \    ${bool}=    Get from list    ${Employee_Designation}    0
    \    ${Employee_Designation}=    BuiltIn.Run Keyword If    '${bool}'=='PASS'    Get from list    ${Employee_Designation}    1
    \    ${Employee_Designation}=    BuiltIn.Run Keyword If    '${bool}'=='PASS'    String.Replace String    ${Employee_Designation}    '
    \    ...    ''
    \    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==1    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set staffOneEmployeeDesignation='${Employee_Designation}' where id=${ID};
    \    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==2    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set staffTwoDesignation='${Employee_Designation}' where id=${ID};
    \    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==3    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set staffThreeDesignation='${Employee_Designation}' where id=${ID};
    \    Execute Javascript    window.open()
    \    Select Window    NEW
    \    Go to    ${href}
    \    sleep    10s
    \    ${Phone_Number}=    Run Keyword And Ignore Error    Get text    //div[@id='contacts']/div[1]/div/ul/li/span/span[contains(text(),'phone')]/..
    \    ${bool}    Get From List    ${Phone_Number}    0
    \    ${Extracted_PH_Nm}=    Get From List    ${Phone_Number}    1
    \    ${Staff_Phone_Number}    Set Variable If    '${bool}'=='PASS'    ${Extracted_PH_Nm}
    \    ${Staff_Phone_Number}    BuiltIn.Run Keyword If    '${bool}'=='PASS'    String.Fetch From Left    ${Staff_Phone_Number}    phone
    \    BuiltIn.Run Keyword If    '${New_Phone_Number}'!='${Staff_Phone_Number}'    Extracting_Staff_Phone_Number    ${bool}    ${Staff_Phone_Number}    ${Count2}
    \    ...    ${ID}
    \    ${Fax_Number}=    Run Keyword And Ignore Error    Get text    //div[@id='contacts']/div[1]/div/ul/li/span/span[contains(text(),'fax')]/..
    \    ${bool}    Get From List    ${Fax_Number}    0
    \    ${Extracted_Fax_Nm}=    Get From List    ${Fax_Number}    1
    \    ${Staff_Fax_Number}    Set Variable If    '${bool}'=='PASS'    ${Extracted_Fax_Nm}
    \    ${Staff_Fax_Number}    BuiltIn.Run Keyword If    '${bool}'=='PASS'    String.Fetch From Left    ${Staff_Fax_Number}    fax
    \    BuiltIn.Run Keyword If    '${New_Fax_Number}'!='${Staff_Fax_Number}'    Extracting_Staff_Fax_Number    ${bool}    ${Staff_Fax_Number}    ${Count2}
    \    ...    ${ID}
    \    ${Email_ID}=    BuiltIn.Run Keyword And Ignore Error    Get text    //div[@id='contacts']/div[1]/div/ul/li/span/a[contains(text(),'@')]
    \    ${bool}    Get From List    ${Email_ID}    0
    \    ${Extracted_Email}=    Get From List    ${Email_ID}    1
    \    ${Staff_Email_ID}    Set Variable If    '${bool}'=='PASS'    ${Extracted_Email}
    \    BuiltIn.Run Keyword If    '${New_Email_ID}'!='${Staff_Email_ID}'    Extracting_Staff_Email_ID    ${bool}    ${Staff_Email_ID}    ${Count2}
    \    ...    ${ID}
    \    close window
    \    Sleep    10s
    \    Select Window    MAIN
    \    BuiltIn.Exit For Loop If    ${Count2}==3
    \    ${Count2}    BuiltIn.Evaluate    ${Count2}+1

Extracting_Staff_Phone_Number
    [Arguments]    ${bool}    ${Staff_Phone_Number}    ${Count2}    ${ID}
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==1    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set staffOneEmployeePhoneNumber='${Staff_Phone_Number}' where id=${ID};
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==2    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set staffTwoPhoneNumber='${Staff_Phone_Number}' where id=${ID};
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==3    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set staffThreePhoneNumber='${Staff_Phone_Number}' where id=${ID}};

Extracting_Staff_Fax_Number
    [Arguments]    ${bool}    ${Staff_Fax_Number}    ${Count2}    ${ID}
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==1    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set staffOneEmployeeFax='${Staff_Fax_Number}' where id=${ID};
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==2    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set staffTwoEmployeeFax='${Staff_Fax_Number}' where id=${ID};
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==3    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set staffThreeEmployeeFax='${Staff_Fax_Number}' where id=${ID};

Extracting_Staff_Email_ID
    [Arguments]    ${bool}    ${Staff_Email_ID}    ${Count2}    ${ID}
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==1    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set staffOneEmailID='${Staff_Email_ID}' where id=${ID};
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==2    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set staffTwoEmailID='${Staff_Email_ID}' where id=${ID};
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==3    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set staffThreeEmailID='${Staff_Email_ID}' where id=${ID};

Fetching_Affiliations_Details
    [Arguments]    ${ID}    @{List}
    : FOR    ${j}    IN    @{List}
    \    ${Affliation_Text}    Get Text    ${j}
    \    ${bool}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Be Equal As Strings    ${Affliation_Text}    Also Known As
    \    ${bool}=    Get from list    ${bool}    0
    \    BuiltIn.Run Keyword If    '${bool}'=='PASS'    Storing_Affliations_Details    ${ID}    ${row_counter}
    \    BuiltIn.Exit For Loop If    '${bool}'=='PASS'
    \    ${row_counter}    BuiltIn.Evaluate    ${row_counter}+1

Storing_Affliations_Details
    [Arguments]    ${ID}    ${row_counter}
    ${t1}=    get text    //*[@id="company_affiliation_sortable_table"]/tbody/tr[${row_counter}]/td[1]/div
    ${t2}=    get text    //*[@id="company_affiliation_sortable_table"]/tbody/tr[${row_counter}]/td[2]/div
    ${t3}=    get text    //*[@id="company_affiliation_sortable_table"]/tbody/tr[${row_counter}]/td[3]/div
    ${t4}=    BuiltIn.Catenate    ${t1}    ${t2}
    ${Affliation_Details}    BuiltIn.Catenate    ${t4}    ${t3}
    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set affiliationsDetails='${Affliation_Details}' where id=${ID};

Second_Inner_Loop
    [Arguments]    ${company_id}    ${ID}    ${Imdb_ID}    ${Company_Name}    ${Country}    ${Unique_Title}
    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set companyID='${company_id}' where id=${ID};
    Go to    https://pro.imdb.com/company/${company_id}
    sleep    10s
    ${Title}=    BuiltIn.Run Keyword And Ignore Error    Get text    css=#company_heading>div>h1
    ${bool}=    Get from list    ${Title}    0
    ${Title}=    Get from list    ${Title}    1
    ${Title}=    Run keyword if    '${bool}'=='PASS'    String.Fetch From Left    ${Title}    [
    ${Title}=    Run keyword if    '${bool}'=='PASS'    String.Fetch From Left    ${Title}    .
    Run keyword if    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set companyTitle='${Title}' where id=${ID};
    ${Country_Code}=    BuiltIn.Run Keyword And Ignore Error    Get text    css=#company_heading>div>h1>span
    ${bool}=    Get from list    ${Country_Code}    0
    ${Country_Code}=    Get from list    ${Country_Code}    1
    ${Country_Code}=    Run keyword if    '${bool}'=='PASS'    String.Fetch From Right    ${Country_Code}    [
    ${Country_Code}=    Run keyword if    '${bool}'=='PASS'    String.Fetch From Left    ${Country_Code}    ]
    Run keyword if    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set companyTerritoryCode='${Country_Code}' where id=${ID};
    ${Company_Class}=    BuiltIn.Run Keyword And Ignore Error    Get text    css=#company_heading
    ${bool}=    Get from list    ${Company_Class}    0
    ${Company_Class}=    Get from list    ${Company_Class}    1
    ${Company_Class}=    Run keyword if    '${bool}'=='PASS'    String.Fetch From Right    ${Company_Class}    ]
    Run keyword if    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set companyClassification='${Company_Class}' where id=${ID};
    ${Website_URL}    BuiltIn.Run Keyword And Ignore Error    Get Element Attribute    //div[@id='contacts']/div[1]/div/ul/li/span/div/a[contains(@class,'clickable_share_link')]    href
    ${bool}=    Get from list    ${Website_URL}    0
    ${Website_URL}=    Get from list    ${Website_URL}    1
    ${New_Website_URL}    Set Variable If    '${bool}'=='PASS'    ${Website_URL}
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set companyWebsite='${New_Website_URL}' where id=${ID};
    ${Phone_Number}=    Run Keyword And Ignore Error    Get text    //div[@id='contacts']/div[1]/div/ul/li/span/span[contains(text(),'phone')]/..
    ${bool}    Get From List    ${Phone_Number}    0
    ${Extracted_PH_Nm}=    Get From List    ${Phone_Number}    1
    ${New_Phone_Number}    Set Variable If    '${bool}'=='PASS'    ${Extracted_PH_Nm}
    ${New_Phone_Number}    BuiltIn.Run Keyword If    '${bool}'=='PASS'    String.Fetch From Left    ${New_Phone_Number}    phone
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set companyPhoneNumber='${New_Phone_Number}' where id=${ID};
    ${Fax_Number}=    Run Keyword And Ignore Error    Get text    //div[@id='contacts']/div[1]/div/ul/li/span/span[contains(text(),'fax')]/..
    ${bool}    Get From List    ${Fax_Number}    0
    ${Extracted_Fax_Nm}=    Get From List    ${Fax_Number}    1
    ${New_Fax_Number}    Set Variable If    '${bool}'=='PASS'    ${Extracted_Fax_Nm}
    ${New_Fax_Number}    BuiltIn.Run Keyword If    '${bool}'=='PASS'    String.Fetch From Left    ${New_Fax_Number}    fax
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set companyFax='${New_Fax_Number}' where id=${ID};
    ${Address}=    BuiltIn.Run Keyword And Ignore Error    Get text    css=div#contacts>div:nth-child(1)>div>div>span
    ${bool}=    Get from list    ${Address}    0
    ${Address}=    Get from list    ${Address}    1
    ${New_Address}    Set Variable If    '${bool}'=='PASS'    ${Address}
    ${New_Address}    BuiltIn.Run Keyword If    '${bool}'=='PASS'    String.Replace String    ${New_Address}    '    ''
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set companyAddress='${New_Address}' where id=${ID};
    ${Email_ID}=    BuiltIn.Run Keyword And Ignore Error    Get text    //div[@id='contacts']/div[1]/div/ul/li/span/a[contains(text(),'@')]
    ${bool}    Get From List    ${Email_ID}    0
    ${Extracted_Email}=    Get From List    ${Email_ID}    1
    ${New_Email_ID}    Set Variable If    '${bool}'=='PASS'    ${Extracted_Email}
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set companyEmail='${New_Email_ID}' where id=${ID};
    @{List}    Get WebElements    //div[@id='contacts']/div[1]/div/ul/li//div[contains(@class,'a-fixed-left-grid-col a-col-right')]/span
    BuiltIn.Run Keyword And Ignore Error    Extracting_Company_Complete_Address    ${ID}    @{List}
    Click Element    css=[data-tab-name='staff']
    sleep    10s
    @{List}    Get WebElements    css=span.a-size-base-plus>a
    BuiltIn.Run Keyword And Ignore Error    Fetching_Staff_Details    ${ID}    ${New_Phone_Number}    ${New_Fax_Number}    ${New_Email_ID}    @{List}
    Click Element    css=[data-tab-name='affiliations']
    sleep    10s
    @{List}    Get WebElements    //*[@id="company_affiliation_sortable_table"]/tbody/tr/td[1]/div
    BuiltIn.Run Keyword And Ignore Error    Fetching_Affiliations_Details    ${ID}    @{List}

First_Inner_Loop
    [Arguments]    ${ID}    ${Imdb_ID}    ${Company_Name}    ${Country}    ${Unique_Title}    @{List}
    : FOR    ${j}    IN    @{List}
    \    ${Text}    BuiltIn.Run Keyword And Ignore Error    Get Text    ${j}
    \    ${bool}=    Get From List    ${Text}    0
    \    ${Text}    BuiltIn.Run Keyword If    '${bool}'=='PASS'    Get From List    ${Text}    1
    \    ${bool}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Contain    ${Text}    ${Country}
    \    ${bool1}=    Get From List    ${bool}    0
    \    ${href}=    BuiltIn.Run Keyword If    '${bool1}'=='PASS'    Get Element Attribute    //div[@id='company_credits_content']/ul[2]/li[${Count2}]/a    href
    \    ${company_id}=    BuiltIn.Run Keyword If    '${bool1}'=='PASS'    String.Fetch From Right    ${href}    company/
    \    ${company_id}=    BuiltIn.Run Keyword If    '${bool1}'=='PASS'    String.Fetch From Left    ${company_id}    ?
    \    ${Company_Name}=    String.Replace String    ${Company_Name}    '    ''
    \    BuiltIn.Run Keyword If    '${bool1}'=='PASS'    Second_Inner_Loop    ${company_id}    ${ID}    ${Imdb_ID}
    \    ...    ${Company_Name}    ${Country}    ${Unique_Title}
    \    BuiltIn.Exit For Loop If    '${bool1}'=='PASS'
    \    ${Count2}    BuiltIn.Evaluate    ${Count2}+1
