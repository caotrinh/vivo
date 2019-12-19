// Enable the JIRA issue Collector
window.ATL_JQ_PAGE_PROPS =  {
    "triggerFunction": function(showCollectorDialog) {
        //Requires that jQuery is available!
        $('#supportLink').click(function(e) {
            e.preventDefault();
            showCollectorDialog();
        });
}};