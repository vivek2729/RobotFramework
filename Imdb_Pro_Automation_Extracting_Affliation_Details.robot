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
    : FOR    ${i}    IN RANGE    5000
    \    ${list}=    DatabaseLibrary.Query    Select companyId,id from clean_movies.imdbpro_scraping_output where isProcessed=0 and companyId<>' ' limit 1
    \    Convert To List    ${list}
    \    ${CompanyID_List}    Evaluate    [x[0] for x in ${list}]
    \    ${ID_List}    Evaluate    [x[1] for x in ${list}]
    \    ${CompanyId}=    Get From List    ${CompanyID_List}    ${count}
    \    ${id}=    Get From List    ${ID_List}    ${count}
    \    Go to    https://pro.imdb.com/company/${CompanyId}/affiliations
    \    Sleep    20s
    \    @{List}    Get WebElements    //*[@id="company_affiliation_sortable_table"]/tbody/tr/td[1]/div
    \    BuiltIn.Run Keyword And Ignore Error    First_Inner_Loop    ${CompanyId}    @{List}
    \    DatabaseLibrary.Execute Sql String    update clean_movies.imdbpro_scraping_output set isProcessed=1 where id=${id}
    Disconnect From Database
    Close Browser

*** Keywords ***
Fetching_Affiliations_Details
    [Arguments]    ${Count3}    @{List}
    : FOR    ${j}    IN    @{List}
    \    BuiltIn.Run Keyword And Ignore Error    Storing_Affliations_Details    ${Count3}    ${row_counter}
    \    ${row_counter}    BuiltIn.Evaluate    ${row_counter}+1

Storing_Affliations_Details
    [Arguments]    ${Count3}    ${row_counter}
    ${Affliation_Type}    BuiltIn.Run Keyword And Ignore Error    Get text    //*[@id="company_affiliation_sortable_table"]/tbody/tr[${row_counter}]/td[1]
    ${bool}=    Get from list    ${Affliation_Type}    0
    ${Affliation_Type}    Get from list    ${Affliation_Type}    1
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.affiliations_details set type='${Affliation_Type}' where id=${Count3};
    ${Company_Name}    BuiltIn.Run Keyword And Ignore Error    Get text    //*[@id="company_affiliation_sortable_table"]/tbody/tr[${row_counter}]/td[2]/div/span/a
    ${bool}=    Get from list    ${Company_Name}    0
    ${Company_Name}    Get from list    ${Company_Name}    1
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.affiliations_details set companyName='${Company_Name}' where id=${Count3};
    ${href}    BuiltIn.Run Keyword And Ignore Error    Get Element Attribute    //*[@id="company_affiliation_sortable_table"]/tbody/tr[${row_counter}]/td[2]/div/span/a    href
    ${bool}=    Get from list    ${href}    0
    ${href}    Get from list    ${href}    1
    ${company_id}    BuiltIn.Run Keyword If    '${bool}'=='PASS'    String.Fetch From Right    ${href}    company/
    ${company_id}    BuiltIn.Run Keyword If    '${bool}'=='PASS'    String.Fetch From Left    ${company_id}    ?
    ${company_id}    BuiltIn.Run Keyword If    '${bool}'=='PASS'    String.Fetch From Left    ${company_id}    /
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.affiliations_details set companyId='${company_id}' where id=${Count3};
    ${Territoary}    BuiltIn.Run Keyword And Ignore Error    Get Text    //*[@id="company_affiliation_sortable_table"]/tbody/tr[${row_counter}]/td[2]/div/span/span
    ${bool}=    Get from list    ${Territoary}    0
    ${Territoary}    Get from list    ${Territoary}    1
    ${Territoary}    BuiltIn.Run Keyword If    '${bool}'=='PASS'    String.Fetch From Right    ${Territoary}    [
    ${Territoary}    BuiltIn.Run Keyword If    '${bool}'=='PASS'    String.Fetch From Left    ${Territoary}    ]
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.affiliations_details set territoryCode='${Territoary}' where id=${Count3};
    ${Email_id}    BuiltIn.Run Keyword And Ignore Error    Get Text    //*[@id="company_affiliation_sortable_table"]/tbody/tr[${row_counter}]/td[3]/div/a[contains(text(),'@')]
    ${bool}=    Get from list    ${Email_id}    0
    ${Email_id}    Get from list    ${Email_id}    1
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.affiliations_details set emailId='${Email_id}' where id=${Count3};
    ${Website}    BuiltIn.Run Keyword And Ignore Error    Get Text    //*[@id="company_affiliation_sortable_table"]/tbody/tr[${row_counter}]/td[3]/div/a[contains(@href,'http:')]
    ${bool}=    Get from list    ${Website}    0
    ${Website}    Get from list    ${Website}    1
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.affiliations_details set website='${Website}' where id=${Count3};
    ${Text}    BuiltIn.Run Keyword And Ignore Error    Get text    //*[@id="company_affiliation_sortable_table"]/tbody/tr[${row_counter}]/td[3]/div
    ${bool}=    Get From List    ${Text}    0
    ${Text}    Get From List    ${Text}    1
    @{List}    BuiltIn.Run Keyword If    '${bool}'=='PASS'    String.Split String    ${Text}    \n
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    Extracting_Phone_Number_Fax_Number    ${Count3}    @{List}

Extracting_Phone_Number_Fax_Number
    [Arguments]    ${Count3}    @{List}
    : FOR    ${j}    IN    @{List}
    \    ${bool}    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Contain    ${j}    Phone:
    \    ${bool}    Get from list    ${bool}    0
    \    BuiltIn.Run Keyword If    '${bool}'=='PASS'    Extracting_Phone_Number    ${Count3}    ${j}
    \    ${bool}    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Contain    ${j}    Fax:
    \    ${bool}    Get from list    ${bool}    0
    \    BuiltIn.Run Keyword If    '${bool}'=='PASS'    Extracting_Fax_number    ${Count3}    ${j}

Extracting_Phone_Number
    [Arguments]    ${Count3}    ${j}
    ${j}    String.Fetch From Right    ${j}    Phone:
    DatabaseLibrary.Execute Sql String    update clean_movies.affiliations_details set phoneNumber='${j}' where id=${Count3};

Extracting_Fax_number
    [Arguments]    ${Count3}    ${j}
    ${j}    String.Fetch From Right    ${j}    Fax:
    DatabaseLibrary.Execute Sql String    update clean_movies.affiliations_details set faxNumber='${j}' where id=${Count3};

First_Inner_Loop
    [Arguments]    ${CompanyId}    @{List}
    : FOR    ${j}    IN    @{List}
    \    DatabaseLibrary.Execute Sql String    INSERT INTO clean_movies.affiliations_details (`masterCompanyId`) VALUES ('${CompanyId}')
    \    Sleep    3s
    \    ${list}=    DatabaseLibrary.Query    select max(id) from clean_movies.affiliations_details;
    \    Convert To List    ${list}
    \    ${list}=    Evaluate    [x[0] for x in ${list}]
    \    ${Count3}=    Get From List    ${list}    0
    \    BuiltIn.Run Keyword And Ignore Error    Storing_Affliations_Details    ${Count3}    ${row_counter}
    \    ${row_counter}    BuiltIn.Evaluate    ${row_counter}+1
