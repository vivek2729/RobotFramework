*** Settings ***
Library           SeleniumLibrary
Library           BuiltIn
Library           String
Library           DateTime
Library           Process
Library           OperatingSystem
Library           Collections

*** Variables ***
${count}          1
${i}              1
${j}              ${Empty}
${count1}         0
${Start}          95000
${End}            5000
${Count2}         0
${Server-IP}      54.158.206.49
${Current_Status}    ${Empty}
${Address}        ${EMPTY}
${row_counter}    2
${bool}           ${EMPTY}
${Complete_Address}    ${EMPTY}
${Vertical_Scroll}    50000
${New_gr_Title}    ${Empty}
${New_Explanation}    ${Empty}
${Output_Dir}     C:\Users\Administrator\Desktop\GlobeSmart_Images\
${desc}           ${Empty}

*** Keywords ***
Select_New_Date
    [Arguments]    ${date}    ${expected_month}
    ${current_month}    Read Excel Cell    2    7
    ${year}    Read Excel Cell    2    6
    Wait Until Element Is Visible    css=app-datepicker[title="Select Date"]
    Click Element    css=app-datepicker[title="Select Date"]
    Click Element    //span[contains(text(),'${current_month}')]
    Click Element    //span[contains(text(),'${year}')]
    Click Element    //span[contains(text(),'${year}')]
    Click Element    //span[contains(text(),'${expected_month}')]
    Click Element    //span[contains(text(),'${date}')]
    Wait Until Element Is Visible    css=.highlighter.heat-cell.hm-td    ${timeout}

Search_Date
    Wait Until Element Is Visible    css=app-datepicker[title="Select Date"]
    Click Element    css=app-datepicker[title="Select Date"]
    Click Element    css=button.previous
    Click Element    //span[contains(text(),'13')]
    Wait Until Element Is Visible    css=.highlighter.heat-cell.hm-td

Search_Title
    [Arguments]    ${Title_Name}    ${Expected_Title_Name}
    Wait Until Element Is Visible    css=[placeholder="Title"]
    Sleep    5s
    Log    Reading value from excel.
    Click Element    css=[placeholder="Title"]
    Input Text    css=[placeholder="Title"]    ${Title_Name}
    Wait Until Element Is Visible    css=.dropdown-item
    Click Element    css=.dropdown-item
    Wait Until Element Is Visible    css=.highlighter.heat-cell.hm-td
    Sleep    5s
    Click Element    css=.username
    @{heat_map_list}    Get WebElements    css=.highlighter.heat-cell.hm-td
    BuiltIn.Set Test Variable    ${Title_xpath}    css=[role="gridcell"][col-id="titleInternalAlias"]
    @{Title_Column_List}    Get WebElements    ${Title_xpath}
    Log    Comparing filtered Title Values
    BuiltIn.Run Keyword And Continue On Failure    compare_filter_values    ${Expected_Title_Name}    @{Title_Column_List}
    BuiltIn.Set Test Variable    ${Title_xpath}    css=[role="gridcell"][col-id="titleInternalAlias"]
    BuiltIn.Run Keyword And Continue On Failure    Compare_with_Pagination
    Reload Page
    Sleep    10s

Write_Headers_in_Excel
    [Arguments]    ${File_Path}
    Create Excel Document    11
    Save Excel Document    ${File_Path}
    Close All Excel Documents
    ExcelLibrary.Open Excel Document    ${File_Path}    11
    Wait Until Element Is Visible    css=[class="ag-header-container"] [class="ag-header-row"]
    Get WebElement    css=[class="ag-header-container"] [class="ag-header-row"]
    ${text}    Get Text    css=[class="ag-header-container"] [class="ag-header-row"]
    ${string}    Split String    ${text}    \n
    Write Excel Row    1    ${string}

Write_To_Excel
    [Arguments]    ${row_counter}    ${File_Path}
    @{heat_map_list}    Get WebElements    //*[@id="page-wrapper"]/app-m-availability/div/div[2]/div[2]/div/div[1]/div/ag-grid-angular/div/div[1]/div/div[3]/div[2]/div/div/div
    FOR    ${i}    IN    @{heat_map_list}
    ${elm}    Get WebElement    ${i}
    ${count}    Get Text    ${i}
    ${string}    Split String    ${count}    \n
    Write Excel Row    ${row_counter}    ${string}
    ${row_counter}    BuiltIn.Evaluate    ${row_counter}+1
    Save Excel Document    ${File_Path}
    Close Current Excel Document

