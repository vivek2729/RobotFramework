*** Settings ***
Library           SeleniumLibrary
Library           DatabaseLibrary
Library           ExcelLibrary
Library           OperatingSystem
Library           DateTime
Resource          resource.robot

*** Test Cases ***
Roku_Channels_Automation
    SeleniumLibrary.Open Browser    https://channelstore.roku.com/en-gb/browse/film-and-tv    chrome
    Sleep    5s
    Maximize Browser Window
    Sleep    5s
    ${List}=    SeleniumLibrary.Get WebElements    css=div.channel>div.thumbnail>a
    ${Length_Before_Scroll}=    BuiltIn.Get Length    ${List}
    : FOR    ${i}    IN RANGE    999999
    \    BuiltIn.Run Keyword And Ignore Error    Scroll page to location    0    ${Vertical_Scroll}
    \    Sleep    5s
    \    ${List}=    SeleniumLibrary.Get WebElements    css=div.channel>div.thumbnail>a
    \    ${Length_After_Scroll}=    BuiltIn.Get Length    ${List}
    \    ${bool}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Be Equal As Integers    ${Length_After_Scroll}    ${Length_Before_Scroll}
    \    ${bool}    Get From List    ${bool}    0
    \    BuiltIn.Convert To String    ${bool}
    \    ${Vertical_Scroll}    BuiltIn.Evaluate    ${Vertical_Scroll}+50000
    \    BuiltIn.Exit For Loop If    '${bool}'=='PASS'
    \    ${Length_Before_Scroll}    BuiltIn.Set Variable    ${Length_After_Scroll}
    DatabaseLibrary.Connect To Database    pymysql    nbcu_pilot    vivekkumar.pandey    MMaXm83dZD18A4AA    dev-scraper.csoaie2kvgsc.us-east-1.rds.amazonaws.com    3306
    ${List}=    Get WebElements    css=div.channel>div.thumbnail>a
    BuiltIn.Get Length    ${List}
    :FOR    ${j}    IN    @{List}
    \    \    Sleep    5s
    \    ${URL}=    Get Element Attribute    ${j}    href
    \    Sleep    5s
    \    BuiltIn.Run Keyword And Ignore Error    Extracting_Details_From_URL    ${URL}
    \    close window
    \    Select Window    Main
    \    Sleep    5s
    Close All Browsers

*** Keywords ***
Scroll_Page_To_Location
    [Arguments]    ${x_location}    ${y_location}
    Execute Javascript    window.scrollTo(${x_location},${y_location})

Extracting_Details_From_URL
    [Arguments]    ${URL}
    Execute Javascript    window.open()
    Select Window    NEW
    Sleep    10s
    Go To    ${URL}
    Sleep    10s
    ${Title}=    Get Text    css=h1[itemprop='name']
    ${Title}=    String.Replace String    ${Title}    '    ''
    DatabaseLibrary.Execute Sql String    INSERT INTO nbcu_pilot.Roku_Channels (`Title`) VALUES ('${Title}')
    Sleep    3s
    ${list}=    DatabaseLibrary.Query    select max(id) from nbcu_pilot.Roku_Channels;
    Convert To List    ${list}
    ${list}=    Evaluate    [x[0] for x in ${list}]
    ${Count3}=    Get From List    ${list}    ${count}
    Sleep    5s
    ${URL}=    String.Replace String    ${URL}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Roku_Channels set URL= '${URL}' where id=${Count3}
    ${Average_Rating}=    Get Text    css=span.average-rating
    ${Average_Rating}=    String.Replace String    ${Average_Rating}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Roku_Channels set Average_Rating ='${Average_Rating}' where id=${Count3}
    ${Ratings_In_Numbers}=    Get Text    css=small[itemprop="starRating"]
    ${Ratings_In_Numbers}=    String.Fetch From Right    ${Ratings_In_Numbers}    \n
    ${Ratings_In_Numbers}=    String.Replace String    ${Ratings_In_Numbers}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Roku_Channels set Ratings_In_Numbers= '${Ratings_In_Numbers}' where id='${Count3}'
    ${Category}=    Get Text    css=p.categories>a
    ${Category}=    String.Replace String    ${Category}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Roku_Channels set Category ='${Category}' where id=${Count3}
    ${Description}=    Get Text    css=article.channel-description>div>p:nth-child(3)
    ${Description}=    String.Replace String    ${Description}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Roku_Channels set Description='${Description}' where id=${Count3}
    ${Developed_By}=    Get Text    css=article.channel-description>div>p:nth-child(2)>i:nth-child(3)
    ${Developed_By}=    String.Fetch From Left    ${Developed_By}    Privacy Policy
    ${Developed_By}=    String.Replace String    ${Developed_By}    '    ''
    ${Developed_By}=    String.Strip String    ${Developed_By}${SPACE}
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Roku_Channels set Developed_By= '${Developed_By}' where id=${Count3}
    ${Artwork}=    Get Element Attribute    css=div.Roku-Image>div>img    src
    ${Artwork}=    String.Replace String    ${Artwork}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Roku_Channels set Artwork='${Artwork}' where id=${Count3}
