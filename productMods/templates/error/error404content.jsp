<%-- $This file is distributed under the terms of the license in /doc/license.txt$ --%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %><%/* this odd thing points to something in web.xml */ %>
<div class="container">
	<div class="panel panel-default">
		<h4 class="panel-heading">Page Not Found</h4>
		<div class="panel-body">
			<p class="warning">The page you requested is not available.  It may have been deleted or moved to another location.</p>

			<p>If you reached this page by following a link within this website, please consider <a href="<c:url value="contact"/>">contacting us</a> and telling us what link you clicked.</p>

			<p>Return to the <a href="/">home page</a></p>

			<!-- _______________________________Exception__________________________________

			404
			Request URI:  ${param.uriStr}
			___________________________________________________________________________ -->
		</div>
	</div>
</div><!-- contents -->

