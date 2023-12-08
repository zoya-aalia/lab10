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

        <!-- HTML canvas element for the D3 chart -->
        <div style="width: 80%; margin: auto;">
            <svg id="d3Chart" width="928" height="500"></svg>
        </div>

        <!-- JavaScript code for creating the D3 chart -->
        <script>
            // D3 chart function
            function createChart(data) {
                // Declare the chart dimensions and margins.
                const width = 928;
                const height = 500;
                const marginTop = 30;
                const marginRight = 0;
                const marginBottom = 30;
                const marginLeft = 40;

                // Declare the x (horizontal position) scale.
                const x = d3.scaleBand()
                    .domain(d3.groupSort(data, ([d]) => -d.Total_Sales, (d) => d.Day)) // descending frequency
                    .range([marginLeft, width - marginRight])
                    .padding(0.1);

                // Declare the y (vertical position) scale.
                const y = d3.scaleLinear()
                    .domain([0, d3.max(data, (d) => d.Total_Sales)])
                    .range([height - marginBottom, marginTop]);

                // Create the SVG container.
                const svg = d3.select("#d3Chart")
                    .attr("width", width)
                    .attr("height", height)
                    .attr("viewBox", [0, 0, width, height])
                    .attr("style", "max-width: 100%; height: auto;");

                // Add a rect for each bar.
                svg.append("g")
                    .attr("fill", "steelblue")
                    .selectAll()
                    .data(data)
                    .join("rect")
                    .attr("x", (d) => x(d.Day))
                    .attr("y", (d) => y(d.Total_Sales))
                    .attr("height", (d) => y(0) - y(d.Total_Sales))
                    .attr("width", x.bandwidth());

                // Add the x-axis and label.
                svg.append("g")
                    .attr("transform", `translate(0,${height - marginBottom})`)
                    .call(d3.axisBottom(x).tickSizeOuter(0));

                // Add the y-axis and label, and remove the domain line.
                svg.append("g")
                    .attr("transform", `translate(${marginLeft},0)`)
                    .call(d3.axisLeft(y).tickFormat((y) => (y * 100).toFixed()))
                    .call(g => g.select(".domain").remove())
                    .call(g => g.append("text")
                        .attr("x", -marginLeft)
                        .attr("y", 10)
                        .attr("fill", "currentColor")
                        .attr("text-anchor", "start")
                        .text("↑ Frequency (%)"));

                // Return the SVG element.
                return svg.node();
            }

            // Call the chart function and append the generated SVG to the body
            createChart(new Gson().toJson(chartData));


        </script>

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
