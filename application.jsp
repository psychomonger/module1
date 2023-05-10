<!DOCTYPE html>
<head>
	<meta charset="UTF-8">
	<title>Final Project</title>
	<link rel="stylesheet" href="styles.css">
	<script src="scripts.js"></script>
	<!--*****************************************************
	George E. Mitchell
 	202320 Object Oriented Programming COP-3330C-25749
 	Final Programming Project
 	******************************************************-->
</head>
<%@ page import = "java.io.*,java.util.*,java.sql.*" %>
<%@ page import = "java.nio.file.Files" %>
<%@ page import = "java.nio.file.Path" %>
<%@ page import = "java.nio.file.Paths" %>
<%@ page import = "java.util.Date" %>

<%!
public static <T> String getCorrectAnswer(String param1, String param2, Integer problemNumber) {
	
	String dataType; 
	
	// @TODO this needs to be abstracted to determine data type depending on the parameters.
	if (problemNumber == 1 || problemNumber == 2 || problemNumber == 6 || problemNumber == 8){
		
		dataType = "Double";
	
	} else if (problemNumber == 3 || problemNumber == 7 || problemNumber == 9) {	
	
		dataType = "String";
		
	} else if (problemNumber == 4) {	
	
		dataType = "Char";
		
	} else if (problemNumber == 5 || problemNumber == 10) {

		dataType = "Integer";
		
	} else {
		
		dataType = "error";
	
	}
	
	
	if (dataType == "Double"){
		
		return String.valueOf(Double.valueOf(param1) + Double.valueOf(param2));
	
	} else if (dataType == "String") {	
	
		return param1 + param2;
		
	} else if (dataType == "Char") {	
	
		return String.valueOf(param1.charAt(0) + param2.charAt(0));
		
	} else if (dataType == "Integer") {

		return String.valueOf(Integer.parseInt(param1) + Integer.parseInt(param2));
		
	} else {
		
		return "error";
	
	}
}
%>

