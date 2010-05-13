$(function(){
	$('.new-venue').hide();
	$('.show-venue-details').toggle(venue_details_show, venue_details_hide);
	$("#events-venue").change(function(){
		if($(this).val() == "new"){
			venue_details_blank();
			if($('.new-venue').css('display') == 'none') $('.show-venue-details').click();
		}
		else{
			load_venue_details($(this).val());
		}
	});
	$('input[name*=link_to_eventbrite]').change(function(){ 
		if($(this).attr('checked')){
			$('p.eventbrite-link').show();
		}
		else{
			$('p.eventbrite-link').hide();
		}
	});
	$('#events-eventbrite-id').change(function(){ 
		load_event_details($(this).val());
	});
	$("input[name*='location']").change(function(){$("#events-venue").val("new")});
});

function venue_details_show(){
	$('.show-venue-details').text('Hide'); 
	$('.new-venue').show();
}

function venue_details_hide(){
	$('.show-venue-details').text('(Details)'); 
	$('.new-venue').hide();
}

function load_venue_details(id){
	var obj = venues[id];
	$("input[name*=location_name]").val(obj.name);
	$("input[name*=location_address]").val(obj.address);
	$("input[name*=location_address2]").val(obj.address_2);
	$("input[name*=location_city]").val(obj.city);
	$("input[name*=location_state]").val(obj.region);
	$("input[name*=location_zip]").val(obj.postal_code);
}

function load_event_details(id){
	var obj = events[id];
	$("input[name*='events[name]']").val(obj.title);
	$("textarea[name*=description]").val(obj.description);
}

function venue_details_blank(){
	$("input[name*='location']").val('');
}