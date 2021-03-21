*** Settings ***
Library           DatabaseLibrary
Library           OperatingSystem
Library           DateTime
Resource          resource.robot
Library           Selenium2Library
Library           AWSLibrary

*** Test Cases ***
Roku_Channels_Automation
    Selenium2Library.Open Browser    https://www.google.com    chrome
    Sleep    5s
    Selenium2Library.Maximize Browser Window
    Sleep    5s
    DatabaseLibrary.Connect To Database    pymysql    nbcu_pilot    vivekkumar.pandey    MMaXm83dZD18A4AA    dev-scraper.csoaie2kvgsc.us-east-1.rds.amazonaws.com    3306
    FOR    ${i}    IN RANGE    10000
        ${list}    DatabaseLibrary.Query    SELECT id,URL FROM `Roku_Channels` where locale<>'en-us' and isProcessed='0' limit 6
        Convert To List    ${list}
        ${id_list}=    Evaluate    [x[0] for x in ${list}]
        ${id}=    Get From List    ${id_list}    0
        ${url_list}=    Evaluate    [x[1] for x in ${list}]
        ${url}=    Get From List    ${url_list}    0
        Sleep    5s
        BuiltIn.Run Keyword And Ignore Error    Extracting_desc_from_url    ${url}    ${id}
        Selenium2Library.Close Window
        Selenium2Library.Select Window    Main
        Sleep    5s
    END
    Disconnect From Database
    Selenium2Library.Close All Browsers
    Pabot

*** Keywords ***
Scroll_Page_To_Location
    [Arguments]    ${x_location}    ${y_location}
    Execute Javascript    window.scrollTo(${x_location},${y_location})

Extracting_Details_From_URL
    [Arguments]    ${URL}    ${locale}    ${Title}    ${Artwork}    ${Desc}
    Execute Javascript    window.open()
    Select Window    NEW
    Sleep    10s
    Go To    ${URL}
    Sleep    10s
    Sleep    5s
    ${uniqueID}=    String.Fetch From Right    ${URL}    details/
    ${uniqueID}=    String.Fetch From Left    ${uniqueID}    /
    ${list}    DatabaseLibrary.Query    SELECT count(*) FROM `Roku_Channels` where uniqueID='${uniqueID}' and locale='${locale}';
    Convert To List    ${list}
    ${list}=    Evaluate    [x[0] for x in ${list}]
    ${Count}=    Get From List    ${list}    0
    BuiltIn.Run Keyword If    ${Count}==0    UniqueID_Existance    ${URL}    ${uniqueID}    ${locale}    ${Title}    ${Artwork}    ${Desc}

Category_List
    [Arguments]    ${Count3}    @{List}
    FOR    ${j}    IN    @{List}
    Sleep    5s
    ${Category}=    Get Text    ${j}
    ${Category}=    String.Replace String    ${Category}    '    ''
    ${New_Category}    BuiltIn.Catenate    SEPARATOR=,    ${New_Category}    ${Category}
    ${Sub}=    String.Get Substring    ${New_Category}    0    1
    ${New_Category}    BuiltIn.Run Keyword If    '${Sub}'==','    String.Get Substring    ${New_Category}    1
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Roku_Channels set Category ='${New_Category}' where id=${Count3}

Channel_Extraction
    [Arguments]    ${locale}
    ${List}=    SeleniumLibrary.Get WebElements    css=div.channel>div.thumbnail>a
    ${Length_Before_Scroll}=    BuiltIn.Get Length    ${List}
    FOR    ${i}    IN RANGE    999999
    BuiltIn.Run Keyword And Ignore Error    Scroll page to location    0    ${Vertical_Scroll}
    Sleep    5s
    ${List}=    SeleniumLibrary.Get WebElements    css=div.channel>div.thumbnail>a
    ${Length_After_Scroll}=    BuiltIn.Get Length    ${List}
    ${bool}=    BuiltIn.Run Keyword And Ignore Error    BuiltIn.Should Be Equal As Integers    ${Length_After_Scroll}    ${Length_Before_Scroll}
    ${bool}    Get From List    ${bool}    0
    BuiltIn.Convert To String    ${bool}
    ${Vertical_Scroll}    BuiltIn.Evaluate    ${Vertical_Scroll}+50000
    BuiltIn.Exit For Loop If    '${bool}'=='PASS'
    ${Length_Before_Scroll}    BuiltIn.Set Variable    ${Length_After_Scroll}
    DatabaseLibrary.Connect To Database    pymysql    nbcu_pilot    vivekkumar.pandey    MMaXm83dZD18A4AA    dev-scraper.csoaie2kvgsc.us-east-1.rds.amazonaws.com    3306
    @{List}=    Get WebElements    css=div.channel>div.thumbnail>a
    FOR    ${j}    IN    @{List}
    Sleep    5s
    ${URL}=    Get Element Attribute    ${j}    href
    Sleep    5s
    ${Title}=    Get Element Attribute    ${j}    title
    ${Artwork}=    Get Element Attribute    //div[@class='row loader-body']/div[@class='Roku-Channel-View'][${k}]/div/div/div/a/div/div/img    src
    ${Desc}=    Get Text    //div[@class='row loader-body']/div[@class='Roku-Channel-View'][${k}]/div/div/p[@class='description']
    BuiltIn.Run Keyword And Ignore Error    Extracting_Details_From_URL    ${URL}    ${locale}    ${Title}    ${Artwork}    ${Desc}
    close window
    Select Window    Main
    Sleep    5s
    ${k}=    BuiltIn.Evaluate    ${k}+1

