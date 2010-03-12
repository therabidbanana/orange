$(function(){
	$("div.page-listing-title a strong, div.page-listing-child-title a strong").hover(
		function(){
			$(this).parent().parent().parent().siblings("div.page-listing-cell").children("div.page-listing-excerpt").show();
		},
		function(){
			$(this).parent().parent().parent().siblings("div.page-listing-cell").children("div.page-listing-excerpt").hide();
	});
	$("a.publish-this").click(function(){
		$(this).prev("div.status-draft").switchClass("status-draft","status-published");
		$(this).prev("div.status-draft").text("Published");
		$(this).text("");
	});
	$("div.status-published").hover(
		function(){
			orig_text = $(this).text();
			$(this).addClass("status-draft");
			$(this).text("Unpublish");
		},
		function(){
			$(this).removeClass("status-draft");
			$(this).text(orig_text);
		});
	$("a.expand").toggle(
		function(){
			$(this).children("img").attr("src","/assets/public/images/page-listing-hide.png");
			$(this).parent().parent().parent("li").siblings("li").children("div.page-listing-child").slideDown();
		},
		function(){
			$(this).children("img").attr("src","/assets/public/images/page-listing-expand.png");
			$(this).parent().parent().parent("li").siblings("li").children("div.page-listing-child").slideUp();
		});
	$("a.page-listing-more-info").toggle(
		function(){
			$(this).parent().parent().siblings(".page-listing-extras").slice(0,2).show();
		},
		function(){
			$(this).parent().parent().siblings(".page-listing-extras").slice(0,2).hide();
		});
	$("a.move-button").toggle(
		function(){
			$(this).parent().parent().siblings("div.move-controls").show();
		},
		function(){
			$(this).parent().parent().siblings("div.move-controls").hide();
		});
	$("a.move-higher").click(function(){
		$(this).parent("form").submit(); 		
		return false;
	});
	$("a.move-lower").click(function(){
		$(this).parent("form").submit(); 
		return false;
	});
	$("a.move-indent").click(function(){
		$(this).parent("form").submit(); 
		return false;
	});
	$("a.move-outdent").click(function(){
		$(this).parent("form").submit(); 
		return false;
	});
	// $("form.move-arrow").ajaxForm();
});