Sum_Of_Titles
    [Arguments]    ${File_Path}
    ${text}    Get Text    //span[contains(text(),' entries')]
    ${count}    Get Substring    ${text}    \    -8
    ${pagination}    BuiltIn.Evaluate    ${count}/50
    ${pagination}    BuiltIn.Evaluate    ${pagination}+0.49
    ${No_of_Pages}    BuiltIn.Convert To Number    ${pagination}    0
    ${No_of_Pages}    BuiltIn.Convert To Integer    ${No_of_Pages}
    FOR    ${count}    IN RANGE    1    ${No_of_Pages}
    Element Should Be Enabled    css=.fa.fa-angle-right
    Click Element    css=.fa.fa-angle-right
    Sleep    15s
    Log    Count is = ${count}
    BuiltIn.Run Keyword And Ignore Error    ExcelLibrary.Open Excel Document    ${File_Path}    2
    ${row_counter}    BuiltIn.Evaluate    ${row_counter}+50
    Log    New Webpage records row in excel starts with ${row_cntr}
    Write_To_Excel    ${row_counter}    ${File_Path}
    Log    New Webpage records row in excel starts with ${row_counter}

compare_filter_values
    [Arguments]    ${Expected_Text}    @{Title_Column_List}
    FOR    ${i}    IN    @{Title_Column_List}
    ${elm}    Get WebElement    ${i}
    ${Actual_text}    Get Text    ${i}
    Log    Expected Text = ${Expected_Text}
    BuiltIn.Should Be Equal    ${Actual_text}    ${Expected_Text}    \    \    ignore_case=case-insensitive

Compare_with_Pagination
    ${text}    Get Text    //span[contains(text(),' entries')]
    ${count}    Get Substring    ${text}    \    -8
    ${pagination}    BuiltIn.Evaluate    ${count}/50
    ${pagination}    BuiltIn.Evaluate    ${pagination}+0.49
    ${No_of_Pages}    BuiltIn.Convert To Number    ${pagination}    0
    ${No_of_Pages}    BuiltIn.Convert To Integer    ${No_of_Pages}
    FOR    ${count}    IN RANGE    1    ${No_of_Pages}
    Log    Page loop
    Element Should Be Enabled    css=.fa.fa-angle-right
    Click Element    css=.fa.fa-angle-right
    Sleep    6s
    Click Element    css=.username
    @{Title_Column_List}    Get WebElements    ${Title_xpath}
    compare_filter_values    ${Expected_Text}    @{Title_Column_List}

compare_error_message
    ${error_message}    Read Excel Cell    27    2
    Wait Until Page Contains    ${error_message}

FileName_with_Timestamp
    ${Timestamp}    BuiltIn.Get Time    YYMMMDD
    ${text}    Convert Date    ${Timestamp}    result_format=%d-%m-%Y_%H_%M_%S
    BuiltIn.Set Test Variable    ${Timestamp}    ${text}

Log_Out
    [Documentation]    -> This allows user to successfully log out of the Spherex Application.
    Close All Excel Documents
    Wait Until Element Is Visible    class=avatar-navbar    ${timeout}
    Click Element    class=avatar-navbar
    Wait Until Element Is Visible    css=[href="javascript:void(0);"]    ${timeout}
    Log    Clicking Log Out button.
    Click Element    css=[href="javascript:void(0);"]
    Close Browser

Login
    BuiltIn.Run Keyword And Ignore Error    ExcelLibrary.Open Excel Document    ${path}    1
    ${url}=    Read Excel Cell    2    1
    SeleniumLibrary.Open Browser    ${url}    chrome
    Log    Clicking Username text field
    Click Element    id=usernameField
    ${username}=    Read Excel Cell    2    2
    Input Text    id=usernameField    ${username}
    Click Element    css=.btn.Spherex-headings-bg-color.block.full-width
    Wait Until Element Is Visible    id=passwordField
    ${password}=    Read Excel Cell    2    3
    Input Password    id=passwordField    ${password}
    Click Button    css=.btn.Spherex-headings-bg-color.block.full-width.m-b
    Maximize Browser Window
    Wait Until Element Is Visible    class=avatar-navbar
    Log    User logged into system successfully.
    Close Current Excel Document

