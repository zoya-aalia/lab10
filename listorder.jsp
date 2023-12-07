<%@ page import="java.sql.*" %>
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
<style>
        h1 {color:#1baa82;}
        h2 {color:black;}
</style>
<head>
<title>A & Z's Grocery Order List</title>
</head>
<body>
<h2>Order List</h2>
<table border="1">
    <%
    // Note: Forces loading of SQL Server driver 

    // Initialize Variables
    String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
    String uid = "sa";
    String pw = "304#sa#pw";

    // Load driver class
        
    try {	
	    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    }

    catch (java.lang.ClassNotFoundException e) {
	    System.err.println("ClassNotFoundException: " +e);
	    System.exit(1);
    }

    //Connect to server

    try (Connection connection = DriverManager.getConnection(url, uid, pw); Statement stmt = connection.createStatement();) {

        //Query to retrieve all summary records
        String orderQuery = "SELECT * FROM ordersummary";
        PreparedStatement orderStatement = connection.prepareStatement(orderQuery);
        ResultSet orderResultSet = orderStatement.executeQuery();

        out.println("<th>Order ID</th>");
        out.println("<th>Order Date</th>");
        out.println("<th>Total Amount</th>");
        out.println("<th>Customer</th>");

        while (orderResultSet.next()) {
            //Print order summary info
            int orderId = orderResultSet.getInt("orderId");
            Date orderDate = orderResultSet.getDate("orderDate");
            double totalAmount = orderResultSet.getDouble("totalAmount");
            int customerId = orderResultSet.getInt("customerId");

            String customerNameQuery = "SELECT firstName, lastName FROM customer WHERE customerId = ?";
            PreparedStatement customerStatement = connection.prepareStatement(customerNameQuery);
            customerStatement.setInt(1, customerId);
            ResultSet customerResultSet = customerStatement.executeQuery();

            if (customerResultSet.next()) {
                String firstName = customerResultSet.getString("firstName");
                String lastName = customerResultSet.getString("lastName");

                out.println("<tr><td>" + orderId + "</td>");
                out.println("<td>" + orderDate + "</td>");
                out.println("<td>" + NumberFormat.getCurrencyInstance().format(totalAmount) + "</td>");
                out.println("<td>" + firstName + " " + lastName + "</td></tr>");

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

            //Close customer ResultSet and Statement
            customerResultSet.close();
            customerStatement.close();
        }
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