$(document).ready(function() {

	$("#addBtn").click(function() {
		$("#contactdiv").css("display", "block");

	});
	$("#contact #cancel").click(function() {
		$(this).parent().parent().hide();
	});
	
	// $("#contactdiv", {
	// 	.bind('beforeshow', function(){
			
	// 	});
	// }




	function getdurationIndex() {
		var getduration = document.getElementById("addduration").selectedIndex;
	};

	function getstatusIndex() {
		var getstatus = document.getElementById("addstatus").selectedIndex;
	};

	$("#adddate").datepicker({
		showAnim: "slide",
		showWeek:true
	});

	$("#addtime").timepicker({
		//console.log($(this).val());
	});

});

