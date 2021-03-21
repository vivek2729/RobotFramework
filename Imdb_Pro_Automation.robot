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
    Input Text    css=input[name='email']    Username
    Input Text    css=input[name='password']    Password
    Click Element    css=#signInSubmit
    sleep    20s
    : FOR    ${i}    IN RANGE    6000
    \    ${list}=    DatabaseLibrary.Query    Select imdbId,companyName,country,id from clean_movies.imdbpro_scraping_inputs where isProcessed=0 limit 1
    \    Convert To List    ${list}
    \    ${IMDB_ID_List}    Evaluate    [x[0] for x in ${list}]
    \    ${Company_Name_List}    Evaluate    [x[1] for x in ${list}]
    \    ${Country_List}    Evaluate    [x[2] for x in ${list}]
    \    ${ID_List}    Evaluate    [x[3] for x in ${list}]
    \    ${Imdb_ID}=    Get From List    ${IMDB_ID_List}    ${count}
    \    ${Company_Name}=    Get From List    ${Company_Name_List}    ${count}
    \    ${Country}=    Get From List    ${Country_List}    ${count}
    \    ${id}=    Get From List    ${ID_List}    ${count}
    \    DatabaseLibrary.Execute Sql String    INSERT INTO clean_movies.imdbpro_scraping_output (`imdbId`) VALUES ('${Imdb_ID} ')
    \    Sleep    5s
    \    ${list}=    DatabaseLibrary.Query    select max(id) from clean_movies.imdbpro_scraping_output;
    \    Convert To List    ${list}
    \    ${list}=    Evaluate    [x[0] for x in ${list}]
    \    ${Count3}=    Get From List    ${list}    0
    \    Sleep    5s
    \    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set country='${Country}' where id=${Count3};
    \    Go to    https://www.imdb.com/title/${Imdb_ID}/
    \    Sleep    20s
    \    ${bool}=    BuiltIn.Run Keyword And Ignore Error    Page Should Contain Element    //h3[contains(text(),'Company Credits')]/following-sibling::div/span[@class='see-more inline']/a
    \    ${bool}=    Get from list    ${bool}    0
    \    BuiltIn.Run Keyword If    '${bool}'=='PASS'    Click Element    //h3[contains(text(),'Company Credits')]/following-sibling::div/span[@class='see-more inline']/a
    \    Sleep    10s
    \    @{List}    Get WebElements    //div[@id='company_credits_content']/ul[2]/li/a/..
    \    BuiltIn.Run Keyword And Ignore Error    First_Inner_Loop    ${Count3}    ${Imdb_ID}    ${Company_Name}    ${Country}
    \    ...    @{List}
    \    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_inputs set \ isProcessed=1 where id=${id}
    Disconnect From Database
    Close Browser

*** Keywords ***
Extracting_Company_Complete_Address
    [Arguments]    ${Count3}    @{List}
    : FOR    ${j}    IN    @{List}
    \    ${Address}=    Get Text    ${j}
    \    ${Complete_Address}=    BuiltIn.Set Variable    ${Complete_Address}
    \    ${Complete_Address}=    BuiltIn.Catenate    ${Complete_Address}    ${Address}
    ${Complete_Address}=    String.Fetch From Left    ${Complete_Address}    See map (bing.com)
    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set companyCompleteAddress='${Complete_Address}' where id=${Count3};