Heatmap_Verification
    Log    Verifying Heatmap count & respective title count displayed in table grid.
    Sleep    5s
    @{heat_map_list}    Get WebElements    css=.highlighter.heat-cell.hm-td
    FOR    ${i}    IN    @{heat_map_list}
    Click Element    ${i}
    Sleep    7s
    BuiltIn.Run Keyword And Continue On Failure    Verify_Filters_On_Heatmap_Selection
    Click Element    //span[contains(text(),' entries')]
    ${Actual_text}    Get Text    ${i}
    Sleep    10s
    ${text}    Get Text    //span[contains(text(),' entries')]
    ${count}    Get Substring    ${text}    \    -8
    BuiltIn.Should Be Equal As Integers    ${Actual_text}    ${count}
    Log    Heatmap Value: ${Actual_text}
    Log    Title Count Value: ${count}

compare_avails_date
    [Documentation]    -> This keyword fetches the current date of the system & compares it with start end & end date of the avails title data to identify whether avails is in current/expired/future avails.
    ${current_date}    DateTime.Get Current Date
    Log    ${current_date}
    ${current_date}    Get Substring    ${current_date}    \    -13
    ${start_date}    Get Text    css=.master-Table-list.startDate.ng-star-inserted
    ${end_date}    Get Text    css=.master-Table-list.endDate.ng-star-inserted
    ${current_date}    BuiltIn.Set Variable    ${current_date}
    ${start_date}    BuiltIn.Set Variable    ${start_date}
    ${end_date}    BuiltIn.Set Variable    ${end_date}
    BuiltIn.Return From Keyword    ${current_date}    ${start_date}    ${end_date}
    [Return]    ${current_date}    ${start_date}    ${end_date}

compare_filter_with_multiple_values
    [Arguments]    ${Expected_Text}    ${Expected_Text_1}    @{Title_Column_List}
    FOR    ${i}    IN    @{Title_Column_List}
    ${elm}    Get WebElement    ${i}
    ${Actual_text}    Get Text    ${i}
    Log    Expected Texts are :- ${Expected_Text}/${Expected_Text_1}
    BuiltIn.Should Contain Any    ${Actual_text}    ${Expected_Text}    ${Expected_Text_1}
    Sleep    5s

Compare_With_Pagination_For_Multiple_Values
    ${text}    Get Text    //span[contains(text(),' entries')]
    ${count}    Get Substring    ${text}    \    -8
    ${pagination}    BuiltIn.Evaluate    ${count}/50
    ${pagination}    BuiltIn.Evaluate    ${pagination}+0.5
    ${No_of_Pages}    BuiltIn.Convert To Number    ${pagination}    0
    ${No_of_Pages}    BuiltIn.Convert To Integer    ${No_of_Pages}
    FOR    ${count}    IN RANGE    1    ${No_of_Pages}
    Log    Page loop
    Element Should Be Enabled    css=.fa.fa-angle-right
    Click Element    css=.fa.fa-angle-right
    Sleep    6s
    Click Element    css=.username
    @{Title_Column_List}    Get WebElements    ${Title_xpath}
    compare_filter_with_multiple_values    ${Expected_Text}    ${Expected_Text_1}    @{Title_Column_List}

Sort
    [Arguments]    ${Title_Header_xpath}    ${Title_xpath}
    Log    Sorting
    Wait Until Element Is Visible    ${Title_Header_xpath}
    ${text}    Get Text    css=td:nth-child(1).table-cell-width
    Click Element    ${Title_Header_xpath}
    Sleep    10s
    ${Actual_text}    Get Text    ${Title_xpath}
    BuiltIn.Should Not Be Equal As Strings    ${text}    ${Actual_text}

Filter_with_Parameterization
    [Arguments]    @{List_of_data}
    FOR    ${i}    IN    @{List_of_data}
    Click Element    //span[contains(text(),'${i}')]

compare_with_parameterization
    FOR    ${i}    IN    @{Title_Column_List}
    ${elm}    Get WebElement    ${i}
    ${Actual_text}    Get Text    ${i}
    Log    Expected Texts are :- ${Expected_Text}/${Expected_Text_1}
    BuiltIn.Should Contain Any    ${Actual_text}    ${Expected_Text}    ${Expected_Text_1}
    Sleep    5s

