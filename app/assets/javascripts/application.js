// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .

function moveEvent(event, dayDelta, minuteDelta, allDay){
    jQuery.ajax({
        data: 'id=' + event.id + '&title=' + event.title + '&day_delta=' + dayDelta + '&minute_delta=' + minuteDelta + '&all_day=' + allDay + '&authenticity_token=' + authenticity_token,
        dataType: 'script',
        type: 'post',
        url: "/events/move"
    });
}

function resizeEvent(event, dayDelta, minuteDelta){
    jQuery.ajax({
        data: 'id=' + event.id + '&title=' + event.title + '&day_delta=' + dayDelta + '&minute_delta=' + minuteDelta + '&authenticity_token=' + authenticity_token,
        dataType: 'script',
        type: 'post',
        url: "/events/resize"
    });
}

function showEventDetails(event){
    $('#event_desc').html(event.description);
    $('#edit_event').html("<a href = 'javascript:void(0);' onclick ='editEvent(" + event.id + ")'>Edit</a>");
    if (event.recurring) {
        title = event.title + "(Recurring)";
        $('#delete_event').html("&nbsp; <a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", " + false + ")'>Delete Only This Occurrence</a>");
        $('#delete_event').append("&nbsp;&nbsp; <a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", " + true + ")'>Delete All In Series</a>")
        $('#delete_event').append("&nbsp;&nbsp; <a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", \"future\")'>Delete All Future Events</a>")
    }
    else {
        title = event.title;
        $('#delete_event').html("<a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", " + false + ")'>Delete</a>");
    }
    $('#desc_dialog').dialog({
        title: title,
        modal: true,
        width: 500,
        close: function(event, ui){
            $('#desc_dialog').dialog('destroy')
        }
        
    });
}

function editEvent(event_id){
    jQuery.ajax({
      url: "/events/" + event_id + "/edit",
      success: function(data) {
        $('#event_desc').html(data['form']);
      } 
    });
}

function deleteEvent(event_id, delete_all){
  jQuery.ajax({
    data: 'authenticity_token=' + authenticity_token + '&delete_all=' + delete_all,
    dataType: 'script',
    type: 'delete',
    url: "/events/" + event_id,
    success: refetch_events_and_close_dialog
  });
}

function refetch_events_and_close_dialog() {
  $('#calendar').fullCalendar( 'refetchEvents' );
  $('.dialog:visible').dialog('destroy');
}

function showPeriodAndFrequency(value){

    switch (value) {
        case 'Daily':
            $('#period').html('day');
            $('#frequency').show();
            break;
        case 'Weekly':
            $('#period').html('week');
            $('#frequency').show();
            break;
        case 'Monthly':
            $('#period').html('month');
            $('#frequency').show();
            break;
        case 'Yearly':
            $('#period').html('year');
            $('#frequency').show();
            break;
            
        default:
            $('#frequency').hide();
    } 
}

function submitForm() {
    $.ajax({
		url: "/events/showEvent", // Route to the Script Controller method
		type: "GET",
		dataType: "json",
		success: function(data) {
			console.log(data);
		},
		error: function() {
			console.log("Ajax error!");
		}
	});
}

$(document).ready(function(){
	$.ajax({
		url: "/events/showEvent", // Route to the Script Controller method
		type: "GET",
		dataType: "json",
		success: function(data) {
			console.log(data);
		},
		error: function() {
			console.log("Ajax error!");
		}
	});
	$('#calendar').fullCalendar({
		header: {
            left: 'prev, next, today',
            center: 'title',
            right : 'basicDay, basicWeek, month'
        },
        titleFormat: {
            month: 'MMMM YYYY',
            week: 'MMM D YYYY',
            day: 'MMMM D YYYY'
        },
		events: function(start, end, timezone, callback) {
	        $.ajax({
	            url: '/events/showEvent',
	            dataType: 'xml',
	            type: "GET",
				dataType: "json",
	            success: function(data) {
	                var events = [];
	                for (key in data) {
	                	events.push({
	                        title: data[key].value.title,
	                        start: data[key].value.startDate + 'T' + data[key].value.startTime,
	                        end: data[key].value.endDate + 'T' + data[key].value.endTime,
	                        description: data[key].value.description
	                    });
	                	console.log(data[key].value.startDate + 'T' + data[key].value.startTime);
	                };
	                callback(events);
	            },
	            error: function() {
					console.log("Ajax error!");
				}
	        });
	    }
		
	    // dayClick: function(date, jsEvent, view) {
	    //     // change the day's background color just for fun
	    //     $(this).css('background-color', 'red');
	    // }
	});
	// $('#create_event_dialog, #desc_dialog').on('submit', "#event_form", function(event) {
 //    	var $spinner = $('.spinner');
 //    	event.preventDefault();
 //    	$.ajax({
	// 		type: "POST",
	// 		data: $(this).serialize(),
	// 		url: $(this).attr('action'),
	// 		beforeSend: show_spinner,
	// 		complete: hide_spinner,
	// 		success: refetch_events_and_close_dialog,
	// 		error: handle_error
 //    	});

	//     function show_spinner() {
	//       	$spinner.show();
	//     }

	//     function hide_spinner() {
	//       	$spinner.hide();
	//     }

	//     function handle_error(xhr) {
	//       	alert(xhr.responseText);
	//     }
 //  	})
});