Fetching_Staff_Details
    [Arguments]    ${Count3}    ${New_Phone_Number}    ${New_Fax_Number}    ${New_Email_ID}    @{List}
    : FOR    ${j}    IN    @{List}
    \    ${Employee_Name}    Get Text    ${j}
    \    BuiltIn.Run Keyword If    ${Count2}==1    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set staffOneEmployeeName='${Employee_Name}' where id=${Count3};
    \    BuiltIn.Run Keyword If    ${Count2}==2    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set staffTwoEmployeeName='${Employee_Name}' where id=${Count3};
    \    BuiltIn.Run Keyword If    ${Count2}==3    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set StaffThreeEmployeeName='${Employee_Name}' where id=${Count3};
    \    ${href}    Get Element Attribute    ${j}    href
    \    ${Employee_id}=    String.Fetch From Right    ${href}    name/
    \    ${Employee_id}=    String.Fetch From Left    ${Employee_id}    /?
    \    ${Employee_id}=    String.Fetch From Left    ${Employee_id}    ?
    \    BuiltIn.Run Keyword If    ${Count2}==1    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set staffOneEmployeeID='${Employee_id}' where id=${Count3};
    \    BuiltIn.Run Keyword If    ${Count2}==2    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set staffTwoEmployeeID='${Employee_id}' where id=${Count3};
    \    BuiltIn.Run Keyword If    ${Count2}==3    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set staffThreeEmployeeID='${Employee_id}' where id=${Count3};
    \    ${Employee_Designation}=    BuiltIn.Run Keyword And Ignore Error    Get Text    //tbody/tr[@class='staff_sortable_row'][${Count2}]/td[3]
    \    ${bool}=    Get from list    ${Employee_Designation}    0
    \    ${Employee_Designation}=    BuiltIn.Run Keyword If    '${bool}'=='PASS'    Get from list    ${Employee_Designation}    1
    \    ${Employee_Designation}=    BuiltIn.Run Keyword If    '${bool}'=='PASS'    String.Replace String    ${Employee_Designation}    '
    \    ...    ''
    \    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==1    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set staffOneEmployeeDesignation='${Employee_Designation}' where id=${Count3};
    \    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==2    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set staffTwoDesignation='${Employee_Designation}' where id=${Count3};
    \    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==3    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set staffThreeDesignation='${Employee_Designation}' where id=${Count3};
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
    \    ...    ${Count3}
    \    ${Fax_Number}=    Run Keyword And Ignore Error    Get text    //div[@id='contacts']/div[1]/div/ul/li/span/span[contains(text(),'fax')]/..
    \    ${bool}    Get From List    ${Fax_Number}    0
    \    ${Extracted_Fax_Nm}=    Get From List    ${Fax_Number}    1
    \    ${Staff_Fax_Number}    Set Variable If    '${bool}'=='PASS'    ${Extracted_Fax_Nm}
    \    ${Staff_Fax_Number}    BuiltIn.Run Keyword If    '${bool}'=='PASS'    String.Fetch From Left    ${Staff_Fax_Number}    fax
    \    BuiltIn.Run Keyword If    '${New_Fax_Number}'!='${Staff_Fax_Number}'    Extracting_Staff_Fax_Number    ${bool}    ${Staff_Fax_Number}    ${Count2}
    \    ...    ${Count3}
    \    ${Email_ID}=    BuiltIn.Run Keyword And Ignore Error    Get text    //div[@id='contacts']/div[1]/div/ul/li/span/a[contains(text(),'@')]
    \    ${bool}    Get From List    ${Email_ID}    0
    \    ${Extracted_Email}=    Get From List    ${Email_ID}    1
    \    ${Staff_Email_ID}    Set Variable If    '${bool}'=='PASS'    ${Extracted_Email}
    \    BuiltIn.Run Keyword If    '${New_Email_ID}'!='${Staff_Email_ID}'    Extracting_Staff_Email_ID    ${bool}    ${Staff_Email_ID}    ${Count2}
    \    ...    ${Count3}
    \    close window
    \    Sleep    10s
    \    Select Window    MAIN
    \    BuiltIn.Exit For Loop If    ${Count2}==3
    \    ${Count2}    BuiltIn.Evaluate    ${Count2}+1

Extracting_Staff_Phone_Number
    [Arguments]    ${bool}    ${Staff_Phone_Number}    ${Count2}    ${Count3}
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==1    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set staffOneEmployeePhoneNumber='${Staff_Phone_Number}' where id=${Count3};
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==2    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set staffTwoPhoneNumber='${Staff_Phone_Number}' where id=${Count3};
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==3    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set staffThreePhoneNumber='${Staff_Phone_Number}' where id=${Count3};

Extracting_Staff_Fax_Number
    [Arguments]    ${bool}    ${Staff_Fax_Number}    ${Count2}    ${Count3}
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==1    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set staffOneEmployeeFax='${Staff_Fax_Number}' where id=${Count3};
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==2    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set staffTwoEmployeeFax='${Staff_Fax_Number}' where id=${Count3};
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==3    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set staffThreeEmployeeFax='${Staff_Fax_Number}' where id=${Count3};

Extracting_Staff_Email_ID
    [Arguments]    ${bool}    ${Staff_Email_ID}    ${Count2}    ${Count3}
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==1    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set staffOneEmailID='${Staff_Email_ID}' where id=${Count3};
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==2    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set staffTwoEmailID='${Staff_Email_ID}' where id=${Count3};
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    BuiltIn.Run Keyword If    ${Count2}==3    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set staffThreeEmailID='${Staff_Email_ID}' where id=${Count3};