Locale_Extraction
    Comment    Go To    ${URL}
    Comment    Sleep    10s
    ${locale}=    SeleniumLibrary.Get Location
    ${locale}=    String.Fetch From Right    ${locale}    ?locale=
    ${Before_Click}    Get Element Attribute    //div[@class='previous']/a/i/..    title
    FOR    ${i}    IN RANGE    999999
    Sleep    5s
    BuiltIn.Run Keyword And Ignore Error    Category_Extraction    ${locale}
    Click Element    //div[@class='previous']/a/i
    Sleep    5s
    ${After_Click}    Get Element Attribute    //div[@class='previous']/a/i/..    title
    BuiltIn.Exit For Loop If    '${Before_Click}'=='${After_Click}'
    Comment    BuiltIn.Run Keyword And Ignore Error    Category_Extraction    ${locale}

Category_Extraction
    [Arguments]    ${locale}
    BuiltIn.Run Keyword And Ignore Error    Channel_Extraction    ${locale}

UniqueID_Existance
    [Arguments]    ${URL}    ${uniqueID}    ${locale}    ${Title}    ${Artwork}    ${Desc}
    DatabaseLibrary.Execute Sql String    INSERT INTO nbcu_pilot.Roku_Channels (`locale`) VALUES ('${locale}')
    Sleep    3s
    ${list}=    DatabaseLibrary.Query    select max(id) from nbcu_pilot.Roku_Channels where locale='${locale}';
    Convert To List    ${list}
    ${list}=    Evaluate    [x[0] for x in ${list}]
    ${Count3}=    Get From List    ${list}    0
    Sleep    5s
    ${URL}=    Get Location
    ${URL}=    String.Replace String    ${URL}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Roku_Channels set URL= '${URL}' where id=${Count3}
    ${Title}=    String.Replace String    ${Title}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Roku_Channels set Title= '${Title}' where id='${Count3}'
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Roku_Channels set uniqueID= '${uniqueID}' where id='${Count3}'
    ${Artwork}=    String.Replace String    ${Artwork}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Roku_Channels set Artwork='${Artwork}' where id=${Count3}
    ${Desc}=    String.Replace String    ${Desc}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Roku_Channels set Description='${Desc}' where id=${Count3}
    Sleep    5s
    ${Title}=    Get Text    css=h1[itemprop='name']
    ${Title}=    String.Replace String    ${Title}    '    ''
    Comment    DatabaseLibrary.Execute Sql String    INSERT INTO nbcu_pilot.Roku_Channels (`locale`) VALUES ('${locale}')
    Comment    Sleep    3s
    Comment    ${list}=    DatabaseLibrary.Query    select max(id) from nbcu_pilot.Roku_Channels where locale='${locale}';
    Comment    Convert To List    ${list}
    Comment    ${list}=    Evaluate    [x[0] for x in ${list}]
    Comment    ${Count3}=    Get From List    ${list}    0
    Comment    Sleep    5s
    Comment    ${URL}=    Get Location
    Comment    ${URL}=    String.Replace String    ${URL}    '    ''
    Comment    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Roku_Channels set URL= '${URL}' where id=${Count3}
    ${Average_Rating}=    Get Text    css=span.average-rating
    ${Average_Rating}=    String.Replace String    ${Average_Rating}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Roku_Channels set Average_Rating ='${Average_Rating}' where id=${Count3}
    ${Ratings_In_Numbers}=    Get Text    css=small[itemprop="starRating"]
    ${Ratings_In_Numbers}=    String.Fetch From Right    ${Ratings_In_Numbers}    \n
    ${Ratings_In_Numbers}=    String.Replace String    ${Ratings_In_Numbers}    '    ''
    ${Ratings_In_Numbers}=    String.Fetch From Left    ${Ratings_In_Numbers}    ${SPACE}
    ${Ratings_In_Numbers}=    String.Strip String    ${Ratings_In_Numbers}${SPACE}
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Roku_Channels set Ratings_In_Numbers= '${Ratings_In_Numbers}' where id='${Count3}'
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Roku_Channels set Title= '${Title}' where id='${Count3}'
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Roku_Channels set uniqueID= '${uniqueID}' where id='${Count3}'
    @{List}    Get WebElements    css=p.categories>a
    BuiltIn.Run Keyword And Ignore Error    Category_List    ${Count3}    @{List}
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

Extracting_desc_from_url
    [Arguments]    ${url}    ${id}
    Selenium2Library.Execute Javascript    window.open()
    Selenium2Library.Select Window    NEW
    Sleep    10s
    Selenium2Library.Go To    ${url}
    Sleep    10s
    Sleep    5s
    @{List}=    Selenium2Library.Get Webelements    css=#read-more>p
    BuiltIn.Run Keyword And Ignore Error    Extracting_desc    ${id}    @{List}

Extracting_desc
    [Arguments]    ${id}    @{List}
    FOR    ${k}    IN    @{List}
        ${j}=    BuiltIn.Run Keyword If    '${count}'!='1'    Selenium2Library.Get Text    ${k}
        ${desc}=    BuiltIn.Catenate    ${desc}    ${j}
        ${count}=    BuiltIn.Evaluate    ${count}+1
    END
    ${Sub}=    String.Get Substring    ${desc}    0    5
    ${desc}=    BuiltIn.Run Keyword If    '${Sub}'==' None'    String.Get Substring    ${desc}    5
    ${desc}=    String.Strip String    ${SPACE}${desc}${SPACE}
    ${desc}=    String.Replace String    ${desc}    '    ''
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Roku_Channels set Description= '${desc}' where id='${id}'
    DatabaseLibrary.Execute Sql String    update nbcu_pilot.Roku_Channels set isProcessed= '1' where id='${id}'
