<%@ page import="java.lang.*"%>
<%@ page import="org.jsoup.Jsoup" %>
<%@ page import="org.jsoup.nodes.Document" %>
<%@ page import="org.jsoup.select.Elements" %>
<%@ page import="org.jsoup.nodes.Element" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONException" %>
<%
    String authorId = request.getParameter("authorId");
    String scopusUrl = "https://www.scopus.com/authid/detail.uri?authorId=" + authorId;

    Document doc = Jsoup.connect(scopusUrl).get();

    JSONObject json = new JSONObject();

    Elements hindexElement = doc.select("#authorDetailsHindex > div > div.panel-body > span");
    if(hindexElement.size() == 1) {
        try {
            json.put("hIndex", hindexElement.get(0).text());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    Elements documentCountElement = doc.select("#authorDetailsDocumentsByAuthor > div > div.panel-body > span");
    if(documentCountElement.size() == 1) {
        try {
            json.put("docCount", documentCountElement.get(0).text());
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    Element citeCountElement = doc.getElementById("totalCiteCount");
    try {
        if(citeCountElement != null) {
            json.put("citeCount", citeCountElement.text());
        }
    } catch (JSONException e) {
        e.printStackTrace();
    }

    Element coAuthorsElement = doc.getElementById("coAuthLi");
    if(coAuthorsElement != null) {
        Elements coAuthors = coAuthorsElement.getElementsByTag("span");
        if (coAuthors != null && coAuthors.size() == 1) {
            try {
                json.put("coAuthors", coAuthors.get(0).text());
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }

    out.println(json);
%>
