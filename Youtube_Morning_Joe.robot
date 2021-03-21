*** Settings ***
Library           SeleniumLibrary
Library           DatabaseLibrary
Library           OperatingSystem
Library           DateTime
Resource          resource.robot

*** Test Cases ***
Morning_Joe_Automation
    DatabaseLibrary.Connect To Database    pymysql    nbcu_pilot    vivekkumar.pandey    MMaXm83dZD18A4AA    dev-scraper.csoaie2kvgsc.us-east-1.rds.amazonaws.com    3306
    SeleniumLibrary.Open Browser    https://www.youtube.com/results?search_query=morning+joe&sp=CAISBAgDEAE%253D    chrome
    Maximize Browser Window
    Sleep    5s
    BuiltIn.Run Keyword And Ignore Error    Scroll page to location    0    50000
    Sleep    10s
    BuiltIn.Run Keyword And Ignore Error    Scroll page to location    0    100000
    Sleep    10s
    @{List}=    Get WebElements    css=div#contents>ytd-video-renderer
    : FOR    ${j}    IN    @{List}
    \    Sleep    10s
    \    BuiltIn.Exit For Loop If    ${Count2}==51
    \    ${bool}=    BuiltIn.Run Keyword And Ignore Error    Extracting_Details_From_Main_Page    ${Count2}
    \    ${Count2}    BuiltIn.Evaluate    ${Count2}+1
    \    ${bool}    Get From List    ${bool}    0
    \    BuiltIn.Run Keyword If    '${bool}'=='PASS'    Close Window
    \    Select Window    Main
    \    Sleep    5s
    Close Browser

*** Keywords ***
Extracting_Details_From_URL
    [Arguments]    ${URL}    ${Count3}
    Execute Javascript    window.open()
    Select Window    NEW
    Sleep    10s
    Go To    ${URL}
    Sleep    10s
    ${Date}=    Get Text    css=div#date>yt-formatted-string
    ${Date}=    String.Replace String    ${Date}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Morning_Joe set Date= '${Date}' where id=${Count3}
    Sleep    5s
    ${Full_View_Count}=    Get Text    css=div#count>yt-view-count-renderer>span:nth-child(1)
    ${Full_View_Count}=    String.Replace String    ${Full_View_Count}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Morning_Joe set Full_View_Count ='${Full_View_Count}' where id=${Count3}
    Sleep    5s
    ${Short_View_Count}=    Get Text    css=div#count>yt-view-count-renderer>span:nth-child(2)
    ${Short_View_Count}=    String.Replace String    ${Short_View_Count}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Morning_Joe set Short_View_Count= '${Short_View_Count}' where id='${Count3}'
    Sleep    5s
    ${Total_Likes}=    Get Text    css=#top-level-buttons>ytd-toggle-button-renderer:nth-child(1)>a>yt-formatted-string#text
    ${Total_Likes}=    String.Replace String    ${Total_Likes}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Morning_Joe set Total_Likes ='${Total_Likes}' where id=${Count3}
    Sleep    5s
    ${Total_Dis_Likes}=    Get Text    css=#top-level-buttons>ytd-toggle-button-renderer:nth-child(2)>a>yt-formatted-string#text
    ${Total_Dis_Likes}=    String.Replace String    ${Total_Dis_Likes}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Morning_Joe set Total_Dislikes ='${Total_Dis_Likes}' where id=${Count3}
    Sleep    5s
    ${Total_Subscribers}=    Get Text    css=#owner-sub-count
    ${Total_Subscribers}=    String.Replace String    ${Total_Subscribers}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Morning_Joe set Total_Subscribers= '${Total_Subscribers}' where id=${Count3}
    Sleep    5s
    ${Channel_Name}=    Get Text    css=#channel-name>#container>#text-container>yt-formatted-string>a
    ${Channel_Name}=    String.Replace String    ${Channel_Name}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Morning_Joe set Channel_Name= '${Channel_Name}' where id=${Count3}
    SeleniumLibrary.Reload Page
    sleep    15s
    BuiltIn.Run Keyword And Ignore Error    Click Element    css=yt-formatted-string[slot='more-button']
    sleep    10s
    ${Category}=    Get Text    css=ytd-metadata-row-renderer>div#content>yt-formatted-string>a[dir='auto']
    ${Category}=    String.Replace String    ${Category}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Morning_Joe set Category= '${Category}' where id=${Count3}
    Sleep    5s
    ${Description}=    Get Text    css=div#description>yt-formatted-string
    ${Description}=    String.Replace String    ${Description}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Morning_Joe set Channel_Description= '${Description}' where id=${Count3}

Scroll_Page_To_Location
    [Arguments]    ${x_location}    ${y_location}
    Execute Javascript    window.scrollTo(${x_location},${y_location})

Extracting_Details_From_Main_Page
    [Arguments]    ${Count2}
    Sleep    5s
    ${Title}=    Get Text    css=div#contents>ytd-video-renderer:nth-child(${Count2})>div#dismissable>div.text-wrapper.style-scope>div#meta>div#title-wrapper>h3>a>yt-formatted-string
    ${Title}=    String.Replace String    ${Title}    '    ''
    DatabaseLibrary.Execute Sql String    INSERT INTO nbcu_pilot.Youtube_Morning_Joe (`Title`) VALUES ('${Title}')
    Sleep    5s
    ${list}=    DatabaseLibrary.Query    select max(id) from nbcu_pilot.Youtube_Morning_Joe;
    Convert To List    ${list}
    ${list}=    Evaluate    [x[0] for x in ${list}]
    ${Count3}=    Get From List    ${list}    ${count}
    Sleep    5s
    ${Total_View}=    Get Text    css=div#contents>ytd-video-renderer:nth-child(${Count2})>#dismissable>div>#meta>ytd-video-meta-block>#metadata>#metadata-line>span:nth-child(1)
    ${Total_View}=    String.Replace String    ${Total_View}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Morning_Joe set Total_View= '${Total_View}' where id=${Count3}
    Sleep    5s
    ${Video_Rendered_Before}=    Get Text    css=div#contents>ytd-video-renderer:nth-child(${Count2})>#dismissable>div>#meta>ytd-video-meta-block>#metadata>#metadata-line>span:nth-child(2)
    ${Video_Rendered_Before}=    String.Replace String    ${Video_Rendered_Before}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Morning_Joe set Video_Rendered_Before= '${Video_Rendered_Before}' where id=${Count3}
    Sleep    5s
    ${Duration}=    Get Element Attribute    css=div#contents>ytd-video-renderer:nth-child(${Count2})>#dismissable>ytd-thumbnail>#thumbnail>#overlays>ytd-thumbnail-overlay-time-status-renderer>span    aria-label
    ${Duration}=    String.Replace String    ${Duration}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Morning_Joe set Duration= '${Duration}' where id=${Count3}
    Sleep    5s
    ${URL}=    Get Element Attribute    css=div#contents>ytd-video-renderer:nth-child(${Count2})>#dismissable>ytd-thumbnail>#thumbnail    href
    ${URL}=    String.Replace String    ${URL}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Morning_Joe set URL= '${URL}' where id=${Count3}
    BuiltIn.Run Keyword And Ignore Error    Extracting_Details_From_URL    ${URL}    ${Count3}

Scrolling
    BuiltIn.Run Keyword And Ignore Error    Scroll page to location    0    100000
    Sleep    10s
