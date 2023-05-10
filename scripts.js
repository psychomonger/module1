//*****************************************************
//	George E. Mitchell
// 	202320 Object Oriented Programming COP-3330C-25749
// 	Final Programming Project
//	******************************************************-->
window.onload = function () { 
	
	var timeleft = 5;
	var element =  document.getElementById('timer');
	if (typeof(element) != 'undefined' && element != null){ 
			update_time();
			var interval = window.setInterval( update_time, 1000 ); 
			
	}
	
	function update_time(){
		
		if(timeleft < 0){ 
			
			clearInterval(interval); 
			var input = document.createElement("input");
			input.setAttribute("type", "hidden");
			input.setAttribute("name", "answerSubmit");
			input.setAttribute("value", "auto");
			document.getElementById("gameboard").appendChild(input);
			document.getElementById("gameboard").submit(); 
		
		}
		document.getElementById("timer").innerHTML = timeleft;
		timeleft -= 1;
		
	}
		
}