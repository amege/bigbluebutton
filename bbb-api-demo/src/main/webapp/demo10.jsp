<!--
XX
BigBlueButton - http://www.bigbluebutton.org

Copyright (c) 2008-2009 by respective authors (see below). All rights reserved.

BigBlueButton is free software; you can redistribute it and/or modify it under the 
terms of the GNU Lesser General Public License as published by the Free Software 
Foundation; either version 3 of the License, or (at your option) any later 
version. 

BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY 
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along 
with BigBlueButton; if not, If not, see <http://www.gnu.org/licenses/>.

-->

<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<% 
	request.setCharacterEncoding("UTF-8"); 
	response.setCharacterEncoding("UTF-8"); 
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<link rel="stylesheet" type="text/css" href="css/ui.jqgrid.css" />
	<link rel="stylesheet" type="text/css" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.14/themes/redmond/jquery-ui.css" />
	<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js"></script>
	<script type="text/javascript" src="http://view.jquery.com/trunk/plugins/validate/jquery.validate.min.js"></script>
	<script src="js/jquery.jqGrid.min.js" type="text/javascript"></script>
	<script src="js/jquery.xml2json.js" type="text/javascript"></script>
	<title>Recording Meeting Demo</title>
	<style type="text/css">
	 #formcreate{
		margin-bottom:30px;
	 }
	 #formcreate label.labform{
	 	display:block;
	 	float:left;
	 	width:100px;
	 	text-align:right;
		margin-right:5px;
	 }
	 #formcreate div{
		margin-bottom:5px;
		clear:both;
	 }
	 #formcreate .submit{
		margin-left:100px;
		margin-top:15px;
	 }
	 #descript{
	 	vertical-align:top;
	 }
	 #meta_description , #username1{
		float:left;
	 }
	 .ui-jqgrid{
		font-size:0.7em
	}
	label.error{
		float: none; 
		color: red; 
		padding-left: .5em; 
		vertical-align: top;
		width:200px;
		text-align:left;
	}
	</style>
</head>
<body>

<%@ include file="bbb_api.jsp"%>
<%@ page import="java.util.regex.*"%>

<%@ include file="demo_header.jsp"%>