Fetching_Affiliations_Details
    [Arguments]    ${Count3}    @{List}
    : FOR    ${j}    IN    @{List}
    \    ${Affliation_Text}    Get Text    ${j}
    \    ${bool}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Be Equal As Strings    ${Affliation_Text}    Also Known As
    \    ${bool}=    Get from list    ${bool}    0
    \    BuiltIn.Run Keyword If    '${bool}'=='PASS'    Storing_Affliations_Details    ${Count3}    ${row_counter}
    \    BuiltIn.Exit For Loop If    '${bool}'=='PASS'
    \    ${row_counter}    BuiltIn.Evaluate    ${row_counter}+1

Storing_Affliations_Details
    [Arguments]    ${Count3}    ${row_counter}
    ${t1}=    get text    //*[@id="company_affiliation_sortable_table"]/tbody/tr[${row_counter}]/td[1]/div
    ${t2}=    get text    //*[@id="company_affiliation_sortable_table"]/tbody/tr[${row_counter}]/td[2]/div
    ${t3}=    get text    //*[@id="company_affiliation_sortable_table"]/tbody/tr[${row_counter}]/td[3]/div
    ${t4}=    BuiltIn.Catenate    ${t1}    ${t2}
    ${Affliation_Details}    BuiltIn.Catenate    ${t4}    ${t3}
    DatabaseLibrary.Execute Sql String    update clean_movie.imdbpro_scraping_output set affiliationsDetails='${Affliation_Details}' where id=${Count3};

Second_Inner_Loop
    [Arguments]    ${company_id}    ${Count3}    ${Imdb_ID}    ${Company_Name}    ${Country}
    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set companyID='${company_id}' where id=${Count3};
    Go to    https://pro.imdb.com/company/${company_id}
    sleep    10s
    ${Title}=    BuiltIn.Run Keyword And Ignore Error    Get text    css=#company_heading>div>h1
    ${bool}=    Get from list    ${Title}    0
    ${Title}=    Get from list    ${Title}    1
    ${Title}=    Run keyword if    '${bool}'=='PASS'    String.Fetch From Left    ${Title}    [
    ${Title}=    Run keyword if    '${bool}'=='PASS'    String.Fetch From Left    ${Title}    .
    ${Title}=    Run keyword if    '${bool}'=='PASS'    String.Replace String    ${Title}    '    "
    Run keyword if    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set companyTitle='${Title}' where id=${Count3};
    ${Country_Code}=    BuiltIn.Run Keyword And Ignore Error    Get text    css=#company_heading>div>h1>span
    ${bool}=    Get from list    ${Country_Code}    0
    ${Country_Code}=    Get from list    ${Country_Code}    1
    ${Country_Code}=    Run keyword if    '${bool}'=='PASS'    String.Fetch From Right    ${Country_Code}    [
    ${Country_Code}=    Run keyword if    '${bool}'=='PASS'    String.Fetch From Left    ${Country_Code}    ]
    Run keyword if    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set companyTerritoryCode='${Country_Code}' where id=${Count3};
    ${Company_Class}=    BuiltIn.Run Keyword And Ignore Error    Get text    css=#company_heading
    ${bool}=    Get from list    ${Company_Class}    0
    ${Company_Class}=    Get from list    ${Company_Class}    1
    ${Company_Class}=    Run keyword if    '${bool}'=='PASS'    String.Fetch From Right    ${Company_Class}    ]
    Run keyword if    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set companyClassification='${Company_Class}' where id=${Count3};
    ${Website_URL}    BuiltIn.Run Keyword And Ignore Error    Get Element Attribute    //div[@id='contacts']/div[1]/div/ul/li/span/div/a[contains(@class,'clickable_share_link')]    href
    ${bool}=    Get from list    ${Website_URL}    0
    ${Website_URL}=    Get from list    ${Website_URL}    1
    ${New_Website_URL}    Set Variable If    '${bool}'=='PASS'    ${Website_URL}
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set companyWebsite='${New_Website_URL}' where id=${Count3};
    ${Phone_Number}=    Run Keyword And Ignore Error    Get text    //div[@id='contacts']/div[1]/div/ul/li/span/span[contains(text(),'phone')]/..
    ${bool}    Get From List    ${Phone_Number}    0
    ${Extracted_PH_Nm}=    Get From List    ${Phone_Number}    1
    ${New_Phone_Number}    Set Variable If    '${bool}'=='PASS'    ${Extracted_PH_Nm}
    ${New_Phone_Number}    BuiltIn.Run Keyword If    '${bool}'=='PASS'    String.Fetch From Left    ${New_Phone_Number}    phone
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set companyPhoneNumber='${New_Phone_Number}' where id=${Count3};
    ${Fax_Number}=    Run Keyword And Ignore Error    Get text    //div[@id='contacts']/div[1]/div/ul/li/span/span[contains(text(),'fax')]/..
    ${bool}    Get From List    ${Fax_Number}    0
    ${Extracted_Fax_Nm}=    Get From List    ${Fax_Number}    1
    ${New_Fax_Number}    Set Variable If    '${bool}'=='PASS'    ${Extracted_Fax_Nm}
    ${New_Fax_Number}    BuiltIn.Run Keyword If    '${bool}'=='PASS'    String.Fetch From Left    ${New_Fax_Number}    fax
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set companyFax='${New_Fax_Number}' where id=${Count3};
    ${Address}=    BuiltIn.Run Keyword And Ignore Error    Get text    css=div#contacts>div:nth-child(1)>div>div>span
    ${bool}=    Get from list    ${Address}    0
    ${Address}=    Get from list    ${Address}    1
    ${New_Address}    Set Variable If    '${bool}'=='PASS'    ${Address}
    ${New_Address}    BuiltIn.Run Keyword If    '${bool}'=='PASS'    String.Replace String    ${New_Address}    '    ''
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set companyAddress='${New_Address}' where id=${Count3};
    ${Email_ID}=    BuiltIn.Run Keyword And Ignore Error    Get text    //div[@id='contacts']/div[1]/div/ul/li/span/a[contains(text(),'@')]
    ${bool}    Get From List    ${Email_ID}    0
    ${Extracted_Email}=    Get From List    ${Email_ID}    1
    ${New_Email_ID}    Set Variable If    '${bool}'=='PASS'    ${Extracted_Email}
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set companyEmail='${New_Email_ID}' where id=${Count3};
    @{List}    Get WebElements    //div[@id='contacts']/div[1]/div/ul/li//div[contains(@class,'a-fixed-left-grid-col a-col-right')]/span
    BuiltIn.Run Keyword And Ignore Error    Extracting_Company_Complete_Address    ${Count3}    @{List}
    Click Element    css=[data-tab-name='staff']
    sleep    10s
    @{List}    Get WebElements    css=span.a-size-base-plus>a
    BuiltIn.Run Keyword And Ignore Error    Fetching_Staff_Details    ${Count3}    ${New_Phone_Number}    ${New_Fax_Number}    ${New_Email_ID}    @{List}
    Click Element    css=[data-tab-name='affiliations']
    sleep    10s
    @{List}    Get WebElements    //*[@id="company_affiliation_sortable_table"]/tbody/tr/td[1]/div
    BuiltIn.Run Keyword And Ignore Error    Fetching_Affiliations_Details    ${Count3}    @{List}

