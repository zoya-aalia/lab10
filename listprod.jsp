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


<h2 style = "font-family:'Courier New'">Find New Bestsellers!</h2>
<form method="get" action="listprod.jsp">
	<input type="hidden" name="productName" value="">
	<button type="submit" value="bestSelling" style="font-family:'Optima'; display: inline-block; padding: 5px 10px; background-color:#5a7a53; color: #ffffff; text-decoration: none; border-radius: 20px; border: 1px solid #5a7a53;">Bestsellers</button>
</form>


<h2 style = "font-family:'Courier New'">Shop By Category:</h2>
<form method="get" action="listprod.jsp">
	<button type="submit" name="categoryId" value="1" style="font-family:'Optima'; display: inline-block; padding: 5px 10px; background-color:#5a7a53; color: #ffffff; text-decoration: none; border-radius: 20px; border: 1px solid #5a7a53;">Flowers</button>
	<button type="submit" name="categoryId" value="2" style="font-family:'Optima'; display: inline-block; padding: 5px 10px; background-color:#5a7a53; color: #ffffff; text-decoration: none; border-radius: 20px; border: 1px solid #5a7a53;">Herbs</button>
	<button type="submit" name="categoryId" value="3" style="font-family:'Optima'; display: inline-block; padding: 5px 10px; background-color:#5a7a53; color: #ffffff; text-decoration: none; border-radius: 20px; border: 1px solid #5a7a53;">Houseplants</button>
	<button type="submit" name="categoryId" value="4" style="font-family:'Optima'; display: inline-block; padding: 5px 10px; background-color:#5a7a53; color: #ffffff; text-decoration: none; border-radius: 20px; border: 1px solid #5a7a53;">Gardening Products</button>
</form>


<h2 style = "font-family:'Courier New'">Filter Options:</h2>
<form method="get" action="listprod.jsp">
    <input type="hidden" name="productName" value="">
    <select name="filterOption">
        <option style="font-family:'Optima' value ='default'";>Select an option </option>
        <option value="bestSelling">Best-Selling Products</option>
        <option value="hasImage">Products with Images</option>
    </select>
    <input type="submit" value="Apply Filter" style="font-family:'Optima'; display: inline-block; padding: 5px 10px; background-color:#5a7a53; color: #ffffff; text-decoration: none; border-radius: 20px; border: 1px solid #5a7a53;">
</form>

<% 
// Variable name now contains the search string the user entered
// Use it to build a query and print out the resultset.  Make sure to use PreparedStatement!

// Get product name to search for
String name = String.valueOf(request.getParameter("productName"));

// Get category to filter
String categoryId = String.valueOf(request.getParameter("categoryId"));

// Check filter option
String filterOption = String.valueOf(request.getParameter("filterOption"));


//Note: Forces loading of SQL Server driver

//Initialize Variables
String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
String uid = "sa";
String pw = "304#sa#pw";

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

	
    // check category first
    if (categoryId != null && !categoryId.isEmpty()) {
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
        
	} 
	if ("bestSelling".equals(filterOption)) {
		String bestSellingQuery = "SELECT TOP 5 productId, SUM(totalAmount) AS totalSales " +
				"FROM ordersummary " +
				"GROUP BY productId " +
				"ORDER BY totalSales DESC";
		PreparedStatement bestSellingStatement = connection.prepareStatement(bestSellingQuery);
		ResultSet bestSellingResultSet = bestSellingStatement.executeQuery();
	
		out.println("<h2>Best-Selling Products</h2>");
        out.println("<table border=\"1\">");
        out.println("<tr><th>Product Name</th><th>Total Sales</th></tr>");

	
		while (bestSellingResultSet.next()) {
			int productId = bestSellingResultSet.getInt("productId");
			double totalSales = bestSellingResultSet.getDouble("totalSales");
	
			// Fetch the product information using productId and display it
			// You need to have another query to get product details based on the productId
	
			// Example placeholder:
			String productDetailsQuery = "SELECT productName FROM product WHERE productId = ?";
			PreparedStatement productDetailsStatement = connection.prepareStatement(productDetailsQuery);
			productDetailsStatement.setInt(1, productId);
			ResultSet productDetailsResultSet = productDetailsStatement.executeQuery();
	
			if (productDetailsResultSet.next()) {
				String productName = productDetailsResultSet.getString("productName");
	
                out.println("</table>");			}
	
			// Close the product details ResultSet and Statement
			productDetailsResultSet.close();
			productDetailsStatement.close();
		}
	
		// Close the best-selling ResultSet and Statement
		bestSellingResultSet.close();
		bestSellingStatement.close();
	
	}else if ("hasImage".equals(filterOption)) {
            String productQuery = "SELECT * FROM product WHERE productImage IS NOT NULL";
            PreparedStatement productStatement = connection.prepareStatement(productQuery);
            ResultSet productResultSet = productStatement.executeQuery();
        
            out.println("<h2>Products with Images</h2>");
            out.println("<table border=\"1\">");
            out.println("<tr><th>Product Name</th><th>Price</th><th>Action</th></tr>");

            // Print ResultSet
            while (productResultSet.next()) {
                int productId = productResultSet.getInt("productId");
                String productName = productResultSet.getString("productName");
                double productPrice = productResultSet.getDouble("productPrice");
        
                out.println("<tr>");
                out.println("<td>" + productName + "</td>");
                out.println("<td>" + NumberFormat.getCurrencyInstance().format(productPrice) + "</td>");
                out.println("<td><a href='addcart.jsp?" + (session.getAttribute("authenticatedUser") != null ? "logged=True&" : "") +
                        "id=" + productId +
                        "&name=" + URLEncoder.encode(productName, "UTF-8") +
                        "&price=" + productPrice + "' style='color:#769d6d'>Add to Cart</a></td>");
                out.println("</tr>");
            }
        
            out.println("</table>");
        
            // Close connection
            productResultSet.close();
            productStatement.close();
            connection.close();
        
        } else {
        // check search
        if (name != null && !name.isEmpty()) {
            String productQuery = "SELECT * FROM product WHERE productName LIKE ?";
            PreparedStatement productStatement = connection.prepareStatement(productQuery);
            productStatement.setString(1, "%" + name + "%");
            ResultSet productResultSet = productStatement.executeQuery();

            out.println("<h2>Product Search: '" + name + "'</h2>");
            out.println("<table border=\"1\"><th> </th>");
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


            // Close connection
            productResultSet.close();
            productStatement.close();
            connection.close();


        } else {
            String productQuery = "SELECT * FROM product";
            PreparedStatement productStatement = connection.prepareStatement(productQuery);
            ResultSet productResultSet = productStatement.executeQuery();

            out.println("<h2>All Products</h2>");
		    out.println("<table border=\"1\"><th> </th>");
		    out.println("<th>Product Name</th>");
		    out.println("<th>Price</th>");

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
    }
}  catch (SQLException ex) {
    ex.printStackTrace();
} catch (Exception e) {
    e.printStackTrace();
}


%>

</body>
</html>
