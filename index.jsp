<!DOCTYPE html>
<html>
<%@ include file="headerAcc.jsp"%>
<style>
        h1 {color:#1baa82;}
        h2 {color:black;}
</style>
<head>
        <title>A & Z's Grocery Main Page</title>
</head>
<body>
<h1 align="center">Welcome to A & Z 's Grocery</h1>
<h2 align="center"><a href="login.jsp" style="color:black">Login</a></h2>
<h2 align="center"><a href="listprod.jsp" style="color:black">Begin Shopping</a></h2>
<h2 align="center"><a href="listorder.jsp" style="color:black">List All Orders</a></h2>
<h2 align="center"><a href="customer.jsp" style="color:black">Customer Info</a></h2>
<h2 align="center"><a href="admin.jsp" style="color:black">Administrators</a></h2>
<h2 align="center"><a href="logout.jsp" style="color:black">Log out</a></h2>

<%
	String userName = (String) session.getAttribute("authenticatedUser");
	if (userName != null)
		out.println("<h3 align=\"center\">Signed in as: "+userName+"</h3>");
%>

<h4 align="center"><a href="ship.jsp?orderId=1" style="color:#769d6d">Test Ship orderId=1</a></h4>

<h4 align="center"><a href="ship.jsp?orderId=3" style="color:#769d6d">Test Ship orderId=3</a></h4>

</body>
</head>