<%
	//****************************************************************************
	// Declare and initialize variables
	// ****************************************************************************
	String view = "";
	String playerName = "";
	String report = "";
	String results = "";
	String outcomeMsg = "";
	Integer reportCounter = 0;
	Integer score = 0;
	Integer totalScore = 0;
	Integer timeRemaining = 0;
	Date timestamp;
	Integer problemNumber = 1;	
	String problems = ""; 
	String answers = ""; 
	String[] problems_array;
	String[] answers_array;
	String problem1 = "";
	String problem2 = "";
	String answer1 = "";
	String answer2 = "";
	String answer3 = "";
	String answer4 = "";
	String answerSubmit = "";
	String yourAnswer = "";
	String correctAnswer = "";
	String dbUrl = "jdbc:mysql://localhost:3306/trivia";
	String dbUser = "javauser";
	String dbPass = "password";
	String sql = "";
	Connection conn = null;
	Statement statement = null;
	ResultSet rs = null;
	
	
	// ****************************************************************************
	// Establish MySQL driver exists.
	// ****************************************************************************
	try {
		
		Class.forName("com.mysql.cj.jdbc.Driver");
	
	} catch (ClassNotFoundException e) {
		
		out.write(e.toString());
	
	} 
	
	// ****************************************************************************
	// Establish database connection
	// ****************************************************************************
	try {
				
		conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
		statement = conn.createStatement();
				
	} catch (SQLException e) {
			
		out.write(e.toString());
		
	}
	
	// ****************************************************************************
	// Determine view
	// ****************************************************************************
	view = request.getParameter("view");
	if(view == null){ 
		
		session.invalidate(); 
		view = "welcome"; 

	}
	
	// ****************************************************************************
	// processWelcome view
	// ****************************************************************************
	if(view.equals("processWelcome")){
		
		playerName = request.getParameter("playerName");
		session.setAttribute("playerName", playerName);
		session.setAttribute("problemNumber", problemNumber);
		session.setAttribute("totalScore", 0);
		session.setAttribute("results", null);
		session.setAttribute("results", results);
		view = "gameboard";
	
	}
	
	// ****************************************************************************
	// processGameboard view
	// ****************************************************************************
	if(view.equals("processGameboard")){ 
		
		playerName = (String) session.getAttribute("playerName");
		problemNumber = (Integer) session.getAttribute("problemNumber");
		
		Date date = new Date();
		timestamp = new Timestamp(date.getTime());
		
		answerSubmit = request.getParameter("answerSubmit");
		if(answerSubmit != null){
			
			problem1 = request.getParameter("problem1");
			problem2 = request.getParameter("problem2");
			answer1 = request.getParameter("answer1");
			answer2 = request.getParameter("answer2");
			answer3 = request.getParameter("answer3");
			answer4 = request.getParameter("answer4");
			
			if(answerSubmit.equals("Choice 1")){ yourAnswer = answer1; }
			else if(answerSubmit.equals("Choice 2")){ yourAnswer = answer2; }
			else if(answerSubmit.equals("Choice 3")){ yourAnswer = answer3; }
			else if(answerSubmit.equals("Choice 4")){ yourAnswer = answer4; }
			else { yourAnswer = "Time expired!"; }
			
			correctAnswer = getCorrectAnswer(problem1, problem2, problemNumber);
						
			// If the correct answer is not among the possible choices, report correct answer as error.
			if(!correctAnswer.equals(answer1) && !correctAnswer.equals(answer2) && !correctAnswer.equals(answer3) && !correctAnswer.equals(answer4)){ correctAnswer = "error"; }
			
			
			if(yourAnswer.equals(correctAnswer)){ 
					
				session.setAttribute("totalScore", (Integer) session.getAttribute("totalScore") + 1); 
				score = 1;
				
			} else {
				
				score = 0;
				
			}
			
			
			results = (String) session.getAttribute("results");
			if(results == null){ results = "<tr>"; } else { results += "<tr>"; }
			results += "<td>" + problemNumber + "</td>";
			results += "<td>" + problem1 + " + " + problem2 + "</td>";
			results += "<td>" + correctAnswer + "</td>";
			results += "<td>" + yourAnswer +  "</td>";
			results += "<td>" + score + "</td>";
			results += "<td class=\"nowrap\">" + timestamp +  "</td>";
			results += "</tr>";
			session.setAttribute("results", results);
		}
		
		problemNumber += 1;	
		
		if(problemNumber <= 10){
			
			session.setAttribute("problemNumber", problemNumber);
			view = "gameboard";
			
		} else {
				
			totalScore = (Integer) session.getAttribute("totalScore");
			sql = "INSERT INTO games (player_name, score, activity_date) VALUES ('" + playerName + "', " + totalScore + ", CURDATE())";
			statement.executeUpdate(sql);
			view = "results";
			
		}
		
	}
		
	// ****************************************************************************
	// Gameboard view
	// ****************************************************************************
	if(view.equals("gameboard")){ 
		
		playerName = (String) session.getAttribute("playerName");
		timeRemaining = 5;
		totalScore = (Integer) session.getAttribute("totalScore"); 
		
		problemNumber = (Integer) session.getAttribute("problemNumber");
		
		problems = Files.readAllLines(Paths.get("C://input.txt")).get((problemNumber * 2) - 2); 
		answers = Files.readAllLines(Paths.get("C://input.txt")).get((problemNumber * 2) - 1); 
		
		problems_array = problems.split(" ");
		answers_array = answers.split(" ");
		
		problem1 = problems_array[0];
		problem2 = problems_array[1];
		answer1 = answers_array[0];
		answer2 = answers_array[1];
		answer3 = answers_array[2];
		answer4 = answers_array[3];
		
	}
	
	// ****************************************************************************
	// Results view
	// ****************************************************************************
	if(view.equals("results")){ 
	
		results = (String) session.getAttribute("results");
		playerName = (String) session.getAttribute("playerName");
		timeRemaining = 5;
		totalScore = (Integer) session.getAttribute("totalScore"); 
		
		if(totalScore == 10){ outcomeMsg = "Congratulations! You are a genius!"; }
		else if(totalScore > 7){ outcomeMsg = "Congratulations! You did a fine job!"; }
		else if(totalScore > 4){ outcomeMsg = "Well, that was a average attempt. Try again, you can do better."; }
		else { outcomeMsg = "What happened!? Please try again. Surely you can do better than this!"; }
		
	}
	
	// ****************************************************************************
	// Report view
	// ****************************************************************************
	if(view.equals("report")){ 
		
		sql = "select player_name, score, activity_date FROM games ORDER BY id DESC LIMIT 10";
		rs = statement.executeQuery(sql);
		
		if(rs.next() == false){
			
			report = "<tr><td colspan=\"4\"><i>No records founds</i></td></tr>";
		
		} else {
			
			do{
				reportCounter += 1;
				report += "<tr>";
				report += "<td>" + reportCounter + "</td>";
				for(int i=1; i<=3; i++) {
					report += "<td>" + rs.getString(i) + "</td>";
				}	
				report += "</tr>";
				
			} while(rs.next());
		
		}
		
	}
	
	// ****************************************************************************
	// Close database connection
	// ****************************************************************************
	statement.close();
	conn.close();
	
