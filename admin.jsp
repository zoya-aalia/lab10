<%@ page import="java.sql.*,java.net.URLEncoder" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
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
    h1 {color:#a06296;}
    h2 {color:black;}
</style>
<head>
    <title>Administrator Page</title>
    <script src="https://d3js.org/d3.v6.min.js"></script>
</head>
<body>

<%@ include file="auth.jsp"%>
<%@ include file="jdbc.jsp"%>

<%
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
        //Write SQL query that prints out the total order amount by day
        String sql = "SELECT orderDate AS orderDay, SUM(totalAmount) AS totalSales FROM ordersummary GROUP BY orderDate";
        PreparedStatement preparedStatement = connection.prepareStatement(sql);
        ResultSet resultSet = preparedStatement.executeQuery();
        
        // Process data for D3 chart
        List<Map<String, Object>> chartData = new ArrayList<>();
        while (resultSet.next()) {
            String orderDay = resultSet.getString("orderDay");
            double totalSales = resultSet.getDouble("totalSales");

            Map<String, Object> entry = new HashMap<>();
            entry.put("Day", orderDay);
            entry.put("Total Sales", totalSales);
            chartData.add(entry);
        }
%>

        <h2>Total Sales Report</h2>
        <table border="1">
            <tr><th>Order Day</th><th>Total Sales</th></tr>
            <% for (Map<String, Object> entry : chartData) { %>
                <tr>
                    <td><%= entry.get("Day") %></td>
                    <td><%= entry.get("Total Sales") %></td>
                </tr>
            <% } %>
        </table>

    

<%
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        closeConnection();
    }

} catch (Exception e) {
    e.printStackTrace();
}
%>

</body>
</html>