Title_Search_with_Parameterization
    [Arguments]    @{List_of_data}
    FOR    ${i}    IN    @{List_of_data}
    Input Text    css=[placeholder="Title"]    ${i}
    Wait Until Element Is Visible    css=.dropdown-item
    Log    Clicking on fetched title record from drop-down.
    Click Element    css=.dropdown-item
    Sleep    5s
    Click Element    css=.username
    ${Expected_Text}    Read Excel Cell    ${row_counter}    9
    @{Title_Column_List}    Get WebElements    css=div[role="gridcell"][col-id="titleInternalAlias"]
    BuiltIn.Run Keyword And Continue On Failure    compare_filter_values    ${Expected_Text}    @{Title_Column_List}
    ${row_counter}    BuiltIn.Evaluate    ${row_counter} + 1

Calculate_Number_of_Records_&_Pagination
    ${text}    Get Text    //span[contains(text(),' entries')]
    ${count}    Get Substring    ${text}    \    -8
    ${pagination}    BuiltIn.Evaluate    ${count}/50
    ${pagination}    BuiltIn.Evaluate    ${pagination}+0.49
    ${No_of_Pages}    BuiltIn.Convert To Number    ${pagination}    0
    ${No_of_Pages}    BuiltIn.Convert To Integer    ${No_of_Pages}
    BuiltIn.Return From Keyword    ${No_of_Pages}

Invalid_Title_Search
    ${text}    Read Excel Cell    35    2
    Input Text    css=input[placeholder="Title"]    ${text}
    Sleep    3s
    Element Should Not Be Visible    css=.dropdown-item    Drop-down value should not be displayed.

Search_With_Release_Year
    [Documentation]    This user defined keyword is used when user have to filter data based on 'Release Year'.
    Click Element    css=[title="Select Year"]
    Click Element    css=span[class="ui-slider-handle ui-corner-all ui-state-default"][style="left: 0%;"]
    Drag And Drop By Offset    css=span[class="ui-slider-handle ui-corner-all ui-state-default ui-state-hover ui-state-focus"][style="left: 0%;"]    100    0
    Click Element    css=span[class="ui-slider-handle ui-corner-all ui-state-default"][style="left: 100%;"]
    Drag And Drop By Offset    css=span[class="ui-slider-handle ui-corner-all ui-state-default ui-state-hover ui-state-focus"][style="left: 100%;"]    -50    0
    Click Element    css=[title="Select Year"] [class="btn btn-sm btn-primary close-dropdown"]
    Sleep    3s

Change_Avail_Based_Value
    Element Should Be Visible    //div[contains(text(),"Yes")]
    Click Element    css=i.fa.fa-pencil-square-o
    Sleep    5s
    Click Element    css=span.slider.round
    Sleep    3s
    Click Element    css=[id="saveClose"]
    Sleep    5s

Resize_Column
    [Arguments]    ${locator_value}
    ${element_size_before}    Get Element Size    ${locator_value}
    Click Element    ${locator_value} [class="ag-header-cell-resize"]
    Drag And Drop By Offset    ${locator_value} [class="ag-header-cell-resize"]    100    0
    Sleep    3s
    ${element_size_after}    Get Element Size    ${locator_value}
    BuiltIn.Should Not Be Equal    ${element_size_before}    ${element_size_after}

Move_Column
    [Arguments]    ${First_Column}    ${Second_Column}
    Wait Until Element Is Visible    ${First_Column}    timeout=10s
    ${before_move}    Get Element Attribute    ${First_Column}    style
    Drag And Drop    ${First_Column}    ${Second_Column}
    ${after_move}    Get Element Attribute    ${First_Column}    style
    BuiltIn.Should Not Be Equal    ${before_move}    ${after_move}

Admin_Login
    BuiltIn.Run Keyword And Ignore Error    ExcelLibrary.Open Excel Document    ${path}    1
    ${url}=    Read Excel Cell    7    1
    SeleniumLibrary.Open Browser    ${url}    chrome
    Log    Clicking Username text field
    Click Element    id=usernameField
    ${username}=    Read Excel Cell    7    2
    Input Text    id=usernameField    ${username}
    Click Element    css=.btn.Spherex-headings-bg-color.block.full-width
    Wait Until Element Is Visible    id=passwordField
    ${password}=    Read Excel Cell    7    3
    Input Password    id=passwordField    ${password}
    Click Button    css=.btn.Spherex-headings-bg-color.block.full-width.m-b
    Maximize Browser Window
    Wait Until Element Is Visible    class=avatar-navbar
    Log    User logged into system successfully.
    Close Current Excel Document

