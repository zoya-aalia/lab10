<%@ page language="java" import="java.io.*,java.sql.*"%>
<%@ include file="jdbc.jsp" %>
<%
	String authenticatedUser = null;
	session = request.getSession(true);

	try
	{
		authenticatedUser = validateLogin(out,request,session);
	}
	catch(IOException e)
	{	System.err.println(e); }

	if(authenticatedUser != null)
		response.sendRedirect("index.jsp");		// Successful login
	else
		response.sendRedirect("login.jsp");		// Failed login - redirect back to login page with a message 
%>


<%!
	String validateLogin(JspWriter out,HttpServletRequest request, HttpSession session) throws IOException {
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		String retStr = null;

		if(username == null || password == null)
				return null;
		if((username.length() == 0) || (password.length() == 0))
				return null;
    
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


    	//Connect to server
    	try (Connection connection = DriverManager.getConnection(url, uid, pw); Statement stmt = connection.createStatement();) {

        	// Begin transaction
        	connection.setAutoCommit(false);

        	try {
            	//Verify customer id is connected to a user
            	String checkIdQuery = "SELECT firstName, lastName, password FROM customer WHERE userId= ?";
            	PreparedStatement checkIdStatement = connection.prepareStatement(checkIdQuery);
            	checkIdStatement.setString(1, username);
            	ResultSet checkIdResultSet = checkIdStatement.executeQuery();

            	String first = "";
            	String last = "";
            	String pass = "";

            	while (checkIdResultSet.next()) {
                	first = checkIdResultSet.getString("firstName");
                	last = checkIdResultSet.getString("lastName");
                	pass = checkIdResultSet.getString("password");
            	}

				//Check if userId and password match some customer account. If so, set retStr to be the username.
            	if (!first.isEmpty() && !last.isEmpty() && pass.equals(password)) {

                	retStr = username;
				}
				else {
                //Error message if customer id not in database
                out.println("<p>Error: Incorrect Customer id or Password</p>");
            	}
			}
			catch (SQLException ex) {
				out.println(ex);
			}
			finally {
				closeConnection();
			}	
			if(retStr != null) {	
				session.removeAttribute("loginMessage");
				session.setAttribute("authenticatedUser",username);
			}
			else
			session.setAttribute("loginMessage","Could not connect to the system using that username/password.");
		}
		catch (SQLException e) {
        //Handle exceptions
        out.println("<p>Error: " + e.getMessage() + "</p>");
    	} 

		return retStr;
	}
%>