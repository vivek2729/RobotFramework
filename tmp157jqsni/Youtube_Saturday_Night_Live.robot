*** Settings ***
Library           SeleniumLibrary
Library           DatabaseLibrary
Library           OperatingSystem
Library           DateTime
Resource          resource.robot

*** Test Cases ***
Saturday_Live_Automation
    DatabaseLibrary.Connect To Database    pymysql    nbcu_pilot    vivekkumar.pandey    MMaXm83dZD18A4AA    dev-scraper.csoaie2kvgsc.us-east-1.rds.amazonaws.com    3306
    SeleniumLibrary.Open Browser    https://www.youtube.com/user/SaturdayNightLive/videos?view=0&sort=dd&flow=grid    chrome
    Maximize Browser Window
    Sleep    5s
    BuiltIn.Run Keyword And Ignore Error    Scroll page to location    0    50000
    Sleep    10s
    @{List}=    Get WebElements    css=div#items>ytd-grid-video-renderer
    : FOR    ${j}    IN    @{List}
    \    Sleep    10s
    \    BuiltIn.Exit For Loop If    ${Count2}==51
    \    BuiltIn.Run Keyword And Ignore Error    Extracting_Details_From_Main_Page    ${Count2}
    \    ${Count2}    BuiltIn.Evaluate    ${Count2}+1
    \    Close window
    \    Select Window    Main
    \    Sleep    5s
    \    BuiltIn.Exit For Loop
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
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Saturday_Night_Live set Date= '${Date}' where id=${Count3}
    ${Full_View_Count}=    Get Text    css=div#count>yt-view-count-renderer>span:nth-child(1)
    ${Full_View_Count}=    String.Replace String    ${Full_View_Count}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Saturday_Night_Live set Full_View_Count ='${Full_View_Count}' where id=${Count3}
    ${Short_View_Count}=    Get Text    css=div#count>yt-view-count-renderer>span:nth-child(2)
    ${Short_View_Count}=    String.Replace String    ${Short_View_Count}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Saturday_Night_Live set Short_View_Count= '${Short_View_Count}' where id='${Count3}'
    ${Total_Likes}=    Get Text    css=#top-level-buttons>ytd-toggle-button-renderer:nth-child(1)>a>yt-formatted-string#text
    ${Total_Likes}=    String.Replace String    ${Total_Likes}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Saturday_Night_Live set Total_Likes ='${Total_Likes}' where id=${Count3}
    ${Total_Dis_Likes}=    Get Text    css=#top-level-buttons>ytd-toggle-button-renderer:nth-child(2)>a>yt-formatted-string#text
    ${Total_Dis_Likes}=    String.Replace String    ${Total_Dis_Likes}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Saturday_Night_Live set Total_Dislikes ='${Total_Dis_Likes}' where id=${Count3}
    ${Total_Subscribers}=    Get Text    css=#owner-sub-count
    ${Total_Subscribers}=    String.Replace String    ${Total_Subscribers}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Saturday_Night_Live set Total_Subscribers= '${Total_Subscribers}' where id=${Count3}
    SeleniumLibrary.Reload Page
    sleep    5s
    Click Element    css=yt-formatted-string[slot='more-button']
    sleep    5s
    ${Category}=    Get Text    css=ytd-metadata-row-renderer>div#content>yt-formatted-string>a[dir='auto']
    ${Category}=    String.Replace String    ${Category}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Saturday_Night_Live set Category= '${Category}' where id=${Count3}
    Sleep    3s
    ${Description}=    Get Text    css=div#description>yt-formatted-string>span
    ${Description}=    String.Replace String    ${Description}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Saturday_Night_Live set Channel_Description= '${Description}' where id=${Count3}

Scroll_Page_To_Location
    [Arguments]    ${x_location}    ${y_location}
    Execute Javascript    window.scrollTo(${x_location},${y_location})

Extracting_Details_From_Main_Page
    [Arguments]    ${Count2}
    ${Channel_Name}=    Get Text    css=div#channel-container>div>div:nth-child(1)>div>div>#channel-name>div>div>#text
    ${Channel_Name}=    String.Replace String    ${Channel_Name}    '    ''
    DatabaseLibrary.Execute Sql String    INSERT INTO nbcu_pilot.Youtube_Saturday_Night_Live (`Channel_Name`) VALUES ('${Channel_Name}')
    Sleep    3s
    ${list}=    DatabaseLibrary.Query    select max(id) from nbcu_pilot.Youtube_Saturday_Night_Live;
    Convert To List    ${list}
    ${list}=    Evaluate    [x[0] for x in ${list}]
    ${Count3}=    Get From List    ${list}    ${count}
    ${Video_Title}=    Get Text    css=div#items>ytd-grid-video-renderer:nth-child(${Count2})>div>div#details>div#meta>h3>a#video-title
    ${Video_Title}=    String.Replace String    ${Video_Title}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Saturday_Night_Live set Video_Title= '${Video_Title}' where id=${Count3}
    BuiltIn.Run Keyword And Ignore Error    Extracting_Duration    ${Count2}    ${Count3}
    ${View}=    Get Text    css=div#items>ytd-grid-video-renderer:nth-child(${Count2})>div>div#details>div#meta>div#metadata-container>div#metadata>div#metadata-line>span:nth-child(1)
    ${View}=    String.Replace String    ${View}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Saturday_Night_Live set Views= '${View}' where id=${Count3}
    ${Video_Rendered_Before}=    Get Text    css=div#items>ytd-grid-video-renderer:nth-child(${Count2})>div>div#details>div#meta>div#metadata-container>div#metadata>div#metadata-line>span:nth-child(2)
    ${Video_Rendered_Before}=    String.Replace String    ${Video_Rendered_Before}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Saturday_Night_Live set Video_Rendered_Before= '${Video_Rendered_Before}' where id=${Count3}
    ${URL}=    Get Element Attribute    css=div#items>ytd-grid-video-renderer:nth-child(${Count2})>div>ytd-thumbnail>a    href
    ${URL}=    String.Replace String    ${URL}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Youtube_Saturday_Night_Live set URL= '${URL}' where id=${Count3}
    BuiltIn.Run Keyword And Ignore Error    Extracting_Details_From_URL    ${URL}    ${Count3}

Scrolling
    BuiltIn.Run Keyword And Ignore Error    Scroll page to location    0    100000
    Sleep    10s

Scrolling_For_Duration
    [Arguments]    ${Count2}    ${Count3}
    BuiltIn.Run Keyword And Ignore Error    Scroll page to location    0    100000
    Sleep    10s
    BuiltIn.Run Keyword And Ignore Error    Extracting_Duration    ${Count2}

Extracting_Duration
    [Arguments]    ${Count2}    ${Count3}
    Sleep    5s
    ${bool}=    BuiltIn.Run Keyword And Ignore Error    SeleniumLibrary.Element Should Be Visible    css=div#items>ytd-grid-video-renderer:nth-child(${Count2})>div>ytd-thumbnail>a>div>ytd-thumbnail-overlay-time-status-renderer>span
    ${bool}=    Get From List    ${bool}    0
    Run Keyword If    '${bool}'=='PASS'    Duration_Extraction    ${Count2}    ${Count3}
    ...    ELSE    Scrolling_For_Duration    ${Count2}    ${Count3}

Duration_Extraction
    [Arguments]    ${Count2}    ${Count3}
    ${Duration}=    Get Text    css=div#items>ytd-grid-video-renderer:nth-child(${Count2})>div>ytd-thumbnail>a>div>ytd-thumbnail-overlay-time-status-renderer>span