Save_Filter
    Sleep    3s
    Click Element    css=.multiselect-text.dark-depth.filter-icon.save-filter
    Log    Entering filter name
    ${text}    Read Excel Cell    34    2
    Wait Until Element Is Visible    css=input[placeholder="Name your new saved filter..."]    ${timeout}
    Input Text    css=input[placeholder="Name your new saved filter..."]    ${text}
    ${text}    Read Excel Cell    24    3
    Click Element    //button[contains(text(),"${text}")]
    Sleep    5s
    Wait Until Element Is Visible    css=button[title="Reset"]
    Click Element    css=button[title="Reset"]
    Sleep    4s
    ${status}    ${text_before_applying_filter}    BuiltIn.Run Keyword And Ignore Error    Get Text    //span[contains(text(),' entries')]
    ${text_before_applying_filter}    BuiltIn.Run Keyword If    '${status}' == 'PASS'    Get Text    //span[contains(text(),' entries')]
    ...    ELSE IF    '${status}' == 'FAIL'    Get Text    css=p.alert
    Click Element    css=.multiselect-text.dark-depth.filter-icon.save-filter
    ${text}    Read Excel Cell    34    2
    Wait Until Element Is Visible    //label[contains(text(),"${text}")]    ${timeout}
    Click Element    css=[title="Select Filter"] [placeholder="Search"]
    Input Text    css=[title="Select Filter"] [placeholder="Search"]    ${text}
    Click Element    css=label[title="${text}"]
    Sleep    3s
    ${text}    Get Text    //span[contains(text(),' entries')]
    BuiltIn.Should Not Be Equal    ${text_before_applying_filter}    ${text}
    Click Element    css=.multiselect-text.dark-depth.filter-icon.save-filter
    ${text}    Read Excel Cell    34    2
    Wait Until Element Is Visible    //label[contains(text(),"${text}")]
    Click Element    css=[title="Select Filter"] [placeholder="Search"]
    Input Text    css=[title="Select Filter"] [placeholder="Search"]    ${text}
    Wait Until Element Is Visible    css=i.fa.fa-trash-o
    Click Element    css=i.fa.fa-trash-o
    Sleep    3s
    Wait Until Element Is Visible    css=div.modal-footer    ${timeout}
    Click Element    css=.btn.colored-button.Spherex-headings-bg-color
    Sleep    3s
    Wait Until Element Is Visible    css=button[title="Reset"]
    Click Element    css=button[title="Reset"]

Verify_View_In_Catalog
    Sleep    7s
    ${Expected_Text}    Get Text    css=[role="gridcell"][col-id="titleInternalAlias"]
    Wait Until Element Is Visible    css=.fa.fa-ellipsis-v
    Click Element    css=.fa.fa-ellipsis-v
    ${text}    Read Excel Cell    4    3
    Wait Until Element Is Visible    //a[contains(text(),'${text}')]
    Click Element    //a[contains(text(),'${text}')]
    Sleep    10s
    @{window_list}    Get Window Handles
    FOR    ${i}    IN    @{window_list}
    Select Window    ${i}
    ${text}    Read Excel Cell    5    3
    Wait Until Element Is Visible    //div[contains(text(),'${text}')]
    Wait Until Element Is Visible    css=.media-heading.media-heading-titlename
    ${Actual_text}    Get Text    css=.media-heading.media-heading-titlename
    BuiltIn.Should Be Equal    ${Actual_text}    ${Expected_Text}    \    ignore_case=case-insensitive
    Close Window
    Select Window    Spherex

Verify_View_In_Explorer_View
    Sleep    10s
    ${Expected_Text}    Get Text    css=[role="gridcell"][col-id="titleInternalAlias"]
    Wait Until Element Is Visible    css=[role="gridcell"][col-id="ellipsis"]
    Click Element    css=[role="gridcell"][col-id="ellipsis"]
    ${text}    Read Excel Cell    6    3
    Wait Until Element Is Visible    //a[contains(text(),'${text}')]
    Click Element    //a[contains(text(),'${text}')]
    @{window_list}    Get Window Handles
    FOR    ${i}    IN    @{window_list}
    Select Window    ${i}
    ${text}    Read Excel Cell    7    3
    BuiltIn.Run Keyword And Continue On Failure    Wait Until Element Is Visible    //div[contains(text(),'${text}')]
    BuiltIn.Run Keyword And Continue On Failure    Wait Until Element Is Visible    css=.media-heading.media-heading-titlename
    ${Actual_text}    BuiltIn.Run Keyword And Continue On Failure    Get Text    css=.media-heading.media-heading-titlename
    BuiltIn.Run Keyword And Continue On Failure    BuiltIn.Should Be Equal    ${Actual_text}    ${Expected_Text}    \    ignore_case=case-insensitive
    Close Window
    Select Window    Spherex