%>
<body>
	<!-- ***** Application Header ***** -->
	<section>
		<h1>My Excellent Trivia Game</h1>
	</section>
	
	<% if(view.equals("welcome")){ %>
	<section>
		<p>This game will show two things to be added together. You must chose the correct answer from among four possible choices within 5 seconds.
		After 5 seconds, the game scores the question wrong and moves on to the next problem. You score 1 point for a correct answer and 0 points
		for a wrong answer. There are a total of 10 problems. At the end of the game, you will have a chance to see the results of the game as well 
		as generate a report of the last 10 players and their score.</p>
		
		<p>To get started, please enter your name and click the Submit button/<p>
	</section>
	 
	<section>
		<form action="application.jsp" method="POST">
			<fieldset>
				<legend>Player Name</legend>
				<input type="text" name="playerName" required>
				<input type="hidden" name="view" value="processWelcome">
				<br>
				<input type="submit" name="submit" id="submit" value="Submit">
			</fieldset>
		</form>
	</section>
	<% ;} %>
	
	
	<% if(view.equals("gameboard")){ %>
	<section>
	<table class="heading">
		<tr>
			<td><h2><% out.write(playerName); %></h2></td>
			<td style="text-align: center;"><b>Score: <% out.write(String.valueOf(totalScore)); %></b></td>
			<td style="text-align: right;"><b><span id="timer"></span> seconds remaining!</b></td>
		</tr>
	</table>
	</section>
	<section>
		<h3>Problem #<% out.write(String.valueOf(problemNumber)); %></h3>
		<form action="application.jsp" method="POST" id="gameboard">
		<table class="problemContainer">
			<tr>
				<td><% out.write(problem1); %></td>
				<td>+</td>
				<td><% out.write(problem2); %></td>
			</tr>
		</table>
		<!--  form action="application.jsp" method="POST" -->
		<table class="answerContainer">
			<tr>
				<td><% out.write(answer1); %><br><input type="submit" name="answerSubmit" value="Choice 1"></td>
				<td><% out.write(answer2); %><br><input type="submit" name="answerSubmit" value="Choice 2"></td>
				<td><% out.write(answer3); %><br><input type="submit" name="answerSubmit" value="Choice 3"></td>
				<td><% out.write(answer4); %><br><input type="submit" name="answerSubmit" value="Choice 4"></td>
			</tr>
		</table>
		<input type="hidden" name="problem1" value="<% out.write(problem1); %>">
		<input type="hidden" name="problem2" value="<% out.write(problem2); %>">
		<input type="hidden" name="answer1" value="<% out.write(answer1); %>">
		<input type="hidden" name="answer2" value="<% out.write(answer2); %>">
		<input type="hidden" name="answer3" value="<% out.write(answer3); %>">
		<input type="hidden" name="answer4" value="<% out.write(answer4); %>">
		<input type="hidden" name="view" value="processGameboard">
		</form>
	</section>
	<% ;} %>
	
	
	<% if(view.equals("results")){ %>
	<section>
	<table class="heading">
		<tr>
			<td><h2><% out.write(playerName); %></h2></td>
			<td style="text-align: center;"><b>Score: <% out.write(String.valueOf(totalScore)); %></b></td>
			<td style="text-align: right;">&nbsp;</td>
		</tr>
	</table>
	</section>
	<section>
		<h3>Results</h3>
		<p style="color: green; text-align: center;"><b><% out.write(outcomeMsg); %></b></p>
		<table class="resultsContainer">
			<tr>
				<th>#</th>
				<th>Problem</th>
				<th>Correct Answer</th>
				<th>Your Answer</th>
				<th>Points</th>
				<th>Timestamp</th>
			</tr>
			<% out.write(results); %>	
		</table>
	</section>
	
	<section>
		<form action="application.jsp" method="POST">
			<input type="hidden" name="view" value="report">
			<input type="submit" value="Generate Report">
		</form>
	</section>
	
	<section>
		<form action="application.jsp" method="POST">
			<input type="submit" value="Start New Game">
		</form>
	</section>
	<% ;} %>
	
	
	<% if(view.equals("report")){ %>
	<section>
		<h3>Last 10 Players</h3>
		<table class="reportContainer">
			<tr>
				<th>#</th>
				<th>Name</th>
				<th>Score</th>
				<th>Date</th>
			</tr>
			<% out.write(report); %>	
		</table>
	</section>
	
	<section>
	<form action="application.jsp" method="POST">
	<input type="submit" value="Start New Game">
	</form>
	</section>
	<% ;} %>
	
	
	
</body>
</html>