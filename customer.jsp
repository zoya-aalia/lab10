<!DOCTYPE html>
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
<style>
        h1 {color:#1baa82;}
        h2 {color:black;}
</style>
<head>
<title>Customer Page</title>
</head>
<body>

<%@ include file="auth.jsp"%>
<%@ page import="java.text.NumberFormat" %>
<%@ include file="jdbc.jsp" %>

<%
	String userName = (String) session.getAttribute("authenticatedUser");
%>

<%
	// Check if valid user name in database
	if (userName != null) {
		// Initialize Variables
    	String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
    	String uid = "sa";
    	String pw = "304#sa#pw";

    	// Load driver class    
    	try {
        	Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    	} 
		catch (java.lang.ClassNotFoundException e) {
        	System.err.println("ClassNotFoundException: " + e);
        	System.exit(1);
    	}

		try (Connection connection = DriverManager.getConnection(url, uid, pw); Statement stmt = connection.createStatement();) {
			try {
				//Check that username is in database
				String checkUserQuery = "SELECT userid FROM customer WHERE userid = ?";
				PreparedStatement checkUserStatement = connection.prepareStatement(checkUserQuery);
    			checkUserStatement.setString(1, userName);
    			ResultSet checkUserResultSet = checkUserStatement.executeQuery();

				String user = "";

    			while (checkUserResultSet.next()) {
        			user = checkUserResultSet.getString("userid");
    			}
				
				if (!user.isEmpty()) {
					// Print Customer information
					String getUserQuery = "SELECT customerId, firstName, lastName, email, phonenum, address, city, state, postalcode, country FROM customer WHERE userId = ?";
					PreparedStatement getUserStatement = connection.prepareStatement(getUserQuery);
    				getUserStatement.setString(1, userName);
    				ResultSet getUserResultSet = getUserStatement.executeQuery();

					while (getUserResultSet.next()) {
        				String cid = getUserResultSet.getString("customerId");
						String first = getUserResultSet.getString("firstName");
						String last = getUserResultSet.getString("lastName");
						String email = getUserResultSet.getString("email");
						String phone = getUserResultSet.getString("phonenum");
						String addy = getUserResultSet.getString("address");
						String city = getUserResultSet.getString("city");
						String state = getUserResultSet.getString("state");
						String postcode = getUserResultSet.getString("postalcode");
						String country = getUserResultSet.getString("country");

						out.print("<h2>Customer Profile</h2>");
						out.print("<table border='1'>");
						out.print("<tr><th>Id</th><td>" + cid + "</td></tr>");
						out.print("<tr><th>First Name</th><<td>" + first + "</td></tr>");
						out.print("<tr><th>Last Name</th><<td>" + last + "</td></tr>");
						out.print("<tr><th>Email</th><td>" + email + "</td></tr>");
						out.print("<tr><th>Phone</th><td>" + phone + "</td></tr>");
						out.print("<tr><th>Address</th><td>" + addy + "</td></tr>");
						out.print("<tr><th>City</th><td>" + city + "</td></tr>");
						out.print("<tr><th>State</th><td>" + state + "</td></tr>");
						out.print("<tr><th>Postal Code</th><td>" + postcode + "</td></tr>");
						out.print("<tr><th>Country</th><td>" + country + "</td></tr>");
						out.print("<tr><th>User id</th><td>" + userName + "</td></tr></table>");
    				}

				}
				else {
                //Error message if customer id not in database
                out.println("<p>Error: Incorrect Customer id or Password</p>");
				}
			}
			catch (SQLException e) {
            throw e;
			} 
		}
		catch (SQLException e) {
        //Handle exceptions
        out.println("<p>Error: " + e.getMessage() + "</p>");
    	} 
	}
	else {
    // Error message if customer id is null
    out.println("<p>Error: Customer id not found</p>");
	}
%>

<h2>Customer Orders</h2>

<table border="1">
<%
    try (Connection connection = DriverManager.getConnection(url, uid, pw); Statement stmt = connection.createStatement();) {

        String cidQuery = "SELECT customerId FROM customer WHERE userid = ?";
        PreparedStatement cidStatement = connection.prepareStatement(cidQuery);
        cidStatement.setString(1, userName);
        ResultSet cidResultSet = cidStatement.executeQuery();

        if (cidResultSet.next()) {
            String cid = cidResultSet.getString("customerId");
		
			//Query to retrieve all summary records
        	String orderQuery = "SELECT * FROM ordersummary WHERE customerId = ?";
        	PreparedStatement orderStatement = connection.prepareStatement(orderQuery);
			orderStatement.setString(1, cid);
        	ResultSet orderResultSet = orderStatement.executeQuery();

       	 	out.println("<th>Order ID</th>");
        	out.println("<th>Order Date</th>");
        	out.println("<th>Total Amount</th>");

        	while (orderResultSet.next()) {
            	//Print order summary info
            	int orderId = orderResultSet.getInt("orderId");
            	Date orderDate = orderResultSet.getDate("orderDate");
            	double totalAmount = orderResultSet.getDouble("totalAmount");
            	int customerId = orderResultSet.getInt("customerId");

                out.println("<tr><td>" + orderId + "</td>");
                out.println("<td>" + orderDate + "</td>");
                out.println("<td>" + NumberFormat.getCurrencyInstance().format(totalAmount) + "</td>");

                //Retrieve products in the order
                String productQuery = "SELECT * FROM orderproduct WHERE orderId = ?";
                PreparedStatement productStatement = connection.prepareStatement(productQuery);
                productStatement.setInt(1, orderId);
                ResultSet productResultSet = productStatement.executeQuery();

                out.println("<tr><td><table border=\"1\"><th>Product ID:</th>");
                out.println("<th>Quantity</th>");
                out.println("<th>Price</th>");

                while (productResultSet.next()) {
                    //Write out product information
                    int productId = productResultSet.getInt("productId");
                    int quantity = productResultSet.getInt("quantity");
                    double price = productResultSet.getDouble("price");

                    out.println("<tr><td>" + productId + "</td><td>" + quantity + "</td><td>" + NumberFormat.getCurrencyInstance().format(price) + "</td></tr>");
                }

                out.println("</table></td></tr>");

                //Close product ResultSet and Statement
                productResultSet.close();
                productStatement.close();
			}
        }
		else {
			//Error message if customer id not in database
            out.println("<p>Error: Incorrect Customer id or Password</p>");
		}
		//Close cid ResultSet and Statement
        cidResultSet.close();
        cidStatement.close();
    } 
    catch (SQLException e) {
        // Handle SQLException if necessary
        out.println("SQLException: " + e);
    } 

    // Useful code for formatting currency values:
    // NumberFormat currFormat = NumberFormat.getCurrencyInstance();
    // out.println(currFormat.format(5.0));  // Prints $5.00

    %>
</table>

</body>
</html>