Verify_View_In_Avails
    Sleep    5s
    ${Expected_Text}    Get Text    css=[role="gridcell"][col-id="titleInternalAlias"]
    Element Should Be Visible    css=[role="gridcell"][col-id="ellipsis"]
    Click Element    css=[role="gridcell"][col-id="ellipsis"]
    ${text}    Read Excel Cell    31    3
    Sleep    10s
    Comment    Wait Until Element Is Visible    //a[contains(text(),'${text}')]
    Click Element    //a[contains(text(),'${text}')]
    Sleep    10s
    @{window_list}    Get Window Handles
    FOR    ${i}    IN    @{window_list}
    Select Window    ${i}
    Wait Until Element Is Visible    css=input[placeholder="Title"]
    ${url}    Get Location
    ${text}    Read Excel Cell    3    17
    BuiltIn.Should Contain    ${url}    ${text}
    Close Window
    Select Window    Spherex
    Sleep    10s

Titles_Per_Page
    Select From List By Value    css=select.ng-pristine.ng-valid    100
    Sleep    3s
    ${text}    Get Text    //span[contains(text(),'Showing 1 to ')]
    ${count}    Get Substring    ${text}    12    -3
    BuiltIn.Evaluate    100>=${count}>50
    Select From List By Value    css=select.ng-touched.ng-dirty    150
    Sleep    3s
    ${text}    Get Text    //span[contains(text(),'Showing 1 to ')]
    ${count}    Get Substring    ${text}    12    -3
    BuiltIn.Evaluate    150>=${count}>50
    Select From List By Value    css=select.ng-touched.ng-dirty    50
    Sleep    3s
    ${text}    Get Text    //span[contains(text(),'Showing 1 to ')]
    ${count}    Get Substring    ${text}    12    -3
    BuiltIn.Evaluate    ${count}<=50

Verify_Moved_Column_On_Reload
    [Arguments]    ${First_Column}    ${Second_Column}
    Wait Until Element Is Visible    ${First_Column}
    Log    ---- Verifying moved columns on page reload.----
    ${before_move}    Get Element Attribute    ${First_Column}    style
    Drag And Drop    ${First_Column}    ${Second_Column}
    ${after_move}    Get Element Attribute    ${First_Column}    style
    BuiltIn.Should Not Be Equal    ${before_move}    ${after_move}
    Reload Page
    Wait Until Element Is Visible    ${First_Column}    timeout=15s
    ${after_reload}    Get Element Attribute    ${First_Column}    style
    BuiltIn.Should Be Equal    ${after_move}    ${after_reload}
    Log    ---- Verifying moved columns with change in titles per page. ----
    BuiltIn.Run Keyword And Continue On Failure    Titles_Per_Page
    Wait Until Element Is Visible    ${First_Column}
    ${after_reload}    Get Element Attribute    ${First_Column}    style
    BuiltIn.Should Be Equal    ${after_move}    ${after_reload}
    Log    ---- Verifying moved columns with pagination. ----
    FOR    ${i}    IN RANGE    1
    BuiltIn.Run Keyword And Ignore Error    Element Should Be Enabled    css=.fa.fa-angle-right
    BuiltIn.Run Keyword And Ignore Error    Click Element    css=.fa.fa-angle-right
    Sleep    6s
    Click Element    css=.username
    Wait Until Element Is Visible    ${First_Column}
    ${after_reload}    Get Element Attribute    ${First_Column}    style
    BuiltIn.Should Be Equal    ${after_move}    ${after_reload}
    Log    ---- Verifying moved columns on Re-login. ----
    ${url}    Get Location
    Sleep    5s
    BuiltIn.Run Keyword And Continue On Failure    Log_Out
    BuiltIn.Run Keyword And Continue On Failure    Login
    Go To    ${url}
    Wait Until Element Is Visible    ${First_Column}
    ${after_reload}    Get Element Attribute    ${First_Column}    style
    BuiltIn.Should Be Equal    ${after_move}    ${after_reload}

