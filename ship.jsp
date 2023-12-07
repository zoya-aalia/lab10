<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Date" %>
<%@ include file="jdbc.jsp" %>

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
<title>A & Z's Grocery Shipment Processing</title>
</head>
<body>

<%
	// Get order id
	String orderId = request.getParameter("orderId");
	@SuppressWarnings({"unchecked"})
	HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");
          
	// Check if valid order id in database
	if (orderId != null && productList != null && !productList.isEmpty()) {

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

		//Initialize shipId
		int shipId = 0;

		try (Connection connection = DriverManager.getConnection(url, uid, pw); Statement stmt = connection.createStatement();) {

			// Start a transaction (turn-off auto-commit)
			connection.setAutoCommit(false);

			try {
				String checkIdQuery = "SELECT customerId FROM orderSummary WHERE orderId = ?";
				PreparedStatement checkIdStatement = connection.prepareStatement(checkIdQuery);
    			checkIdStatement.setString(1, orderId);
    			ResultSet checkIdResultSet = checkIdStatement.executeQuery();

				String cid = "";

    			while (checkIdResultSet.next()) {
        			cid = checkIdResultSet.getString("customerId");
    			}

				if (!cid.isEmpty()) {
	
					// Retrieve all items in order with given id
					// Create a new shipment record.
					int wId = 1;
					String shipDesc = "";

					String shipInsertQuery = "INSERT INTO shipment (shipmentDate, shipmentDesc, warehouseId) VALUES (GETDATE(), ?, ?)";
                	PreparedStatement shipStmt = connection.prepareStatement(shipInsertQuery, Statement.RETURN_GENERATED_KEYS);
					shipStmt.setString(1, shipDesc);
					shipStmt.setInt(2, wId);
					shipStmt.executeUpdate();

					//Retrieve auto-generated ship id
                	ResultSet generatedKeys = shipStmt.getGeneratedKeys();
               		if (generatedKeys.next()) {
                    	shipId = generatedKeys.getInt(1);
						Boolean err = false;

                    	Iterator<Map.Entry<String, ArrayList<Object>>> productIterator = productList.entrySet().iterator();
                    	while (productIterator.hasNext()) {
                        	Map.Entry<String, ArrayList<Object>> entry = productIterator.next();
                        	ArrayList<Object> product = entry.getValue();
                        	String productId = (String) product.get(0);
					    	int quantity = (Integer) product.get(3);

                        	// For each item verify sufficient quantity available in warehouse 1.
                        	String checkStockQuery = "SELECT quantity FROM productinventory WHERE productId = ? and warehouseId = ?";
                        	PreparedStatement checkStockStmt = connection.prepareStatement(checkStockQuery);
							checkStockStmt.setInt(1, Integer.parseInt(productId));
							checkStockStmt.setInt(2, quantity);
                        	ResultSet checkStockResultSet = checkStockStmt.executeQuery();

            				int inventory = 0;
            				while (checkStockResultSet.next()) {
                				inventory = checkStockResultSet.getInt("quantity");
            				}

							// If any item does not have sufficient inventory, cancel transaction and rollback. Otherwise, update inventory for each item.
							if (quantity <= inventory) {

								String updateStockQuery = "UPDATE productinventory SET quantity = ? WHERE productId = ? and warehouseId = ?";
								PreparedStatement updateStockStmt = connection.prepareStatement(updateStockQuery);
								updateStockStmt.setInt(1, (inventory - quantity));
                        		updateStockStmt.setInt(2, Integer.parseInt(productId));
                        		updateStockStmt.setInt(3, wId);
								updateStockStmt.executeUpdate();

								out.println("<table><th>Ordered Product: " + productId + "</th>");
								out.println("<th>Qty: " + quantity + "</th>");
								out.println("<th>Previous inventory: " + inventory + "</th>");
								out.println("<th>New inventory: " + (inventory - quantity) + "</th></table>");
							}

							else {
								out.println("<h2>Sorry, shipment could not be completed. Insufficient inventory for product id: " + productId + "</h2>");
								err = true;
								connection.rollback();
								break;
							}
                    	}
						if (!err) {
							connection.commit();
							out.println("<h2>Shipment successfully processed!</h2>");

							//Clear cart if order placed successfully
                    		session.removeAttribute("productList");
						}
					}
				}
				else {
					//Error message if order id not in database
					out.println("<p>Error: Order id does not exist</p>");
				} 
			}
			catch (SQLException e) {
				//Rollback transaction in case of error
				connection.rollback();
				throw e;
			} 
			// Auto-commit should be turned back on
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
		// Error message if order id or shopping cart is invalid
		out.println("<p>Error: Invalid order id or no items in the shopping cart</p>");
	}
%>                       				

<%
if (session.getAttribute("authenticatedUser") != null) {
    %>
    <h2><a href="index.jsp">Back to Main Page</a></h2>
    <%
}
else {
    %>
    <h2><a hrf="shop.html">Back to Main Page</a></h2>
    <%
}
%>

</body>
</html>