<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
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
<style>
        h1 {color:#1baa82;}
        h2 {color:black;}
</style>
<head>
<title>A & Z's Grocery Order Processing</title>
</head>
<body>

<% 
// Get customer id
String custId = request.getParameter("customerId");
String password = request.getParameter("password");
@SuppressWarnings({"unchecked"})
HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

// Check if valid customer id was entered and if there are products in the shopping cart
if (custId != null && productList != null && password != null && !productList.isEmpty()) {
    
    // Initialize Variables
    String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
    String uid = "sa";
    String pw = "304#sa#pw";

    // Load driver class    
    try {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    } catch (java.lang.ClassNotFoundException e) {
        System.err.println("ClassNotFoundException: " + e);
        System.exit(1);
    }

    // Initialize orderId
    int orderId = 0;

    //Connect to server
    try (Connection connection = DriverManager.getConnection(url, uid, pw); Statement stmt = connection.createStatement();) {

        // Begin transaction
        connection.setAutoCommit(false);

        try {
            //Verify customer id is connected to a user and that password matches
            String checkIdQuery = "SELECT firstName, lastName, password FROM customer WHERE customerId = ?";
            PreparedStatement checkIdStatement = connection.prepareStatement(checkIdQuery);
            checkIdStatement.setString(1, custId);
            ResultSet checkIdResultSet = checkIdStatement.executeQuery();

            String first = "";
            String last = "";
            String pass = "";

            while (checkIdResultSet.next()) {
                first = checkIdResultSet.getString("firstName");
                last = checkIdResultSet.getString("lastName");
                pass = checkIdResultSet.getString("password");
            }

            if (!first.isEmpty() && !last.isEmpty() && pass.equals(password)) {

                //Save order info to db
                String orderInsertQuery = "INSERT INTO orderSummary (customerId, orderDate, totalAmount) VALUES (?, GETDATE(), ?)";
                PreparedStatement orderStmt = connection.prepareStatement(orderInsertQuery, Statement.RETURN_GENERATED_KEYS);
                orderStmt.setInt(1, Integer.parseInt(custId));

                //Calculate total amount
                double totalAmount = 0;
                Iterator<Map.Entry<String, ArrayList<Object>>> iterator = productList.entrySet().iterator();
                while (iterator.hasNext()) {
                    Map.Entry<String, ArrayList<Object>> entry = iterator.next();
                    ArrayList<Object> product = entry.getValue();
                    String productId = (String) product.get(0);
				    String price = (String) product.get(2);
                    int quantity = (Integer) product.get(3);

                    // Calculate total amount for the order
                    totalAmount += quantity * Double.parseDouble(price);
                }

                //Set total amount in orderSummary
                orderStmt.setDouble(2, totalAmount);

                //Execute order statement
                orderStmt.executeUpdate();

                //Retrieve auto-generated order id
                ResultSet generatedKeys = orderStmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    orderId = generatedKeys.getInt(1);

                    //Insert items into orderProduct table
                    Iterator<Map.Entry<String, ArrayList<Object>>> productIterator = productList.entrySet().iterator();
                    while (productIterator.hasNext()) {
                        Map.Entry<String, ArrayList<Object>> entry = productIterator.next();
                        ArrayList<Object> product = entry.getValue();
                        String productId = (String) product.get(0);
                        String price = (String) product.get(2);
					    int quantity = (Integer) product.get(3);

                        //Insert product into orderProduct
                        String productInsertQuery = "INSERT INTO orderProduct (orderId, productId, quantity, price) VALUES (?, ?, ?, ?)";
                        PreparedStatement productStmt = connection.prepareStatement(productInsertQuery);

                        //Set parameters for product statement
                        productStmt.setInt(1, orderId);
                        productStmt.setInt(2, Integer.parseInt(productId));
                        productStmt.setInt(3, quantity);
                        productStmt.setDouble(4, Double.parseDouble(price));
                        productStmt.executeUpdate();
                    }

                    connection.commit();

                    //Print order summary
				    out.println("<h2>Your Order Summary</h2>");
                    out.println("<table><th>Product Id</th>");
				    out.println("<th>Product Name</th>");
				    out.println("<th>Quantity</th>");
				    out.println("<th>Price</th>");
				    out.println("<th>Subtotal</th>");

                    Iterator<Map.Entry<String, ArrayList<Object>>> productIterator2 = productList.entrySet().iterator();
                    while (productIterator2.hasNext()) {
                        Map.Entry<String, ArrayList<Object>> entry = productIterator2.next();
                        ArrayList<Object> product = entry.getValue();
					    String productId = (String) product.get(0);
                        String productName = (String) product.get(1);
					    String price = (String) product.get(2);
                        int quantity = (Integer) product.get(3);

                        out.println("<tr><td>" + productId + "</td><td>" + productName + "</td><td>" + quantity + "</td><td>" + NumberFormat.getCurrencyInstance().format(Double.parseDouble(price)) + "</td><td>" + NumberFormat.getCurrencyInstance().format(Double.valueOf(price) * quantity) + "</td></tr>");
                    }

				    out.println("</table>");
				    out.println("<p>Total Amount: " + NumberFormat.getCurrencyInstance().format(totalAmount) + "</p>");
				    out.println("<h2>Order completed. Will be shipped soon...</h2>");
				    out.println("<h2>Your order reference number is: " + orderId + "</h2>");
				    out.println("<h2>Shipping to Customer: " + custId + ", Name: " + first + " " + last + "</h2>");

                    out.println("<h2><a href='ship.jsp?orderId=" + orderId + "' style='color:#769d6d'>Continue to Shipment</a></h2>");
                }
            }
            else {
                //Error message if customer id not in database
                out.println("<p>Error: Incorrect Customer id or Password</p>");
            } 
        } 
        catch (SQLException e) {
            //Rollback transaction in case of error
            connection.rollback();
            throw e;
        } 
        finally {
            connection.setAutoCommit(true);
        }
    } 
    catch (SQLException e) {
        //Handle exceptions
        out.println("<p>Error: " + e.getMessage() + "</p>");
    } 
} 
else {
    // Error message if customer id or shopping cart is invalid
    out.println("<p>Error: Invalid customer id or no items in the shopping cart</p>");
}
%>
</BODY>
</HTML>