First_Inner_Loop
    [Arguments]    ${Count3}    ${Imdb_ID}    ${Company_Name}    ${Country}    @{List}
    : FOR    ${j}    IN    @{List}
    \    ${Text}    BuiltIn.Run Keyword And Ignore Error    Get Text    ${j}
    \    ${bool}=    Get From List    ${Text}    0
    \    ${Text}    BuiltIn.Run Keyword If    '${bool}'=='PASS'    Get From List    ${Text}    1
    \    ${bool}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Contain    ${Text}    ${Country}
    \    ${bol}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Contain    ${Text}    ${Company_Name}
    \    ${bool1}=    Get From List    ${bool}    0
    \    ${bool2}=    Get From List    ${bol}    0
    \    ${href}=    BuiltIn.Run Keyword If    '${bool1}'=='PASS'    BuiltIn.Run Keyword If    '${bool2}'=='PASS'    Get Element Attribute
    \    ...    //div[@id='company_credits_content']/ul[2]/li[${Count2}]/a    href
    \    ${company_id}=    BuiltIn.Run Keyword If    '${bool1}'=='PASS'    BuiltIn.Run Keyword If    '${bool2}'=='PASS'    String.Fetch From Right
    \    ...    ${href}    company/
    \    ${company_id}=    BuiltIn.Run Keyword If    '${bool1}'=='PASS'    BuiltIn.Run Keyword If    '${bool2}'=='PASS'    String.Fetch From Left
    \    ...    ${company_id}    ?
    \    ${Company_Name}=    String.Replace String    ${Company_Name}    '    ''
    \    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set companyName='${Company_Name}' where id=${Count3};
    \    BuiltIn.Run Keyword If    '${bool1}'=='PASS'    BuiltIn.Run Keyword If    '${bool2}'=='PASS'    Second_Inner_Loop    ${company_id}
    \    ...    ${Count3}    ${Imdb_ID}    ${Company_Name}    ${Country}
    \    BuiltIn.Run Keyword If    '${bool1}'=='PASS'    BuiltIn.Run Keyword If    '${bool2}'=='PASS'    BuiltIn.Exit For Loop
    \    ${Count2}    BuiltIn.Evaluate    ${Count2}+1
