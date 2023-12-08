<!DOCTYPE html>
<html>
<%@ include file="headerAcc.jsp"%>
<style>
        h1 {color:black;}
</style>
<head>
        <title>A to Z Plant Nursery Home Page</title>
</head>
<body>
<h1 align="center">A to Z Plant Nursery Home Page</h1>

<h2 align="center"><a href="listprod.jsp" style="display: inline-block; padding: 10px 20px; background-color:#5a7a53; color: #ffffff; text-decoration: none; border-radius: 20px; border: 1px solid #5a7a53;">Begin Shopping</a></h2>
<h2 align="center"><a href="listorder.jsp" style="display: inline-block; padding: 10px 20px; background-color:#5a7a53; color: #ffffff; text-decoration: none; border-radius: 20px; border: 1px solid #5a7a53;">List All Orders</a></h2>
<h2 align="center"><a href="showcart.jsp" style="display: inline-block; padding: 10px 20px; background-color:#5a7a53; color: #ffffff; text-decoration: none; border-radius: 20px; border: 1px solid #5a7a53;">Go to Cart</a></h2>
<h2 align="center"><a href="customer.jsp" style="display: inline-block; padding: 10px 20px; background-color:#5a7a53; color: #ffffff; text-decoration: none; border-radius: 20px; border: 1px solid #5a7a53;">Customer Info</a></h2>
<h2 align="center"><a href="admin.jsp" style="display: inline-block; padding: 10px 20px; background-color:#5a7a53; color: #ffffff; text-decoration: none; border-radius: 20px; border: 1px solid #5a7a53;">Administrators</a></h2>
<h2 align="center"><a href="logout.jsp" style="display: inline-block; padding: 10px 20px; background-color:#5a7a53; color: #ffffff; text-decoration: none; border-radius: 20px; border: 1px solid #5a7a53;">Log out</a></h2>

<%
	String userName = (String) session.getAttribute("authenticatedUser");
	if (userName != null)
		out.println("<h3 align=\"center\" style=\"color:#black\">Signed in as: "+userName+" </h3>");
%>

</body>
</head>
