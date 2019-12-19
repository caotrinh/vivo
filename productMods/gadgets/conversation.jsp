<%@ page import="java.net.*,java.io.*,java.lang.*,java.util.*"%>
<%
try {
String authorId = request.getParameter("authorId");

String rssAddress = "http://theconversation.com/profiles/"+authorId+"/articles.atom";
URL rssUrl = new URL( rssAddress );

BufferedReader in = new BufferedReader( new InputStreamReader(rssUrl.openStream()));
String inputLine;
while ((inputLine = in.readLine()) != null)
    out.println(inputLine);
    in.close();
}catch(Exception ex){}

//out.println( "URL: " + metricsUrl );

%>