Add_Column
    Click Element    css=button[title='Select Column']
    ${Column_Name}    Read Excel Cell    2    28
    Input Text    css=li.column-search>div>[placeholder='Search']    ${Column_Name}
    Sleep    3s
    ${status}    ${value}=    BuiltIn.Run Keyword And Ignore Error    Verifying_Column_Status_true_Case
    BuiltIn.Run Keyword If    '${status}'=='FAIL'    Clicking_On_Column
    ${status}    ${value}=    BuiltIn.Run Keyword And Ignore Error    Verifying_Column_Status_false_Case
    BuiltIn.Run Keyword If    '${status}'=='FAIL'    Clicking_On_Column
    ${Column_Selected}    Get Text    //ul[@class='dropdown-menu Tweak-dropdown-menu ']//a
    Click Element    css=button[title='Select Column']
    Sleep    4s
    Comment    Drag And Drop By Offset    css=div.ag-body-horizontal-scroll-container    400    0
    Comment    Sleep    2s
    Element Should Be Visible    //app-header-component/div/ div[contains(text(),'${Column_Selected}')]
    Click Element    css=button[title='Reset']
    Sleep    3s

Verifying_Column_Status_true_Case
    ${Var}    Get Element Attribute    css=a.columnselection.ng-star-inserted    class
    BuiltIn.Convert To String    ${Var}
    BuiltIn.Should Not Contain    ${Var}    checkbox-true

Verifying_Column_Status_false_Case
    ${Var}    Get Element Attribute    css=a.columnselection.ng-star-inserted    class
    BuiltIn.Convert To String    ${Var}
    BuiltIn.Should Not Contain    ${Var}    checkbox-false

Clicking_On_Column
    Click Element    //ul[@class='dropdown-menu Tweak-dropdown-menu ']//a

Verify_Future_Date_Selection
    [Documentation]    Verifying whether a future date is disabled or not in calender under all compliance pages.
    ${Current_Date}    DateTime.Get Current Date
    ${Current_date}    Get Substring    ${Current_Date}    8    10
    ${Current_date}    BuiltIn.Convert To Integer    ${Current_date}
    log    ${Current_date}
    ${Future_date}    BuiltIn.Evaluate    ${Current_date}+1
    Wait Until Element Is Visible    css=app-datepicker[title="Select Date"]
    Click Element    css=app-datepicker[title="Select Date"]
    Sleep    2s
    ${Attribute_For_Current_Date}    Get Element Attribute    //td/span[contains(text(),'${Current_Date}')][@class='selected']    class
    ${Attribute_For_Future_Date}    Get Element Attribute    //td/span[contains(text(),'${Future_Date}')][@class='disabled']    class
    BuiltIn.Should Not Be Equal As Strings    ${Attribute_For_Current_Date}    ${Attribute_For_Future_Date}
    Click Element    css=app-datepicker[title="Select Date"]

Verify_No_Data_On_Compliance_Pages
    Sleep    3s
    Sleep    3s
    Click Element    css=[filter-icon='store']
    Click Element    //span[contains(text(),'Google')]
    Click Element    css=div.multiselect-wrapper.dropdown.myDropdown.open>div.panel.panel-default.multiselect-dropdown.dropdown-menu>div.panel-footer>button[title='Ok']
    Sleep    2s
    Click Element    css=[filter-icon='platform']
    Click Element    //span[contains(text(),'Set Top Box')]
    Click Element    css=div.multiselect-wrapper.dropdown.myDropdown.open>div.panel.panel-default.multiselect-dropdown.dropdown-menu>div.panel-footer>button[title='Ok']
    Wait Until Element Is Visible    css=p.alert.alert-danger
    ${text}    Get Text    css=p.alert.alert-danger
    BuiltIn.Should Be Equal As Strings    ${text}    No Data Found

Verify_Filters_On_Heatmap_Selection
    Element Should Be Visible    css=[placeholder='Title'][disabled='disabled']
    Element Should Be Visible    css=[placeholder='Date'][disabled='disabled']
    Element Should Be Visible    css=[filter-icon='store'][class='disabled']
    Element Should Be Visible    css=[filter-icon='territory'][class='disabled']
    Element Should Be Visible    css=[filter-icon='platform'][class='disabled']
    Element Should Be Visible    css=[title='Select License Type'][class='disabled']

Reset
    Click Element    css=button[title="Reset"]

C:\\Users\\Administrator\\Desktop\\GlobeSmart_Images
