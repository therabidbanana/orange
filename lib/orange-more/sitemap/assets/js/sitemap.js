jQuery(function($){
	$('.sitemap_links_info a.more_info').toggle(
		function(){ 
			jQuery('.sitemap_links').show(); 
			jQuery('.sitemap_links_info a.more_info').text('Less Info');
		},
		function(){
			jQuery('.sitemap_links').hide(); 
			jQuery('.sitemap_links_info a.more_info').text('More Info');
		});
});