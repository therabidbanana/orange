$(function(){
	$("div#event-type div.slider").data('captions', {left_caption: "Public", right_caption: "Private"}).draggable({
		axis: "x",
		containment: "parent",
		grid: [70,0],
		drag: subSliderCaption,
	});
	$("div#event-registration-allowed div.slider").data('captions', {left_caption: "Enabled", right_caption: "Disabled"}).draggable({
		axis: "x",
		containment: "parent",
		grid: [70,0],
		drag: subSliderCaption,
	});
	$("a.pmt-img").toggle(
		function(){
			$(this).addClass("pmt-img-selected")
		},
		function(){
			$(this).removeClass("pmt-img-selected")
		})
});