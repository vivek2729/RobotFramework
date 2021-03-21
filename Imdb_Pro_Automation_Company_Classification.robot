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
    : FOR    ${i}    IN RANGE    3500
    \    ${list}=    DatabaseLibrary.Query    Select id,companyID from clean_movies.bd_distributor_company_output where companyClassification=' ' and companyID<>' ' and isProcessed=0 limit 1
    \    Convert To List    ${list}
    \    ${ID_List}    Evaluate    [x[0] for x in ${list}]
    \    ${Company_ID_List}    Evaluate    [x[1] for x in ${list}]
    \    ${ID}    Get From List    ${ID_List}    ${count}
    \    ${Company_ID}    Get From List    ${Company_ID_List}    ${count}
    \    BuiltIn.Run Keyword And Ignore Error    Inner_Loop    ${Company_ID}    ${ID}
    \    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set isProcessed=1 where id=${ID};
    Disconnect From Database
    Close Browser

*** Keywords ***
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

Inner_Loop
    [Arguments]    ${Company_ID}    ${ID}
    Go to    https://pro.imdb.com/company/${Company_ID}
    sleep    10s
    ${Company_Class}=    BuiltIn.Run Keyword And Ignore Error    Get text    css=#company_heading
    ${bool}=    Get from list    ${Company_Class}    0
    ${Company_Class}=    Get from list    ${Company_Class}    1
    ${Company_Class}=    Run keyword if    '${bool}'=='PASS'    String.Fetch From Right    ${Company_Class}    ]
    Run keyword if    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set companyClassification='${Company_Class}' where id=${ID};
    ${Address}=    BuiltIn.Run Keyword And Ignore Error    Get text    css=div#contacts>div:nth-child(1)>div>div>span
    ${bool}=    Get from list    ${Address}    0
    ${Address}=    Get from list    ${Address}    1
    ${New_Address}    Set Variable If    '${bool}'=='PASS'    ${Address}
    ${New_Address}    BuiltIn.Run Keyword If    '${bool}'=='PASS'    String.Replace String    ${New_Address}    '    ''
    BuiltIn.Run Keyword If    '${bool}'=='PASS'    DatabaseLibrary.Execute Sql String    update clean_movies.bd_distributor_company_output set companyAddress='${New_Address}' where id=${ID};
    Click Element    css=[data-tab-name='affiliations']
    sleep    10s
    @{List}    Get WebElements    //*[@id="company_affiliation_sortable_table"]/tbody/tr/td[1]/div
    BuiltIn.Run Keyword And Ignore Error    Fetching_Affiliations_Details    ${ID}    @{List}
