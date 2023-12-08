<!DOCTYPE html>
<html>
<%@ include file="header.jsp"%>
<style>
        h1 {color:#1baa82;}
        h2 {color:black;}
</style>
<head>
<title>A to Z's Nursery Checkout Line</title>
</head>
<body>

<h2>Checkout Information</h2>

<h1>Please provide the following details to complete your transaction</h1>

<form method="get" action="order.jsp">
<h2>1. Verify your customer ID and password:</h2>
    <table>
        <tbody>
            <tr>
                <td>Customer ID: </td>
                <td><input type="text" name="customerId" size="50"></td>
            </tr>
            <tr>
                <td>Password: </td>
                <td><input type="text" name="password" size="50"></td>
            </tr>
        </tbody>
    </table>
<h2>2. Shipping Information</h2>
    <table>
        <tbody>
            <tr>
                <td>Address: </td>
                <td><input type="text" name="address" size="50"></td>
            </tr>
            <tr>
                <td>City: </td>
                <td><input type="text" name="city" size="50"></td>
            </tr>
            <tr>
                <td>State: </td>
                <td><input type="text" name="State" size="50"></td>
            </tr>
            <tr>
                <td>Postal Code: </td>
                <td><input type="text" name="postalCode" size="50"></td>
            </tr>
            <tr>
                <td>Country: </td>
                <td><input type="text" name="country" size="50"></td>
            </tr>
        </tbody>
    </table>
<h2>3. Payment Information</h2>
    <table>
        <tbody>
            <tr>
                <td>Payment Type: </td>
                <td><input type="text" name="paymentType" size="50"></td>
            </tr>
            <tr>
                <td>Card Number: </td>
                <td><input type="text" name="paymentNumber" size="50"></td>
            </tr>
            <tr>
                <td>Expiry Date (YYYY-MM-DD): </td>
                <td><input type="text" name="paymentExpiryDate" size="50"></td>
            </tr>
        </tbody>
    </table>
    <input type="submit" value="Submit"><input type="reset" value="Reset">
</form>


</body>
</html>

