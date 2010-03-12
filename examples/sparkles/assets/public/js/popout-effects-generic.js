$(function(){
	$("#edit-box").height($("#popout-box").height()+30);
	$("textarea#edit-content").height($("#edit-box").height()-168);
	$("#collapse").toggle(function(){
		$("#popout-box").animate({'left': '-232px','background-position': '232px 0'}, 200, 'swing');
		$("#edit-box, #button-container").animate({'width': '655px'}, 200, 'swing');
		$("#box-container").animate({'width': '960px'}, 200, 'swing');
		$(".markItUpHeader, .markItUpEditor, .markItUpFooter").animate({'width': '638px'}, 200, 'swing');
		$("#collapse img").attr('src','/assets/public/images/expand.png');
	},
	function(){	
		$("#popout-box").animate({'left': '0','background-position': '0 0'}, 200, 'swing');
		$("#edit-box, #button-container").animate({'width': '400px'}, 200, 'swing');
		$("#box-container").animate({'width': '776px'}, 200, 'swing');
		$(".markItUpHeader, .markItUpEditor, .markItUpFooter").animate({'width': '384px'}, 200, 'swing');
		$("#collapse img").attr('src','/assets/public/images/collapse-left.png');
	});
	$("a.collapse-up").toggle(function(){
		$(this).parent("div").siblings().next("div.settings-area").slideUp();
		$(this).children("img").attr('src','/assets/public/images/expand-down.png');
	},
	function(){
		$(this).parent("div").siblings().next("div.settings-area").slideDown();
		$(this).children("img").attr('src','/assets/public/images/collapse-up.png');
	});
 	$("#edit-content").markItUp(mySettings);
	$("textarea.autosize").autoResize({
	    extraSpace : 15
	});
	$("div.main-slider-container div.slider").draggable({
		axis: "x",
		containment: "parent",
		grid: [70,0],
		drag: mainSliderCaption
	});
	$("div.main-slider-container div.slider-background").click(function(){
		left = $(this).children(".slider").position().left;
		if (left > 60) {
			$("div.main-slider-container .slider").text("General"); 
			$(this).children(".slider").css({"position": "relative", "left": "0"});
			$(".page-settings-container-current").css("margin-left","0");
		}
		else {
			$("div.main-slider-container .slider").text("Custom"); 
			$(this).children(".slider").css({"position": "relative", "left": "73px"});
			$(".page-settings-container-current").css("margin-left","-276px");
		}
	});
	$("div#show-in-menu div.slider, div#show-in-menu div.slider-off").data('captions', {left_caption: "Yes", right_caption: "No"}).draggable({
		axis: "x",
		containment: "parent",
		grid: [70,0],
		drag: subSliderCaption,
		stop: changeSliderValue("div#show-in-menu", "show-in-menu", true)
	});
	$("#start-publish").datepicker();
	$("div#publish-when div.slider").data('captions', {left_caption: "Now", right_caption: "Later"}).draggable({
		axis: "x",
		containment: "parent",
		grid: [70,0],
		drag: subSliderCaption,
		stop: showDatePicker
	});
	function showDatePicker(){
		el = $(this);
		left = el.position().left;
		if (left == 82) {
			$("#start-publish-date").show();
			$("#start-publish").datepicker('show');
		}
		else {
			$("#start-publish-date").hide();
			$("#start-publish").datepicker('hide');
		}
	}
});
function mainSliderCaption(){
	el = $(this);
	left = el.position().left;
	if (left == 82) {
		$(".page-settings-container-current").stop().animate({'margin-left': '-276px'}, 200, "linear");
		el.text("Custom"); 
	}
	else {	
		$(".page-settings-container-current").stop().animate({"margin-left": "0"}, 200, "linear");
		el.text("General"); 
	}
}

function subSliderCaption(){
	var el = $(this);
	left = el.position().left;
	if (left == 82) {
		el.text(el.data('captions').right_caption);
	}
	else {	
		el.text(el.data('captions').left_caption);
	}
}

fire_now = false;
function changeSliderValue(el_parent, which_slider, fire_now = false){
	if (fire_now === true) {
		el = $(el_parent+" div.slider").length > 0 ? $(el_parent+" div.slider") : $(el_parent+" div.slider-off");
		left = el.position().left;
		switch (which_slider) {
			case "show-in-menu":
				if (left == 82) {
					$.post("/admin/sitemap/"+$("#page-id").val()+"/save", "route[show_in_nav]=0");
				}
				else {
					$.post("/admin/sitemap/"+$("#page-id").val()+"/save", "route[show_in_nav]=1");
				}
				break;
			default:
				break;
		}
	}
}