<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<%
if (session.getAttribute("authenticatedUser") != null) {
    %>
    <%@ include file="headerAcc.jsp"%>
    <%
}
else {
    %>
    <%@ include file="header.jsp"%>
    <%
}
%>
<style >
        h1 {color:#a06296;}
        h2 {color:black;}
</style>
<head>
<title>A & Z's Shopping Cart</title>
</head>
<body style="font-family:'Optima'">

<%
// Get the current list of products
@SuppressWarnings({"unchecked"})
HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

if (productList == null || productList.isEmpty())
{	out.println("<h2 align='center'>A to Z's Shopping Cart</h2>");
	out.println("<h2 align='center'>Your shopping cart is empty!</h2>");
	productList = new HashMap<String, ArrayList<Object>>();
}
else
{
	NumberFormat currFormat = NumberFormat.getCurrencyInstance();

	out.println("<h2>Your Shopping Cart</h2>");
	out.print("<table border = '1'><tr><th>Product Id</th><th>Product Name</th><th>Quantity</th>");
	out.println("<th>Price</th><th>Subtotal</th></tr>");

	double total =0;
	Iterator<Map.Entry<String, ArrayList<Object>>> iterator = productList.entrySet().iterator();
	while (iterator.hasNext()) 
	{	Map.Entry<String, ArrayList<Object>> entry = iterator.next();
		ArrayList<Object> product = (ArrayList<Object>) entry.getValue();
		if (product.size() < 4)
		{
			out.println("Expected product with four entries. Got: "+product);
			continue;
		}
		
		out.print("<tr><td>"+product.get(0)+"</td>");
		out.print("<td>"+product.get(1)+"</td>");

		Object price = product.get(2);
		Object itemqty = product.get(3);
		double pr = 0;
		int qty = 0;
		
		try {
			pr = Double.parseDouble(price.toString());
		}
		catch (Exception e) {
			out.println("Invalid price for product: "+product.get(0)+" price: "+price);
		}
		try {
			qty = Integer.parseInt(itemqty.toString());
		}
		catch (Exception e) {
			out.println("Invalid quantity for product: "+product.get(0)+" quantity: "+qty);
		}	

		out.print("<td><input type='text' name='newqty1' size='3' value='" + qty + "'></td>");
		out.print("<td align=\"right\">"+currFormat.format(pr)+"</td>");
		out.print("<td align=\"right\">"+currFormat.format(pr*qty)+"</td>");
		out.print("<td><a href='showcart.jsp?delete=" + product.get(0) + "' style='color:#769d6d'>Remove Item from Cart</a></td>");
		out.print("<td><input type='BUTTON' onclick='update(1, document.form1.newqty1.value)' value='Update Quantity'></td></tr>");
		total = total +pr*qty;
	}
	out.println("<tr><td colspan=\"4\" align=\"right\"><b>Order Total</b></td>"
			+"<td align=\"right\">"+currFormat.format(total)+"</td></tr>");
	out.println("</table>");
	out.println("<h2><a href='checkout.jsp' style='display: inline-block; padding: 10px 20px; background-color:#769d6d; color: #ffffff; text-decoration: none; border-radius: 5px; border: 1px solid #769d6d;'>Contiue to Check Out!</a></h2>");

	String deleteProductId = request.getParameter("delete");
   	if (deleteProductId != null) {
       	productList.remove(deleteProductId);
       	session.setAttribute("productList", productList);
       	response.sendRedirect("showcart.jsp");  // Redirect to refresh the page
   	}
}
%>
<h2 align="center" ><a href="listprod.jsp" style="display: inline-block; padding: 10px 20px; background-color:#5a7a53; color: #ffffff; text-decoration: none; border-radius: 20px; border: 1px solid #5a7a53;">Continue Shopping</a></h2>
</body>
</html> 
