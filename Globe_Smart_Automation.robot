*** Settings ***
Library           SeleniumLibrary
Library           DatabaseLibrary
Library           ExcelLibrary
Library           OperatingSystem
Library           DateTime
Resource          resource.robot

*** Test Cases ***
Globe_Samart_Automation
    Open Browser    https://www.google.com    chrome
    Maximize Browser Window
    Sleep    2s
    Go to    https://globesmart.aperianglobal.com/culture-guides/ar/communication-styles
    Sleep    20s
    Click Element    //a[contains(text(),'Log In')]
    sleep    5s
    Input Text    //input[@name='email']    phillita2000@yahoo.com
    Sleep    5s
    Input Text    //input[@name='password']    SXRocks2020!
    Sleep    5s
    Click Element    //button[@name='submit']
    Sleep    10s
    DatabaseLibrary.Connect To Database    pymysql    nbcu_pilot    vivekkumar.pandey    MMaXm83dZD18A4AA    dev-scraper.csoaie2kvgsc.us-east-1.rds.amazonaws.com    3306
    @{Culture_List}    SeleniumLibrary.Get WebElements    css=#cultures-filter>div>div>ul>li>a
    : FOR    ${j}    IN    @{Culture_List}
    \    Click Element    css=button[aria-controls='#culture-list']
    \    sleep    5s
    \    ${Culture}=    Get Text    //div[@id='cultures-filter']/div/div/ul/li[${count}]/a
    \    Click Element    //div[@id='cultures-filter']/div/div/ul/li[${count}]/a
    \    Sleep    15s
    \    BuiltIn.Run Keyword And Ignore Error    Section_loop    ${Culture}
    \    ${count}    BuiltIn.Evaluate    ${count}+1
    Close All Browsers
    Disconnect From Database

*** Keywords ***
Group_Title_Extraction
    [Arguments]    ${count}    ${Title}    ${Count3}    @{Group_Title_List}
    : FOR    ${j}    IN    @{Group_Title_List}
    \    ${Group_Title}=    Get Text    ${j}
    \    ${New_gr_ttile}=    BuiltIn.Catenate    ${New_gr_ttile}    ${Group_Title}
    ${EMPTY}
    @{Explanation_List}    Get WebElements    css=article.topic-layout__article>div.concept-grouping.util-clearfix:nth-child(${count})>div.concept-grouping__explanation
    BuiltIn.Run Keyword And Ignore Error    Explanation_Extraction    ${count}    ${Title}    ${New_gr_ttile}    ${Count3}    @{Explanation_List}

Explanation_Extraction
    [Arguments]    ${count}    ${Title}    ${New_gr_ttile}    ${Count3}    @{Explanation_List}
    : FOR    ${j}    IN    @{Explanation_List}
    \    ${Explanation}=    Get Text    ${j}
    \    ${New_Explanation}    BuiltIn.Catenate    ${New_Explanation}    ${Explanation}
    \    Comment    BuiltIn.Run Keyword If    ${count}==2    DatabaseLibrary.Execute Sql String    update nbcu_pilot.GlobeSmart set First_Section= '${Title} ${New_gr_Title} ${New_Explanation}' where id=${Count3}
    \    Comment    BuiltIn.Run Keyword If    ${count}==3    DatabaseLibrary.Execute Sql String    update nbcu_pilot.GlobeSmart set Second_Section= '${Title} ${New_gr_Title} ${New_Explanation}' where id=${Count3}
    \    Comment    BuiltIn.Run Keyword If    ${count}==4    DatabaseLibrary.Execute Sql String    update nbcu_pilot.GlobeSmart set Third_Section= '${Title} ${New_gr_Title} ${New_Explanation}' where id=${Count3}
    \    Comment    BuiltIn.Run Keyword If    ${count}==5    DatabaseLibrary.Execute Sql String    update nbcu_pilot.GlobeSmart set Fourth_Section= '${Title} ${New_gr_Title} ${New_Explanation}' where id=${Count3}
    \    BuiltIn.Run Keyword If    ${count}==6    DatabaseLibrary.Execute Sql String    update nbcu_pilot.GlobeSmart set Fifth_Section= '${Title} ${New_gr_Title} ${New_Explanation}' where id=${Count3}