<%
	if (request.getParameterMap().isEmpty()) {
		//
		// Assume we want to create a meeting
		//
%>
	<h2>Join a Course (Recorded)</h2>

	<form id="formcreate" name="formcreate" method="get" action=""> 		
		<div>
			<label class="labform" for="meetingID">Course:</label>
			<select name="meetingID" onchange="onChangeMeeting(this.value);">
				<option value="English 101">English 101</option>
				<option value="English 102">English 102</option>
				<option value="English 103">English 103</option>
				<option value="English 104">English 104</option>
				<option value="English 105">English 105</option>
				<option value="English 106">English 106</option>
				<option value="English 107">English 107</option>
				<option value="English 108">English 108</option>
				<option value="English 109">English 109</option>
				<option value="English 110">English 110</option>
			</select>
		</div>
		<div>
			<label class="labform" id="descript" for="meta_description">Description:</label>
			<textarea id="meta_description" name="meta_description" cols="50" rows="6" autofocus required></textarea>
		</div>
		<div>
			<label class="labform" for="meta_email">Your Name:</label>
			<input id="meta_email" name="meta_email" type="text" required size="30" />
		</div>	
		<div style="clear:both"></div>
		<input class="submit" type="submit" value="Join" >
		<input type="hidden" name="action" value="create" />
	</form>

	<h3>Recorded Sessions</h3>
	<select id="actionscmb" name="actions" onchange="recordedAction(this.value);">
		<option value="novalue" selected>Actions...</option>
		<option value="publish">Publish</option>
		<option value="unpublish">Unpublish</option>
		<option value="delete">Delete</option>
	</select>
	<table id="recordgrid"></table>
	<p>Note: New recordings will appear in the above list after processing.  Refresh your browser to update the list.</p>
	<script>
	function onChangeMeeting(meetingID){
		isRunningMeeting(meetingID);
	}
	function recordedAction(action){
		if(action=="novalue"){
			return;
		}
		
		var s = jQuery("#recordgrid").jqGrid('getGridParam','selarrrow');
		if(s.length==0){
			alert("Select at least one row");
			$("#actionscmb").val("novalue");
			return;
		}
		var recordid="";
		for(var i=0;i<s.length;i++){
			var d = jQuery("#recordgrid").jqGrid('getRowData',s[i]);
			recordid+=d.id;
			if(i!=s.length-1)
				recordid+=",";
		}
		if(action=="delete"){
			var answer = confirm ("Are you sure to delete the selected recordings?");
			if (answer)
				sendRecordingAction(recordid,action);
			else{
				$("#actionscmb").val("novalue");
				return;
			}
		}else{
			sendRecordingAction(recordid,action);
		}
		$("#actionscmb").val("novalue");
	}
	
	function sendRecordingAction(recordID,action){
		$.ajax({
			type: "GET",
			url: 'demo10_helper.jsp',
			data: "command="+action+"&recordID="+recordID,
			dataType: "xml",
			cache: false,
			success: function(xml) {
				window.location.reload(true);
				$("#recordgrid").trigger("reloadGrid");
			},
			error: function() {
				alert("Failed to connect to API.");
			}
		});
	}
	
	function isRunningMeeting(meetingID) {
		$.ajax({
			type: "GET",
			url: 'demo10_helper.jsp',
			data: "command=isRunning&meetingID="+meetingID,
			dataType: "xml",
			cache: false,
			success: function(xml) {
				response = $.xml2json(xml);
				if(response.running=="true"){
					$("#meta_description").val("An active session exists for "+meetingID+". This session is being recorded.");
					$("#meta_description").attr("readonly","readonly");
					$("#meta_description").attr("disabled","disabled");
				}else{
					$("#meta_description").val("");
					$("#meta_description").removeAttr("readonly");
					$("#meta_description").removeAttr("disabled");
				}
				
			},
			error: function() {
				alert("Failed to connect to API.");
			}
		});
	}
	var meetingID="English 101,English 102,English 103,English 104,English 105,English 106,English 107,English 108,English 109,English 110";
	$(document).ready(function(){
		isRunningMeeting("English 232");
		$("#formcreate").validate();
		$("#meetingID option[value='English 101']").attr("selected","selected");
		jQuery("#recordgrid").jqGrid({
			url: "demo10_helper.jsp?command=getRecords&meetingID="+meetingID,
			datatype: "xml",
			height: 150,
			loadonce: true,
			sortable: true,
			colNames:['Id','Course','Description', 'Date Recorded', 'Published', 'Playback', 'Length'],
			colModel:[
				{name:'id',index:'id', width:50, hidden:true, xmlmap: "recordID"},
				{name:'course',index:'course', width:150, xmlmap: "meetingID", sortable:false},
				{name:'description',index:'description', width:300, xmlmap: "metadata>description",sortable: false},
				{name:'daterecorded',index:'daterecorded', width:200, xmlmap: "startTime", sortable: false},
				{name:'published',index:'published', width:80, xmlmap: "published", sortable:false },
				{name:'playback',index:'playback', width:150, formatter:playbackFormat, sortable:false},
				{name:'length',index:'length', width:80, sortable:false}
			],
			xmlReader: {
				root : "recordings",
				row: "recording",
				repeatitems:false,
				id: "id"
			},
			multiselect: true,
			caption: "Recorded Sessions",
			loadComplete: function(){
				$("#recordgrid").trigger("reloadGrid");
			}
		});
	});
	
	function playbackFormat( cellvalue, options, rowObject ){
		if($(rowObject).find('published:first').text()=="true"){
			var newval="<p>";
			$(rowObject).find('playback format').each(function() {
				if (newval != "<p>") {
					newval += ", ";
				}
				newval += '<a href="'+$(this).find("url").text()+'">'+$(this).find("type").text()+'</a>';
			});
			newval = newval + "</p>"
			return newval;
		}
		return "";
	}
	function lengthFormat( cellvalue, options, rowObject ){
		var duration = 0;
		$(rowObject).find('playback format').each(function() {
			var duration = parseInt($(this).find("length").text());
			if (duration != 0) {
				return false;
			}
		});
		return duration;
	}
	</script>
<%
	} else if (request.getParameter("action").equals("create")) {
		
		String meetingID = request.getParameter("meetingID");
		String username = request.getParameter("meta_email");
		
		//metadata
		Map<String,String> metadata=new HashMap<String,String>();
		
		metadata.put("description", request.getParameter("meta_description"));
		metadata.put("email", request.getParameter("meta_email"));
		// Use the meetingID (e.g English 101) as the title as slides playback
		// uses the title to display the link.
		metadata.put("title", request.getParameter("meetingID"));

		//
		// This is the URL for to join the meeting as moderator
		//
		String welcomeMsg = "<br>Welcome to %%CONFNAME%%!<br><br>For help see our <a href=\"event:http://www.bigbluebutton.org/content/videos\"><u>tutorial videos</u></a>.<br><br>To join the voice bridge for this meeting click the headset icon in the upper-left <b>(please use a headset to prevent echo)</b>.<br><br>This meeting is being recorded (audio + slides + chat).";
		String joinURL = getJoinURL(username, meetingID, "true", welcomeMsg, metadata, null);
		if (joinURL.startsWith("http://")) {
%>
<script language="javascript" type="text/javascript">
  window.location.href="<%=joinURL%>";
</script>
<%
		}else{
%>
Error: getJoinURL() failed
<p /><%=joinURL%> <%
		}
	}
%> 

<%@ include file="demo_footer.jsp"%>

</body>
</html>
