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
//= require underscore
//= require gmaps/google
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
            right : 'month'
        },
        titleFormat: {
            month: 'MMMM YYYY',
            week: 'MMM D YYYY',
            day: 'MMMM D YYYY'
        },
        fixedWeekCount: false,
		events: function(start, end, timezone, callback) {
	        $.ajax({
	            url: '/events/showEvent',
	            type: "GET",
				dataType: "json",
	            success: function(data) {
                    console.log(data);
	                var events = [];
                    console.log(data);
	                for (key in data) {
                        var tempRange = ''; 
                        if (data[key].value.weatherTempMin && data[key].value.weatherTempMax) {
                            tempRange = ' : ' + data[key].value.weatherTempMin + '°F' + ' - ' + data[key].value.weatherTempMax + '°F';
                        }
	                	events.push({
                            key: data[key].path.key,
	                        title: data[key].value.title + tempRange,
                            tempRange: tempRange,
                            weatherSummary: data[key].value.weatherSummary,
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
	    },

        eventClick: function(event, jsEvent, view) {
            window.location.href = "editEvent?eventId=" + event.key;
        },

        eventMouseover: function( event, jsEvent, view ) { 
            $('html,body').css('cursor','pointer');

            var weatherSummary;
            if(event.weatherSummary) {
                weatherSummary = event.weatherSummary;
            } else {
                weatherSummary = '';
            }

            var tooltip = '<div class="tooltipevent" style="width:200px;height:auto;padding:10px;background:#fff;position:absolute;z-index:10001;box-shadow: 2px 2px 10px #B1B1B1;"><div>' + event.title + '</div><br/><div>' + weatherSummary + '</div></div>';
            $("body").append(tooltip);
            $(this).mouseover(function(e) {
                $(this).css('z-index', 10000);
                $('.tooltipevent').fadeIn('500');
                $('.tooltipevent').fadeTo('10', 1.9);
            }).mousemove(function(e) {
                $('.tooltipevent').css('top', e.pageY + 10);
                $('.tooltipevent').css('left', e.pageX + 20);
            });

            console.log(event);
        },

        eventMouseout: function( event, jsEvent, view ) { 
            $('html,body').css('cursor','auto');
            $(this).css('z-index', 8);
            $('.tooltipevent').remove();
        }
	});
});