Section_loop
    [Arguments]    ${Culture}
    @{Section_List}    Get WebElements    css=#section-list>ul>li>a
    : FOR    ${j}    IN    @{Section_List}
    \    Click Element    css=button[aria-controls='#section-list']
    \    sleep    5s
    \    ${Section}=    Get Text    //section[@id='section-list']/ul/li[${count}]
    \    Click Element    //section[@id='section-list']/ul/li[${count}]
    \    Sleep    15s
    \    BuiltIn.Run Keyword And Ignore Error    Topics_loop    ${Culture}    ${Section}
    \    ${count}    BuiltIn.Evaluate    ${count}+1

Topics_loop
    [Arguments]    ${Culture}    ${Section}
    @{Topics_List}    Get WebElements    css=#topic-list>ul>li>a
    : FOR    ${j}    IN    @{Topics_List}
    \    Click Element    css=button[aria-controls='#topic-list']
    \    sleep    5s
    \    ${Topic}    Get Text    //section[@id='topic-list']/ul/li[${count}]
    \    Click Element    //section[@id='topic-list']/ul/li[${count}]
    \    Sleep    15s
    \    DatabaseLibrary.Execute Sql String    INSERT INTO nbcu_pilot.GlobeSmart (`Culture`) VALUES ('${Culture}')
    \    ${list}=    DatabaseLibrary.Query    select max(id) from nbcu_pilot.GlobeSmart;
    \    Convert To List    ${list}
    \    ${list}=    Evaluate    [x[0] for x in ${list}]
    \    ${Count3}=    Get From List    ${list}    0
    \    DatabaseLibrary.Execute Sql String    update nbcu_pilot.GlobeSmart set Topic= '${Topic}' where id=${Count3}
    \    DatabaseLibrary.Execute Sql String    update nbcu_pilot.GlobeSmart set Section= '${Section}' where id=${Count3}
    \    BuiltIn.Run Keyword And Ignore Error    Main_Extraction    ${Count3}
    \    ${count}    BuiltIn.Evaluate    ${count}+1

Main_Extraction
    [Arguments]    ${Count3}
    @{List}=    SeleniumLibrary.Get WebElements    css=div.concept-grouping.util-clearfix
    : FOR    ${j}    IN    @{List}
    \    ${Text}=    Get Text    ${j}
    \    ${New_gr_Title}=    BuiltIn.Catenate    ${New_gr_Title}    ${Text}
    \    ${New_gr_Title}=    Replace String    ${New_gr_Title}    '    ""
    \    Comment    BuiltIn.Run Keyword If    ${count}==2    DatabaseLibrary.Execute Sql String    update nbcu_pilot.GlobeSmart set Second_Section= ' ${New_gr_Title}' where id=${Count3}
    \    Comment    BuiltIn.Run Keyword If    ${count}==3    DatabaseLibrary.Execute Sql String    update nbcu_pilot.GlobeSmart set Third_Section= '${New_gr_Title}' where id=${Count3}
    \    Comment    BuiltIn.Run Keyword If    ${count}==4    DatabaseLibrary.Execute Sql String    update nbcu_pilot.GlobeSmart set Fourth_Section= '${New_gr_Title}' where id=${Count3}
    \    Comment    BuiltIn.Run Keyword If    ${count}==5    DatabaseLibrary.Execute Sql String    update nbcu_pilot.GlobeSmart set Fifth_Section= '${New_gr_Title}' where id=${Count3}
    \    Comment    ${count}    BuiltIn.Evaluate    ${count}+1
    \    Comment    ${New_gr_Title}    BuiltIn.Set Variable    '${Empty}'
    \    Comment    ${Title}=    Get Text    css=article.topic-layout__article>div.concept-grouping.util-clearfix:nth-child(${count})>h3.concept-grouping__title
    \    Comment    @{Group_Title_List}    Get WebElements    css=article.topic-layout__article>div.concept-grouping.util-clearfix:nth-child(${count})>h4.concept-grouping__concept-title
    \    Comment    BuiltIn.Run Keyword And Ignore Error    Group_Title_Extraction    ${count}    ${Title}    ${Count3}
    \    ...    @{Group_Title_List}
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.GlobeSmart set Details= '${New_gr_Title}' where id=${Count3}
