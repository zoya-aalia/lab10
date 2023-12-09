<%@ page import="java.sql.*,java.net.URLEncoder" %>
<%@ page import="java.text.NumberFormat" %>
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

<head>
<title>A to Z Plant Nursery Product Search</title>
    <style>
        h1 {color:#a06296;}
        h2 {color:#344f2e;}
    </style>
</head>
<body>

<h2 style = "font-family:'Courier New'">Search All Products:</h2>
<form method="get" action="listprod.jsp">
<input type="text" name="productName" size="50">
<input type="submit" value="Search" style="font-family:'Optima'; display: inline-block; padding: 5px 10px; background-color:#5a7a53; color: #ffffff; text-decoration: none; border-radius: 20px; border: 1px solid #5a7a53;">
<input type="reset" value="Reset" style="font-family:'Optima'; display: inline-block; padding: 5px 10px; background-color:#5a7a53; color: #ffffff; text-decoration: none; border-radius: 20px; border: 1px solid #5a7a53;"> 
<p style="font-family:'Optima';">(Leave blank for all products)</p>
</form>


<h2 style = "font-family:'Courier New'">Shop By Category:</h2>
<form method="get" action="listprod.jsp">
	<button type="submit" name="categoryId" value="1" style="font-family:'Optima'; display: inline-block; padding: 5px 10px; background-color:#5a7a53; color: #ffffff; text-decoration: none; border-radius: 20px; border: 1px solid #5a7a53;">Flowers</button>
	<button type="submit" name="categoryId" value="2" style="font-family:'Optima'; display: inline-block; padding: 5px 10px; background-color:#5a7a53; color: #ffffff; text-decoration: none; border-radius: 20px; border: 1px solid #5a7a53;">Herbs</button>
	<button type="submit" name="categoryId" value="3" style="font-family:'Optima'; display: inline-block; padding: 5px 10px; background-color:#5a7a53; color: #ffffff; text-decoration: none; border-radius: 20px; border: 1px solid #5a7a53;">Houseplants</button>
	<button type="submit" name="categoryId" value="4" style="font-family:'Optima'; display: inline-block; padding: 5px 10px; background-color:#5a7a53; color: #ffffff; text-decoration: none; border-radius: 20px; border: 1px solid #5a7a53;">Gardening Products</button>
</form>

<% 
// Variable name now contains the search string the user entered
// Use it to build a query and print out the resultset.  Make sure to use PreparedStatement!

// Get product name and category value
String name = String.valueOf(request.getParameter("productName"));
String categoryId = String.valueOf(request.getParameter("categoryId"));

//Initialize Variables
String url = "db-mysql-tor1-67398-do-user-15341079-0.c.db.ondigitalocean.com";
String uid = "doadmin";
String pw = "AVNS_dSm1J79fUKXrKAX4BpD";

//Load driver class
        
try {	
	Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
}

catch (java.lang.ClassNotFoundException e) {
	System.err.println("ClassNotFoundException: " +e);
	System.exit(1);
}

//Connect to server

try (Connection connection = DriverManager.getConnection(url, uid, pw); Statement stmt = connection.createStatement();) {

	//check category
    if (categoryId != "null" && !categoryId.isEmpty()) {
        // No need to check for product name when filtering by category
        String productQuery = "SELECT * FROM product WHERE categoryId = ?";
        PreparedStatement productStatement = connection.prepareStatement(productQuery);
        productStatement.setInt(1, Integer.parseInt(categoryId));
        ResultSet productResultSet = productStatement.executeQuery();

        out.println("<h2>Products in Category</h2>");
        out.println("<table border=\"1\">");
        out.println("<tr><th> </th>");
        out.println("<th>Product Name</th>");
        out.println("<th>Price</th>");

        // Print ResultSet
        while (productResultSet.next()) {
            int productId = productResultSet.getInt("productId");
            String productName = productResultSet.getString("productName");
            double productPrice = productResultSet.getDouble("productPrice");
        
            if (session.getAttribute("authenticatedUser") != null) {
                // Create links for each product
                out.println("<tr><td><a href='addcart.jsp?logged=True&id=" + productId +
                        "&name=" + URLEncoder.encode(productName, "UTF-8") +
                        "&price=" + productPrice + "' style='color:#769d6d'>Add to Cart</a></td><td><a href='product.jsp?logged=True&id=" + productId + "' style='color:#769d6d'>" + productName + "</a></td><td>" + NumberFormat.getCurrencyInstance().format(productPrice) + "</td></tr>");
            } else {
                // Create links for each product
                out.println("<tr><td><a href='addcart.jsp?id=" + productId +
                        "&name=" + URLEncoder.encode(productName, "UTF-8") +
                        "&price=" + productPrice + "' style='color:#769d6d'>Add to Cart</a></td><td><a href='product.jsp?id=" + productId + "' style='color:#769d6d'>" + productName + "</a></td><td>" + NumberFormat.getCurrencyInstance().format(productPrice) + "</td></tr>");
            }
        }
        out.println("</table>");
		
		// Close connection
        productResultSet.close();
       	productStatement.close();
		connection.close();
	}

    // check search
    else {
        if (name != "null" && !name.equals("") && !name.isEmpty()) {
			String productQuery = "SELECT * FROM product WHERE productName LIKE ?";
			PreparedStatement productStatement = connection.prepareStatement(productQuery);
			productStatement.setString(1, "%" + name + "%");
			ResultSet productResultSet = productStatement.executeQuery();

			out.println("<h2>Product's Containing '" + name + "'</h2>");
			out.println("<table border=\"1\"><th> </th>");
			out.println("<th>Product Name</th>");
			out.println("<th>Price</th>");

			//Print ResultSet
			while (productResultSet.next()) {
				int productId = productResultSet.getInt("productId");
				String productName = productResultSet.getString("productName");
				double productPrice = productResultSet.getDouble("productPrice");

				if (session.getAttribute("authenticatedUser") != null) {
					//Create links for each product
					out.println("<tr><td><a href='addcart.jsp?logged=True&id=" + productId +
						"&name=" + URLEncoder.encode(productName, "UTF-8") +
						"&price=" + productPrice + "' style='color:#769d6d'>Add to Cart</a></td><td><a href='product.jsp?logged=True&id=" + productId + "' style='color:#769d6d'>" + productName + "</a></td><td>" + NumberFormat.getCurrencyInstance().format(productPrice) + "</td></tr>");
				}
				else {
					//Create links for each product
					out.println("<tr><td><a href='addcart.jsp?id=" + productId +
						"&name=" + URLEncoder.encode(productName, "UTF-8") +
						"&price=" + productPrice + "' style='color:#769d6d'>Add to Cart</a></td><td><a href='product.jsp?id=" + productId + "' style='color:#769d6d'>" + productName + "</a></td><td>" + NumberFormat.getCurrencyInstance().format(productPrice) + "</td></tr>");
				}
			}

			//Close connection
			productResultSet.close();
			productStatement.close();
			connection.close();
		}
		else {
			String productQuery = "SELECT * FROM product";
			PreparedStatement productStatement = connection.prepareStatement(productQuery);
			ResultSet productResultSet = productStatement.executeQuery();

			out.println("<h2>All Products</h2>");
			out.println("<table border=\"1\"><th> </th>");
			out.println("<th>Product Name</th>");
			out.println("<th>Price</th>");

			//Print out the ResultSet
			while (productResultSet.next()) {
				int productId = productResultSet.getInt("productId");
				String productName = productResultSet.getString("productName");
				double productPrice = productResultSet.getDouble("productPrice");

				if (session.getAttribute("authenticatedUser") != null) {
					//Create links for each product
					out.println("<tr><td><a href='addcart.jsp?logged=True&id=" + productId +
						"&name=" + URLEncoder.encode(productName, "UTF-8") +
						"&price=" + productPrice + "' style='color:#769d6d'>Add to Cart</a></td><td><a href='product.jsp?logged=True&id=" + productId + "' style='color:#769d6d'>" + productName + "</a></td><td>" + NumberFormat.getCurrencyInstance().format(productPrice) + "</td></tr>");
				}
				else {
					//Create links for each product
					out.println("<tr><td><a href='addcart.jsp?id=" + productId +
						"&name=" + URLEncoder.encode(productName, "UTF-8") +
						"&price=" + productPrice + "' style='color:#769d6d'>Add to Cart</a></td><td><a href='product.jsp?id=" + productId + "' style='color:#769d6d'>" + productName + "</a></td><td>" + NumberFormat.getCurrencyInstance().format(productPrice) + "</td></tr>");
				}
			}

			out.println("</table>");

        	// Close connection
        	productResultSet.close();
       		productStatement.close();
			connection.close();
    	}
	}
}
catch (SQLException ex) {
	System.err.println("SQLException: " + ex);
}


%>

</body>
</html>
